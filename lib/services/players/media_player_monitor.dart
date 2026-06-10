import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../manager.dart';
import '../../models/episode.dart';
import '../../models/players/mediastatus.dart';
import '../../settings.dart';
import '../../utils/default_player.dart';
import '../../utils/path.dart';
import '../../utils/logging.dart';
import '../../utils/time.dart';
import '../navigation/dialogs.dart';
import '../navigation/navigation.dart';
import '../processes/monitor.dart' as process_monitor;
import '../lock_manager.dart';
import '../library/library_provider.dart';
import 'factory.dart';
import 'player_manager.dart';
import 'players/mpc_hc_slave_player.dart';
import 'slave/mpc_slave_manager.dart';

/// Information about a detected media player
class DetectedPlayer {
  final String id;
  final String name;
  final PlayerType type;
  final String? executablePath;
  final bool isAvailable;
  final String detectionMethod;
  final Map<String, dynamic>? customConfig;

  const DetectedPlayer({
    required this.id,
    required this.name,
    required this.type,
    this.executablePath,
    required this.isAvailable,
    required this.detectionMethod,
    this.customConfig,
  });

  @override
  String toString() => 'DetectedPlayer(id: $id, name: $name, available: $isAvailable)';
}

class MediaPlayerMonitorService with ChangeNotifier {
  final SettingsManager _settings;
  final Library _library;

  MediaPlayerMonitorService(this._settings, this._library) {
    if (_settings.enableMediaPlayerIntegration) {
      start();
    }
  }

  PlayerManager? _playerManager;
  Timer? _connectionTimer;
  Timer? _progressSaveTimer;
  Timer? _forcedSaveTimer;

  final List<DetectedPlayer> _detectedPlayers = [];
  String? _currentConnectedPlayer;
  StreamSubscription? _playerStatusSubscription;

  // MPC-HC slave mode
  MpcSlaveManager? _slaveManager;
  MpcSlavePlayer? _slavePlayer;
  StreamSubscription? _slaveChangesSub;
  bool _slaveLaunchPending = false;
  Timer? _slaveLaunchPendingTimer;

  // State tracking for immediate saves
  String? _lastFilePath;
  bool? _lastPlayingState;
  Episode? _lastEpisode;
  DateTime? _lastImmediateSaveTime;
  Duration? _lastSavedPosition;

  PlayerManager? get playerManager => _playerManager;
  List<DetectedPlayer> get detectedPlayers => List.unmodifiable(_detectedPlayers);
  String? get currentConnectedPlayer => _currentConnectedPlayer;

  /// Whether the active player can report a real volume level/mute (whether the UI should show the volume slider)
  ///
  /// Poll-based players always can;
  /// An MPC-HC slave session can only for the web-interface-owning (first-launched) instance
  bool get activePlayerSupportsVolumeRead {
    if (_playerManager?.currentPlayer is MpcSlavePlayer) return _slaveManager?.activeInstanceHasVolumeReadback ?? false;
    return true;
  }

  Future<void> start() async {
    if (!_settings.enableMediaPlayerIntegration) return;

    _playerManager = PlayerManager();
    _discoverPlayerExecutables();

    logDebug('Initializing video player process monitoring...');

    Future<bool> startProcessMonitoring() {
      return process_monitor.VideoPlayerProcessIntegration.initialize(
        onPlayerDetected: () {
          logDebug('Video player detected by process monitor - starting reconnection timer');
          _startPlayerAutoConnection();
        },
        onPlayerStopped: () {
          if (!process_monitor.VideoPlayerProcessIntegration.hasRunningPlayers) {
            logDebug('All video players stopped - stopping reconnection timer');
            _stopConnectionTimer();
          }
        },
        onSpecificPlayerStarted: (processName, playerType) {
          logDebug('Started: $processName (type: $playerType)');
        },
        onSpecificPlayerStopped: (processName, playerType) {
          logDebug('Stopped: $processName (type: $playerType)');
          handleSpecificPlayerStopped(processName, playerType);
        },
      );
    }

    var processMonitorStarted = await startProcessMonitoring();

    if (processMonitorStarted) {
      logDebug('Video player process monitoring started successfully');
    } else {
      logWarn('Video player process monitoring failed to start - restarting service to recover');

      await process_monitor.VideoPlayerProcessIntegration.stop();
      await Future.delayed(const Duration(seconds: 1));
      processMonitorStarted = await startProcessMonitoring();

      if (!processMonitorStarted) {
        logWarn('Video player process monitoring failed to start - fallback to timer-based connection');
        await _startPlayerAutoConnection();
      }
    }
  }

