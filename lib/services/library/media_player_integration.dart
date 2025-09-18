part of 'library_provider.dart';

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

/// Media player integration methods for Library class
extension LibraryMediaPlayerIntegration on Library {
  /// Get the current player manager instance
  PlayerManager? get playerManager => _playerManager;

  /// Get detected players
  List<DetectedPlayer> get detectedPlayers => List.unmodifiable(_detectedPlayers);

  /// Currently connected player ID
  String? get currentConnectedPlayer => _currentConnectedPlayer;

  /// Initialize media player integration
  Future<void> initializeMediaPlayerIntegration() async {
    if (!_settings.enableMediaPlayerIntegration) return;

    await _detectAvailablePlayers();
    _playerManager = PlayerManager();

    await _startPlayerAutoConnection(); // Always auto-connect
  }

  /// Start automatic player connection attempts
  Future<void> _startPlayerAutoConnection() async {
    if (_connectionTimer?.isActive == true) return;

    final interval = Duration(seconds: 5);
    logDebug('Starting media player auto-connection with ${interval.inSeconds}s interval');

    // Try immediate connection
    await _attemptPlayerConnection();

    // Schedule periodic attempts
    _connectionTimer = Timer.periodic(interval, (_) => _attemptPlayerConnection());
  }

  /// Stop automatic player connection
  Future<void> stopPlayerAutoConnection() async {
    _connectionTimer?.cancel();
    _connectionTimer = null;
    await _playerStatusSubscription?.cancel();
    _playerStatusSubscription = null;
    await _playerManager?.disconnect();
    _currentConnectedPlayer = null;
    logDebug('Stopped media player auto-connection');
  }

  /// Detect available media players on the system
  Future<void> _detectAvailablePlayers() async {
    _detectedPlayers.clear();

    // Detect MPC-HC
    final mpcHc = await _detectMpcHc();
    if (mpcHc != null) _detectedPlayers.add(mpcHc);

    // Detect VLC
    final vlc = await _detectVlc();
    if (vlc != null) _detectedPlayers.add(vlc);

    logDebug('Detected ${_detectedPlayers.length} media players: ${_detectedPlayers.map((p) => p.name).join(', ')}');
  }

  /// Refresh detected players and update connections
  Future<void> refreshMediaPlayers() async {
    await _detectAvailablePlayers();

    // Always restart connection attempts
    await _startPlayerAutoConnection();

    notifyListeners();
    Manager.setState();
  }

  /// Attempt to connect to players in priority order
  Future<void> _attemptPlayerConnection() async {
    // If already connected, verify connection is still active
    if (_currentConnectedPlayer != null && _playerManager?.isConnected == true) return; // Still connected

    // Lost connection or not connected, try to reconnect
    if (_currentConnectedPlayer != null) {
      logWarn('Lost connection to $_currentConnectedPlayer, attempting reconnection');
      _currentConnectedPlayer = null;
      await _playerManager?.disconnect();
    }

    // Try players in priority order
    final priority = _settings.mediaPlayerPriority;
    for (final playerId in priority) {
      final player = _detectedPlayers.where((p) => p.id == playerId).firstOrNull;
      if (player == null || !player.isAvailable) continue;

      try {
        final connected = await _playerManager?.autoConnect() ?? false;

        if (connected) {
          _currentConnectedPlayer = playerId;
          _setupPlayerStatusMonitoring();
          logInfo('Connected to media player: ${player.name}');
          notifyListeners();
          Manager.setState();
          return;
        }
      } catch (e) {
        logErr('Failed to connect to ${player.name}: $e');
      }
    }
  }

  /// Setup monitoring of player status for current playback information
  void _setupPlayerStatusMonitoring() {
    _playerStatusSubscription?.cancel();

    if (_playerManager == null) return;

    _playerStatusSubscription = _playerManager!.statusStream.listen(
      (status) {
        // Here you could update episode progress, detect what's playing, etc.
        _handlePlayerStatusUpdate(status);
      },
      onError: (error) {
        logErr('Player status stream error: $error');
        _currentConnectedPlayer = null;
        notifyListeners();
      },
    );
  }

  /// Handle player status updates - integrate with your episode tracking
  void _handlePlayerStatusUpdate(MediaStatus status) {
    // Find which episode is currently playing by matching file path
    final currentFile = status.filePath;
    if (currentFile.isNotEmpty) {
      final episode = _findEpisodeByPath(currentFile);
      if (episode != null) {
        // Update episode progress/watched status
        _updateEpisodeFromPlayerStatus(episode, status);
      }
    }
  }

