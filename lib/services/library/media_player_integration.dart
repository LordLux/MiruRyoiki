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

    // Initialize video player process monitoring
    logDebug('Initializing video player process monitoring...');
    final processMonitorStarted = await process_monitor.VideoPlayerProcessIntegration.initialize(
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
        // If the currently connected player's process stopped, disconnect immediately
        _handlePlayerProcessStopped(processName, playerType);
      },
    );

    if (processMonitorStarted) {
      logDebug('Video player process monitoring started successfully');
    } else {
      logWarn('Video player process monitoring failed to start - starting timer-based connection as fallback');
      await _startPlayerAutoConnection(); // Fallback to timer-based connection
    }
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
    _stopForcedSaveTimer();
    await _playerManager?.disconnect();
    _currentConnectedPlayer = null;
    logDebug('Stopped media player auto-connection');
  }

  /// Stop only the connection timer (keep other connections active)
  void _stopConnectionTimer() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
    logDebug('Stopped connection timer - no video player processes running');
  }

  /// Handle when a specific player process stops
  void _handlePlayerProcessStopped(String processName, String playerType) {
    // Check if this is the currently connected player
    if (_currentConnectedPlayer != null && _isCurrentPlayerType(playerType)) {
      logWarn('Currently connected player process stopped: $processName');
      _disconnectCurrentPlayer();
    }
  }

  /// Check if the given player type matches currently connected player
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

  /// Disconnect current player and update UI
  Future<void> _disconnectCurrentPlayer() async {
    final previousPlayer = _currentConnectedPlayer;

    await _playerStatusSubscription?.cancel();
    _playerStatusSubscription = null;
    _stopForcedSaveTimer();
    await _playerManager?.disconnect();
    _currentConnectedPlayer = null;

    logInfo('Disconnected from $previousPlayer');
    notifyListeners();
    Manager.setState();
  }

  /// Refresh player connections
  Future<void> refreshMediaPlayers() async {
    notifyListeners();
    Manager.setState();

    await _startPlayerAutoConnection();

    notifyListeners();
    Manager.setState();
  }

  /// Attempt to connect to players in user defined priority order
  Future<void> _attemptPlayerConnection() async {
    // Don't attempt new connections if already connected and connection is still active
    if (_currentConnectedPlayer != null && _playerManager?.isConnected == true) {
      try {
        await _playerManager?.pollStatus();
        return; // Connection is good, no need to reconnect
      } catch (e) {
        // Connection is dead -> try to reconnect below
        logWarn('Connection verification failed for $_currentConnectedPlayer: $e');
      }
    }

    // Lost connection/not connected, try to reconnect
    if (_currentConnectedPlayer != null) {
      logWarn('Lost connection to $_currentConnectedPlayer, attempting reconnection');
      _currentConnectedPlayer = null;
      await _playerManager?.disconnect();
    }

    // Use the user's priority settings
    final userPriorityOrder = _settings.mediaPlayerPriority;

    try {
      final connected = await _playerManager?.autoConnect(userPriorityOrder) ?? false;

      if (connected) {
        // Determine which player we connected to based on PlayerManager's current state
        final playerType = _playerManager?.currentPlayerType;
        final playerConfig = _playerManager?.currentPlayerConfig;

        if (playerType == PlayerType.vlc)
          _currentConnectedPlayer = 'vlc';
        else if (playerType == PlayerType.mpc)
          _currentConnectedPlayer = 'mpc-hc';
        else if (playerType == PlayerType.custom && playerConfig != null) //
          _currentConnectedPlayer = playerConfig.name.toLowerCase().replaceAll(' ', '_');

        _setupPlayerStatusMonitoring();
        logInfo('Connected to media player: $_currentConnectedPlayer (priority: ${userPriorityOrder.indexOf(_currentConnectedPlayer!) + 1})');
        notifyListeners();
        Manager.setState();
      }
    } catch (e) {
      logErr('Failed to connect to media player: $e');
    }
  }

  /// Cleanup media player resources
  Future<void> disposeMediaPlayerIntegration() async {
    await stopPlayerAutoConnection();
    _progressSaveTimer?.cancel();
    _progressSaveTimer = null;
    _stopForcedSaveTimer();
    _playerManager?.dispose();
    _playerManager = null;
    _detectedPlayers.clear();

    // Stop video player process monitoring
    await process_monitor.VideoPlayerProcessIntegration.stop();
    logDebug('Video player process monitoring stopped');
  }

  /// Setup monitoring of player status for current playback information
  void _setupPlayerStatusMonitoring() {
    _playerStatusSubscription?.cancel();

    if (_playerManager == null) return;

    _playerStatusSubscription = _playerManager!.statusStream.listen(
      (status) {
        _handlePlayerStatusUpdate(status);
      },
      onError: (error) {
        logErr('Player status stream error: $error');
        _currentConnectedPlayer = null;
        _stopForcedSaveTimer();
        notifyListeners();
      },
    );

    // Start the forced save timer when monitoring begins
    _startForcedSaveTimer();
  }

  /// Handle player status updates
  void _handlePlayerStatusUpdate(MediaStatus status) {
    final currentFile = status.filePath;
    final currentEpisode = currentFile.isNotEmpty ? findEpisodeByPath(currentFile) : null;

    // Always update episode progress
    bool progressUpdated = false;
    if (currentEpisode != null) progressUpdated = _updateEpisodeFromPlayerStatus(currentEpisode, status);

    // Check for immediate save triggers
    final shouldSaveImmediately = _shouldTriggerImmediateSave(status, currentEpisode) || progressUpdated;
    // Save immediately if triggered by important status changes
    if (shouldSaveImmediately) _saveImmediately();

    // Update state tracking for next comparison
    _updateStateTracking(status, currentEpisode);
  }

  /// Find an episode by file path across all series
  /// Tries to optimize search by inferring series from path structure
  Episode? findEpisodeByPath(String filePath) {
    // Extract the series name from the file path relative to library path
    final libraryPath = _libraryPath;
    if (libraryPath == null) return null;

    // Get relative path from library root
    String relativePath;
    try {
      relativePath = path.relative(filePath, from: libraryPath);
    } catch (e) {
      // If path.relative fails, fall back to original search
      return _findEpisodeByPathFallback(filePath);
    }

    // Extract the first directory (series folder name)
    final pathSegments = path.split(relativePath);
    if (pathSegments.isEmpty) return null;

    final seriesFolderName = pathSegments.first;

    // Find the series with matching folder name
    final targetSeries = _series.where((series) {
      final seriesPath = path.relative(series.path.path, from: libraryPath);
      return path.basename(seriesPath) == seriesFolderName;
    }).firstOrNull;

    if (targetSeries == null) return null;

    // Search only within this specific series
    for (final episode in targetSeries.seasons.expand((s) => s.episodes)) {
      if (episode.path.path == filePath) {
        return episode;
      }
    }

    // Also search related media for this series
    for (final episode in targetSeries.relatedMedia) {
      if (episode.path.path == filePath) return episode;
    }

    return null;
  }

  /// Fallback method iterating through all series and episodes
  Episode? _findEpisodeByPathFallback(String filePath) {
    final String path = PathString(filePath).path;
    for (final series in _series) {
      for (final episode in series.seasons.expand((s) => s.episodes)) {
        if (episode.path.path == path) {
          return episode;
        }
      }
      for (final episode in series.relatedMedia) {
        if (episode.path.path == path) return episode;
      }
    }
    return null;
  }

  /// Check if the current state change should trigger an immediate save
  bool _shouldTriggerImmediateSave(MediaStatus status, Episode? currentEpisode) {
    final currentFile = status.filePath;
    final currentPlaying = status.isPlaying;
    final lastFile = _lastFilePath ?? '';

    // Player was closed (had a file, now doesn't)
    if (lastFile.isNotEmpty && currentFile.isEmpty) {
      logInfo('Player closed -> triggering immediate save');
      return true;
    }

    // Video changed (different file being played)
    if (lastFile.isNotEmpty && currentFile.isNotEmpty && lastFile != currentFile) {
      logInfo('Video changed from "$lastFile" to "$currentFile" -> triggering immediate save');
      return true;
    }

    // Player stopped playing (was playing, now not)
    if (_lastPlayingState == true && !currentPlaying) {
      logInfo('Player stopped/paused -> triggering immediate save');
      return true;
    }

    // Episode became null (had episode, now doesn't)
    if (_lastEpisode != null && currentEpisode == null) {
      logInfo('Episode tracking lost -> triggering immediate save');
      return true;
    }

    return false;
  }

  /// Start the forced save timer for regular progress updates
  /// Just to avoid having large gaps between saves if user leaves player running
  void _startForcedSaveTimer() {
    _forcedSaveTimer?.cancel();

    // Check and save every 60 seconds if player status has changed
    _forcedSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (_playerManager?.isConnected != true) {
        logTrace('Player disconnected - stopping forced save timer');
        _stopForcedSaveTimer();
        return;
      }

      final currentStatus = _playerManager?.lastStatus;

      // Only save if we have a valid status and it has changed
      if (currentStatus != null && _hasPlayerStatusChanged(currentStatus)) {
        final currentEpisode = currentStatus.filePath.isNotEmpty ? findEpisodeByPath(currentStatus.filePath) : null;

        if (currentEpisode != null) {
          // Update episode progress with current player status
          _updateEpisodeFromPlayerStatus(currentEpisode, currentStatus);
          logTrace('Updated episode progress during periodic check: ${currentEpisode.progressPercentage}');

          // Save to database and update UI
          await _saveLibrary();
          notifyListeners();
          Manager.setState();
          // logTrace('Auto-saved episode progress from media player monitoring (periodic)');

          // Update tracking after successful save
          _updateStateTracking(currentStatus, currentEpisode);
        }
      }
    });
  }

  /// Check if the player status has changed meaningfully since last check
  bool _hasPlayerStatusChanged(MediaStatus currentStatus) {
    final lastFile = _lastFilePath ?? '';

    // Status changed if file changed/playing state changed/significant progress made
    return lastFile != currentStatus.filePath || //
        _lastPlayingState != currentStatus.isPlaying ||
        (currentStatus.filePath.isNotEmpty && //
            _lastEpisode != null &&
            (currentStatus.currentPosition.inMilliseconds - (_lastEpisode!.progress * currentStatus.totalDuration.inMilliseconds)).abs() > 2000); // 2 second threshold
  }

  /// Update state tracking variables
  void _updateStateTracking(MediaStatus status, Episode? episode) {
    _lastFilePath = status.filePath;
    _lastPlayingState = status.isPlaying;
    _lastEpisode = episode;
  }

  /// Stop the forced save timer
  void _stopForcedSaveTimer() {
    _forcedSaveTimer?.cancel();
    _forcedSaveTimer = null;
  }

  /// Immediately save the library and cancel any pending saves
  Future<void> _saveImmediately() async {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = null;

    // Perform immediate save
    await _saveLibrary();
    notifyListeners();
    Manager.setState();
    logTrace('Immediately saved episode progress from media player monitoring');
  }

  /// Update episode information based on player status
  /// Returns true if the episode was set as watched/unwatched, false otherwise.
  bool _updateEpisodeFromPlayerStatus(Episode episode, MediaStatus status) {
    // Calculate progress percentage
    if (status.totalDuration.inMilliseconds > 0) {
      final progress = status.currentPosition.inMilliseconds / status.totalDuration.inMilliseconds;

      episode.progress = progress.clamp(0.0, 1.0);

      if (progress > Library.progressThreshold && !episode.watched) {
        // Mark as watched if progress > threshold
        markEpisodeWatched(episode, save: false);
        logInfo('Auto-marked episode "${episode.displayTitle}" as watched (progress: ${(progress * 100).toStringAsFixed(1)}%)');
        return true;
      } else if (episode.watched && progress < Library.progressThreshold) {
        // or mark as unwatched if progress < threshold
        markEpisodeWatched(episode, watched: false, save: false);
        logInfo('Auto-unmarked episode "${episode.displayTitle}" as watched (progress: ${(progress * 100).toStringAsFixed(1)}%)');
        return true;
      }
    }
    return false;
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
}
