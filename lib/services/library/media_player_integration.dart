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

  /// Refresh player connections
  Future<void> refreshMediaPlayers() async {
    notifyListeners();
    Manager.setState();
    
    // Simply restart connection attempts using current user priority
    await _startPlayerAutoConnection();
    
    notifyListeners();
    Manager.setState();
  }

  /// Attempt to connect to players in user-defined priority order
  Future<void> _attemptPlayerConnection() async {
    // If already connected and connection is still active, don't attempt new connections
    if (_currentConnectedPlayer != null && _playerManager?.isConnected == true) {
      // Verify connection is still active by polling
      try {
        await _playerManager?.pollStatus();
        return; // Connection is good, no need to reconnect
      } catch (e) {
        // Connection is dead, continue with reconnection logic below
        logWarn('Connection verification failed for $_currentConnectedPlayer: $e');
      }
    }

    // Lost connection or not connected, try to reconnect
    if (_currentConnectedPlayer != null) {
      logWarn('Lost connection to $_currentConnectedPlayer, attempting reconnection');
      _currentConnectedPlayer = null;
      await _playerManager?.disconnect();
    }

    // Use the user's priority settings from UI, not PlayerConfig
    final userPriorityOrder = _settings.mediaPlayerPriority;
    
    try {
      final connected = await _playerManager?.autoConnect(userPriorityOrder) ?? false;

      if (connected) {
        // Determine which player we connected to based on PlayerManager's current state
        final playerType = _playerManager?.currentPlayerType;
        final playerConfig = _playerManager?.currentPlayerConfig;
        
        if (playerType == PlayerType.vlc) {
          _currentConnectedPlayer = 'vlc';
        } else if (playerType == PlayerType.mpc) {
          _currentConnectedPlayer = 'mpc-hc';
        } else if (playerType == PlayerType.custom && playerConfig != null) {
          _currentConnectedPlayer = playerConfig.name.toLowerCase().replaceAll(' ', '_');
        }
        
        _setupPlayerStatusMonitoring();
        logInfo('Connected to media player: $_currentConnectedPlayer (priority: ${userPriorityOrder.indexOf(_currentConnectedPlayer!) + 1})');
        notifyListeners();
        Manager.setState();
      }
    } catch (e) {
      logErr('Failed to connect to media player: $e');
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
}