  /// Find an episode by file path across all series
  Episode? _findEpisodeByPath(String filePath) {
    for (final series in _series) {
      // Search through all episodes in all seasons
      for (final episode in series.seasons.expand((s) => s.episodes)) {
        if (episode.path.path == filePath) {
          return episode;
        }
      }
      // Also search related media
      for (final episode in series.relatedMedia) {
        if (episode.path.path == filePath) return episode;
      }
    }
    return null;
  }

  /// Update episode information based on player status
  void _updateEpisodeFromPlayerStatus(Episode episode, MediaStatus status) {
    // Calculate progress percentage
    if (status.totalDuration.inMilliseconds > 0) {
      final progress = status.currentPosition.inMilliseconds / status.totalDuration.inMilliseconds;

      // Mark as watched if progress > threshold
      if (progress > Library.progressThreshold && !episode.watched) //
        markEpisodeWatched(episode, save: false);
    }
  }

  /// Manual player connection trigger
  Future<bool> connectToMediaPlayer() async {
    await _attemptPlayerConnection();
    return _currentConnectedPlayer != null;
  }

  /// Control playback through connected player
  Future<void> pauseCurrentPlayback() async => await _playerManager?.pauseWithPoll();

  Future<void> resumeCurrentPlayback() async => await _playerManager?.playWithPoll();

  Future<void> setPlaybackVolume(int volume) async => await _playerManager?.setVolumeWithPoll(volume);

  Future<void> toggleMuteCurrentPlayback() async {
    final isMuted = _playerManager?.lastStatus?.isMuted ?? false;
    if (isMuted) {
      await _playerManager?.unmuteWithPoll();
    } else {
      await _playerManager?.muteWithPoll();
    }
  }

  /// Toggle play/pause with immediate status poll
  Future<void> togglePlayPauseCurrentPlayback() async => await _playerManager?.togglePlayPauseWithPoll();

  /// Navigation controls with immediate status poll
  Future<void> nextCurrentVideo() async => await _playerManager?.nextVideoWithPoll();

  Future<void> previousCurrentVideo() async => await _playerManager?.previousVideoWithPoll();

  Future<void> gotoCurrentVideo(int seconds) async => await _playerManager?.seekWithPoll(seconds);

  /// Force immediate status update
  Future<void> pollCurrentPlayerStatus() async => await _playerManager?.pollStatus();

  /// Cleanup media player resources
  Future<void> disposeMediaPlayerIntegration() async {
    await stopPlayerAutoConnection();
    _playerManager?.dispose();
    _playerManager = null;
    _detectedPlayers.clear();
  }

  // Player detection methods
  Future<DetectedPlayer?> _detectMpcHc() async {
    // Implementation for detecting MPC-HC
    try {
      final result = await Process.run('where', ['mpc-hc64.exe']);
      if (result.exitCode == 0 && result.stdout.toString().isNotEmpty) {
        final executablePath = result.stdout.toString().trim().split('\n').first;
        final file = File(executablePath);
        if (await file.exists()) {
          return DetectedPlayer(
            id: 'mpc-hc',
            name: 'MPC-HC',
            type: PlayerType.mpc,
            executablePath: executablePath,
            isAvailable: true,
            detectionMethod: 'PATH lookup',
          );
        }
      }
    } catch (e) {
      // Try common installation paths
      final commonPaths = [
        r'C:\Program Files\MPC-HC\mpc-hc64.exe',
        r'C:\Program Files (x86)\MPC-HC\mpc-hc64.exe',
      ];

      for (final path in commonPaths) {
        final file = File(path);
        if (await file.exists()) {
          return DetectedPlayer(
            id: 'mpc-hc',
            name: 'MPC-HC',
            type: PlayerType.mpc,
            executablePath: path,
            isAvailable: true,
            detectionMethod: 'Common directory scan',
          );
        }
      }
    }
    return null;
  }

  Future<DetectedPlayer?> _detectVlc() async {
    // Implementation for detecting VLC
    const vlcLinkPath = r'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\VLC media player.lnk';

    try {
      final linkFile = File(vlcLinkPath);
      if (await linkFile.exists()) {
        return DetectedPlayer(
          id: 'vlc',
          name: 'VLC Media Player',
          type: PlayerType.vlc,
          executablePath: vlcLinkPath,
          isAvailable: true,
          detectionMethod: 'Start Menu shortcut',
        );
      }
    } catch (e) {
      logErr('Error detecting VLC: $e');
    }
    return null;
  }
}
