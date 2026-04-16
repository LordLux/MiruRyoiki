import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../models/episode.dart';
import '../../models/players/mediastatus.dart';
import '../../settings.dart';
import '../../utils/path.dart';
import '../../utils/logging.dart';
import '../../utils/time.dart';
import '../processes/monitor.dart' as process_monitor;
import '../lock_manager.dart';
import '../library/library_provider.dart';
import 'factory.dart';
import 'player_manager.dart';

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

  // State tracking for immediate saves
  String? _lastFilePath;
  bool? _lastPlayingState;
  Episode? _lastEpisode;
  DateTime? _lastImmediateSaveTime;
  Duration? _lastSavedPosition;

  PlayerManager? get playerManager => _playerManager;
  List<DetectedPlayer> get detectedPlayers => List.unmodifiable(_detectedPlayers);
  String? get currentConnectedPlayer => _currentConnectedPlayer;

  Future<void> start() async {
    if (!_settings.enableMediaPlayerIntegration) return;

    _playerManager = PlayerManager();

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
          _handlePlayerProcessStopped(processName, playerType);
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

  void _handlePlayerProcessStopped(String processName, String playerType) {
    if (_currentConnectedPlayer != null && _isCurrentPlayerType(playerType)) {
      logWarn('Currently connected player process stopped: $processName');
      _disconnectCurrentPlayer();
    }
  }

  bool _isCurrentPlayerType(String playerType) {
    if (_currentConnectedPlayer == null) return false;
    switch (playerType) {
      case 'vlc': return _currentConnectedPlayer == 'vlc';
      case 'mpc-hc': return _currentConnectedPlayer == 'mpc-hc';
      default: return false;
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
    notifyListeners();
    await _startPlayerAutoConnection();
    notifyListeners();
  }

  Future<void> _attemptPlayerConnection() async {
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

        if (playerType == PlayerType.vlc) _currentConnectedPlayer = 'vlc';
        else if (playerType == PlayerType.mpc) _currentConnectedPlayer = 'mpc-hc';
        else if (playerType == PlayerType.custom && playerConfig != null)
          _currentConnectedPlayer = playerConfig.name.toLowerCase().replaceAll(' ', '_');

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
    return lastFile != currentStatus.filePath ||
        _lastPlayingState != currentStatus.isPlaying ||
        (currentStatus.filePath.isNotEmpty &&
            _lastEpisode != null &&
            (currentStatus.currentPosition.inMilliseconds - (_lastEpisode!.progress * currentStatus.totalDuration.inMilliseconds)).abs() > 2000);
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

    episode ??= currentStatus != null && currentStatus.filePath.isNotEmpty
        ? _library.getEpisodeByPath(PathString(currentStatus.filePath))
        : null;

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