  Future<void> _startPlayerAutoConnection() async {
    if (_connectionTimer?.isActive == true) return;
    final interval = Duration(seconds: 5);
    await _attemptPlayerConnection();
    _connectionTimer = Timer.periodic(interval, (_) => _attemptPlayerConnection());
  }

  Future<void> stopPlayerAutoConnection() async {
    _connectionTimer?.cancel();
    _connectionTimer = null;
    await _playerStatusSubscription?.cancel();
    _playerStatusSubscription = null;
    _stopForcedSaveTimer();
    await _playerManager?.disconnect();
    _currentConnectedPlayer = null;
    logDebug('Stopped media player auto-connection');
  }

  void _stopConnectionTimer() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
  }

  /// Routes a player-process-exit event.
  ///
  /// For a pending or active slave session, prunes the specific dead instance rather than tearing down
  /// the whole (possibly multi-instance) player.
  /// The pending check covers a stale mpc-hc exit event arriving during the launch→CMD_CONNECT gap,
  /// when no instance is tracked yet but the facade is already connected
  @visibleForTesting
  void handleSpecificPlayerStopped(String processName, String playerType) {
    if (playerType == 'mpc-hc' && (_slaveLaunchPending || _slaveManager?.hasInstances == true)) {
      _slaveManager?.pruneDeadInstances();
      return;
    }
    _handlePlayerProcessStopped(processName, playerType);
  }

  void _handlePlayerProcessStopped(String processName, String playerType) {
    if (_currentConnectedPlayer != null && _isCurrentPlayerType(playerType)) {
      logWarn('Currently connected player process stopped: $processName');
      _disconnectCurrentPlayer();
    }
  }

  bool _isCurrentPlayerType(String playerType) {
    if (_currentConnectedPlayer == null) return false;
    switch (playerType) {
      case 'vlc':
        return _currentConnectedPlayer == 'vlc';
      case 'mpc-hc':
        return _currentConnectedPlayer == 'mpc-hc';
      default:
        return false;
    }
  }

  Future<void> _disconnectCurrentPlayer() async {
    await _playerStatusSubscription?.cancel();
    _playerStatusSubscription = null;
    _stopForcedSaveTimer();
    await _playerManager?.disconnect();
    _currentConnectedPlayer = null;
    notifyListeners();
  }

  Future<void> refreshMediaPlayers() async {
    _discoverPlayerExecutables();
    notifyListeners();
    await _startPlayerAutoConnection();
    notifyListeners();
  }

  Future<void> _attemptPlayerConnection() async {
    // Slave mode owns MPC-HC for app-launched instances;
    // Keep the poll path from hijacking or tearing it down while a slave session is active or still starting up (between launch and CMD_CONNECT)
    if (_slaveLaunchPending || _playerManager?.currentPlayer is MpcSlavePlayer) return;

    if (_currentConnectedPlayer != null && _playerManager?.isConnected == true) {
      if (await verifyPlayerConnection()) return;
    }

    if (_currentConnectedPlayer != null) {
      _currentConnectedPlayer = null;
      await _playerManager?.disconnect();
    }

    final userPriorityOrder = _settings.mediaPlayerPriority;

    try {
      final connected = await _playerManager?.autoConnect(userPriorityOrder) ?? false;
      if (connected) {
        final playerType = _playerManager?.currentPlayerType;
        final playerConfig = _playerManager?.currentPlayerConfig;

        if (playerType == PlayerType.vlc)
          _currentConnectedPlayer = 'vlc';
        else if (playerType == PlayerType.mpc)
          _currentConnectedPlayer = 'mpc-hc';
        else if (playerType == PlayerType.custom && playerConfig != null) _currentConnectedPlayer = playerConfig.name.toLowerCase().replaceAll(' ', '_');

        _setupPlayerStatusMonitoring();
        notifyListeners();
      }
    } catch (e) {
      logErr('Failed to connect to media player: $e');
    }
  }

  Future<void> stop() async {
    await stopPlayerAutoConnection();
    _progressSaveTimer?.cancel();
    _stopForcedSaveTimer();
    _slaveLaunchPendingTimer?.cancel();
    await _slaveChangesSub?.cancel();
    _slaveChangesSub = null;
    await _slaveManager?.dispose();
    _slaveManager = null;
    _slavePlayer = null;
    _playerManager?.dispose();
    await process_monitor.VideoPlayerProcessIntegration.stop();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  Future<bool> verifyPlayerConnection() async {
    if (_playerManager == null) return false;
    final isActuallyConnected = await _playerManager!.verifyConnection();

    if (!isActuallyConnected && _currentConnectedPlayer != null) {
      _currentConnectedPlayer = null;
      _stopForcedSaveTimer();
      notifyListeners();
    }
    return isActuallyConnected;
  }

  void _setupPlayerStatusMonitoring() {
    _playerStatusSubscription?.cancel();
    if (_playerManager == null) return;

    _playerStatusSubscription = _playerManager!.statusStream.listen(
      (status) => _handlePlayerStatusUpdate(status),
      onError: (error) {
        _currentConnectedPlayer = null;
        _stopForcedSaveTimer();
        notifyListeners();
      },
    );

    _startForcedSaveTimer();
  }

  void _handlePlayerStatusUpdate(MediaStatus status) {
    final currentFile = status.filePath;
    final currentEpisode = currentFile.isNotEmpty ? _library.getEpisodeByPath(PathString(currentFile)) : null;
    final lastFile = _lastFilePath ?? '';
    final currentPlaying = status.isPlaying;

    bool progressUpdated = false;
    if (currentEpisode != null) progressUpdated = _updateEpisodeFromPlayerStatus(currentEpisode, status);

    final playerClosed = lastFile.isNotEmpty && currentFile.isEmpty;
    final fileChanged = lastFile.isNotEmpty && currentFile.isNotEmpty && lastFile != currentFile;
    final playerPaused = _lastPlayingState == true && !currentPlaying;
    final episodeLost = _lastEpisode != null && currentEpisode == null;

    final shouldSaveImmediately = playerClosed || fileChanged || playerPaused || episodeLost || progressUpdated;

    if (shouldSaveImmediately) {
      _saveImmediately(
        currentStatus: status,
        episode: currentEpisode,
        forceFileChange: fileChanged,
        forcePlayerClosed: playerClosed,
      );
    }

    notifyListeners();
    _updateStateTracking(status, currentEpisode);
  }

  void _startForcedSaveTimer() {
    _forcedSaveTimer?.cancel();
    _forcedSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (!await verifyPlayerConnection()) {
        _stopForcedSaveTimer();
        return;
      }

      if (_library.lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) return;

      final currentStatus = _playerManager?.lastStatus;
      if (currentStatus != null && _hasPlayerStatusChanged(currentStatus)) {
        final currentEpisode = currentStatus.filePath.isNotEmpty ? _library.getEpisodeByPath(PathString(currentStatus.filePath)) : null;

        if (currentEpisode != null) {
          _updateEpisodeFromPlayerStatus(currentEpisode, currentStatus);
          await _library.saveEpisodeProgress(currentEpisode);
          notifyListeners();
          _updateStateTracking(currentStatus, currentEpisode);
        }
      }
    });
  }

  bool _hasPlayerStatusChanged(MediaStatus currentStatus) {
    final lastFile = _lastFilePath ?? '';
    return lastFile != currentStatus.filePath || _lastPlayingState != currentStatus.isPlaying || (currentStatus.filePath.isNotEmpty && _lastEpisode != null && (currentStatus.currentPosition.inMilliseconds - (_lastEpisode!.progress * currentStatus.totalDuration.inMilliseconds)).abs() > 2000);
  }

  void _updateStateTracking(MediaStatus status, Episode? episode) {
    _lastFilePath = status.filePath;
    _lastPlayingState = status.isPlaying;
    _lastEpisode = episode;
  }

  void _stopForcedSaveTimer() {
    _forcedSaveTimer?.cancel();
    _forcedSaveTimer = null;
  }

  Future<void> _saveImmediately({MediaStatus? currentStatus, Episode? episode, bool forceFileChange = false, bool forcePlayerClosed = false}) async {
    if (_library.lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) return;

    final currentPosition = currentStatus?.currentPosition;

    if (_lastImmediateSaveTime != null) {
      final timeSinceLastSave = now.difference(_lastImmediateSaveTime!);
      if (!forceFileChange && !forcePlayerClosed) {
        if (timeSinceLastSave.inSeconds < 5) return;
        if (currentPosition != null && _lastSavedPosition != null) {
          final positionDifference = (currentPosition.inSeconds - _lastSavedPosition!.inSeconds).abs();
          if (positionDifference < 10) return;
        }
      }
    }

    _progressSaveTimer?.cancel();
    _progressSaveTimer = null;

    episode ??= currentStatus != null && currentStatus.filePath.isNotEmpty ? _library.getEpisodeByPath(PathString(currentStatus.filePath)) : null;

    if (episode != null && await _library.saveEpisodeProgress(episode)) {
      // Success
    } else {
      await _library.persistLibrary(forceFull: true);
    }
    notifyListeners();

    _lastImmediateSaveTime = now;
    _lastSavedPosition = currentPosition;
  }

  bool _updateEpisodeFromPlayerStatus(Episode episode, MediaStatus status) {
    if (_library.lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) return false;

    if (status.totalDuration.inMilliseconds > 0) {
      final progress = status.currentPosition.inMilliseconds / status.totalDuration.inMilliseconds;
      episode.progress = progress.clamp(0.0, 1.0);

      if (progress > Library.progressThreshold && !episode.watched) {
        _library.markEpisodeWatched(episode, save: false);
        return true;
      } else if (episode.watched && progress < Library.progressThreshold) {
        _library.markEpisodeWatched(episode, watched: false, save: false);
        return true;
      }
    }
    return false;
  }

  Future<bool> connectToMediaPlayer() async {
    await _attemptPlayerConnection();
    return _currentConnectedPlayer != null;
  }

  /// If the OS default player for [file] is MPC-HC and slave mode is enabled, launches it in slave mode and wires it into this monitor's pipeline
  ///
  /// Returns true if it handled the launch;
  /// Returns false if the caller should open [file] with the OS default handler
  Future<bool> tryLaunchViaSlave(PathString file) async {
    if (!_settings.enableMediaPlayerIntegration || !_settings.enableMpcHcSlaveMode) return false;
    if (!Platform.isWindows) return false;
    if (_playerManager == null) return false; // integration not started

    final resolved = DefaultPlayerResolver.resolveForPath(file);
    if (resolved.kind != DefaultPlayerKind.mpcHc) return false;

    final exe = _resolveMpcHcExe(resolved);
    if (exe == null) {
      // MPC-HC is the default but its exe can't be located;
      // Show the one-time setup prompt and let the caller open the file with the OS default handler
      _promptForMpcHcPathOnce();
      return false;
    }

    _slaveManager ??= MpcSlaveManager();
    _slaveChangesSub ??= _slaveManager!.changes.listen((_) => _onSlaveChanged());

    // Hold off the poll path during the gap between launch and CMD_CONNECT
    _slaveLaunchPending = true;
    _slaveLaunchPendingTimer?.cancel();
    _slaveLaunchPendingTimer = Timer(const Duration(seconds: 10), () => _slaveLaunchPending = false);

    final launched = await _slaveManager!.launch(exe, file);
    if (!launched) {
      _slaveLaunchPending = false;
      return false;
    }

    await _adoptSlaveFacade();
    return true;
  }

  void _onSlaveChanged() {
    if (_slaveManager?.hasInstances == true) {
      // CMD_CONNECT arrived: release the launch hold and (re-)adopt the facade.
      // Re-adoption matters on slow launches, where the poll path (`verifyPlayerConnection`)
      // or a stale process-exit event may have torn the facade down during the launch→connect gap
      _slaveLaunchPendingTimer?.cancel();
      _slaveLaunchPendingTimer = null;
      _slaveLaunchPending = false;
      unawaited(_adoptSlaveFacade());
      return; // _adoptSlaveFacade notifies
    }

    // When the last slave instance closes, drop the facade so the poll path can resume (like an externally-opened player)
    if (_slaveManager != null && _playerManager?.currentPlayer is MpcSlavePlayer) {
      _currentConnectedPlayer = null;
      _playerManager?.disconnect();
    }
    notifyListeners();
  }

  /// Connects the slave facade once (subsequent launches just add another instance) and marks mpc-hc as the connected player
  ///
  /// Idempotent: safe to call both at launch time and again when CMD_CONNECT arrives
  Future<void> _adoptSlaveFacade() async {
    if (_playerManager == null || _slaveManager == null) return;

    if (_playerManager!.currentPlayer is! MpcSlavePlayer) {
      _slavePlayer ??= MpcSlavePlayer(_slaveManager!);
      await _playerManager!.connectToPushPlayer(_slavePlayer!, PlayerType.mpc);
      _setupPlayerStatusMonitoring();
    }
    _currentConnectedPlayer = 'mpc-hc';
    notifyListeners();
  }

  /// Test-only: wires a (fake) slave manager into the service so slow-launch sequences
  /// can be driven without launching a real MPC-HC or starting process monitoring.
  /// With [launchPending] and [adoptFacade] it reproduces the exact post-[tryLaunchViaSlave] state
  @visibleForTesting
  Future<void> debugInjectSlaveSession(MpcSlaveManager manager, {PlayerManager? playerManager, bool launchPending = false, bool adoptFacade = false}) async {
    _playerManager = playerManager ?? _playerManager ?? PlayerManager();
    _slaveManager = manager;
    _slaveChangesSub?.cancel();
    _slaveChangesSub = manager.changes.listen((_) => _onSlaveChanged());
    _slaveLaunchPending = launchPending;
    if (adoptFacade) await _adoptSlaveFacade();
  }

  /// Test-only: whether the launch→CMD_CONNECT hold is active
  @visibleForTesting
  bool get debugSlaveLaunchPending => _slaveLaunchPending;

  /// Caches a discovered mpc-hc executable path (App Paths / common folders) so slave mode works even when the OS-default association can't supply one,
  /// and so the Settings field can show it as a placeholder
  ///
  /// Runs regardless of the user override
  void _discoverPlayerExecutables() {
    if (!Platform.isWindows) return;

    final found = DefaultPlayerResolver.locateMpcHc();
    if (found != null) {
      // Update cached path if a new executable was found
      if (_settings.mpcHcDetectedPath != found) _settings.mpcHcDetectedPath = found;
      return;
    }

    // Clear cached path if the previously-detected install no longer exists
    final cachedPath = _settings.mpcHcDetectedPath;
    if (cachedPath.isNotEmpty && !File(cachedPath).existsSync()) _settings.mpcHcDetectedPath = '';
  }

  /// Resolves a usable mpc-hc.exe: user override, then the OS-default-resolved path, then the cached/just-discovered install
  ///
  /// Returns null if none exist
  String? _resolveMpcHcExe(DefaultPlayer resolved) {
    final override = _settings.mpcHcExecutablePath;
    if (override.isNotEmpty && File(override).existsSync()) return override;

    final fromDefault = resolved.executablePath;
    if (fromDefault != null && fromDefault.isNotEmpty && File(fromDefault).existsSync()) return fromDefault;

    final detected = _settings.mpcHcDetectedPath;
    if (detected.isNotEmpty && File(detected).existsSync()) return detected;

    final found = DefaultPlayerResolver.locateMpcHc();
    if (found != null) {
      _settings.mpcHcDetectedPath = found;
      return found;
    }
    return null;
  }

  /// Shows the one-time "locate MPC-HC for slave mode" prompt
  void _promptForMpcHcPathOnce() {
    if (_settings.mpcHcSlavePromptShown) return;
    _settings.mpcHcSlavePromptShown = true;

    try {
      showSimpleManagedDialog(
        Manager.context,
        id: 'mpc-hc-slave-setup',
        title: 'Set up MPC-HC for advanced control',
        body: 'MPC-HC is your default video player, but its location could not be found automatically. '
            'Set the MPC-HC path in Settings to enable push-based playback control (no polling) and tracking '
            'of multiple player windows. Playback still works without it.',
        positiveButtonText: 'Open Settings',
        negativeButtonText: 'Not now',
        isPositiveButtonPrimary: true,
        onPositive: () => NavigationManager.instance.goToMediaPlayerSettings(),
      );
    } catch (e, st) {
      logErr('Failed to show MPC-HC setup dialog', e, st);
    }
  }

  Future<void> pauseCurrentPlayback() async {
    if (!await verifyPlayerConnection()) return;
    await _playerManager?.pauseWithPoll();
  }

  Future<void> resumeCurrentPlayback() async {
    if (!await verifyPlayerConnection()) return;
    await _playerManager?.playWithPoll();
  }

  Future<void> setPlaybackVolume(int volume) async {
    if (!await verifyPlayerConnection()) return;
    await _playerManager?.setVolumeWithPoll(volume);
  }

  /// Relative volume change
  ///
  /// Works even when the absolute level is unknown (non-owner slave instances),
  /// where it sends a relative volume command to the active instance instead of an absolute set
  Future<void> stepVolumeCurrentPlayback(bool up) async {
    if (!await verifyPlayerConnection()) return;

    if (_playerManager?.currentPlayer is MpcSlavePlayer) {
      up //
          ? _slaveManager?.volumeUp()
          : _slaveManager?.volumeDown();
    } else {
      up //
          ? await _playerManager?.volumeUp()
          : await _playerManager?.volumeDown();
    }
  }

  Future<void> toggleMuteCurrentPlayback() async {
    if (!await verifyPlayerConnection()) return;
    final isMuted = _playerManager?.lastStatus?.isMuted ?? false;
    if (isMuted) {
      await _playerManager?.unmuteWithPoll();
    } else {
      await _playerManager?.muteWithPoll();
    }
  }

  Future<void> togglePlayPauseCurrentPlayback() async {
    if (!await verifyPlayerConnection()) return;
    await _playerManager?.togglePlayPauseWithPoll();
  }

  Future<void> nextCurrentVideo() async {
    if (!await verifyPlayerConnection()) return;
    await _playerManager?.nextVideoWithPoll();
  }

  Future<void> previousCurrentVideo() async {
    if (!await verifyPlayerConnection()) return;
    await _playerManager?.previousVideoWithPoll();
  }

  Future<void> gotoCurrentVideo(int seconds) async {
    if (!await verifyPlayerConnection()) return;
    await _playerManager?.seekWithPoll(seconds);
  }
}
