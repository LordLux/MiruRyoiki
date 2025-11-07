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
      // Verify the connection is actually alive
      if (await verifyPlayerConnection()) return;

      // Connection verification failed -> try to reconnect below
      logWarn('Connection verification failed for $_currentConnectedPlayer');
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

  /// Verify if the player is actually still connected to the media player application
  /// Attempts to poll the player to verify it's still running and responding
  ///
  /// Returns true if the player is connected and responding, false otherwise
  /// Automatically cleans up stale connections if the player is not responding
  Future<bool> verifyPlayerConnection() async {
    if (_playerManager == null) return false;

    final isActuallyConnected = await _playerManager!.verifyConnection();

    if (!isActuallyConnected && _currentConnectedPlayer != null) {
      // Player was thought to be connected but is actually dead
      logWarn('Player connection verification failed, cleaning up stale connection to $_currentConnectedPlayer');
      _currentConnectedPlayer = null;
      _stopForcedSaveTimer();
      notifyListeners();
    }

    return isActuallyConnected;
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
    final lastFile = _lastFilePath ?? '';
    final currentPlaying = status.isPlaying;

    // Always update episode progress
    bool progressUpdated = false;
    if (currentEpisode != null) progressUpdated = _updateEpisodeFromPlayerStatus(currentEpisode, status);

    // Determine the type of save trigger
    final playerClosed = lastFile.isNotEmpty && currentFile.isEmpty;
    final fileChanged = lastFile.isNotEmpty && currentFile.isNotEmpty && lastFile != currentFile;
    final playerPaused = _lastPlayingState == true && !currentPlaying;
    final episodeLost = _lastEpisode != null && currentEpisode == null;

    // Check if we should save
    final shouldSaveImmediately = playerClosed || fileChanged || playerPaused || episodeLost || progressUpdated;

    // Log the reason for saving
    if (shouldSaveImmediately) {
      if (playerClosed)
        logInfo('Player closed -> triggering immediate save');
      else if (fileChanged)
        logInfo('Video changed from "$lastFile" to "$currentFile" -> triggering immediate save');
      else if (playerPaused)
        logInfo('Player stopped/paused -> triggering immediate save');
      else if (episodeLost)
        logInfo('Episode tracking lost -> triggering immediate save');
      else if (progressUpdated) logTrace('Episode progress updated -> triggering immediate save');
    }

    // Save immediately if triggered by important status changes
    if (shouldSaveImmediately) {
      _saveImmediately(
        currentStatus: status,
        forceFileChange: fileChanged,
        forcePlayerClosed: playerClosed,
      );
    }

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

  /// Start the forced save timer for regular progress updates
  /// Just to avoid having large gaps between saves if user leaves player running
  void _startForcedSaveTimer() {
    _forcedSaveTimer?.cancel();

    // Check and save every 60 seconds if player status has changed
    _forcedSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      // Verify the player is actually still connected
      if (!await verifyPlayerConnection()) {
        logTrace('Player connection verification failed - stopping forced save timer');
        _stopForcedSaveTimer();
        return;
      }

      // Don't save during library indexing to prevent conflicts
      if (_lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) {
        logTrace('Skipping periodic save from player - library is indexing');
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
  Future<void> _saveImmediately({MediaStatus? currentStatus, bool forceFileChange = false, bool forcePlayerClosed = false}) async {
    // Don't save during library indexing to prevent conflicts
    if (_lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) {
      logTrace('Skipping immediate save from player - library is indexing');
      return;
    }

    final currentPosition = currentStatus?.currentPosition;

    // Throttling
    if (_lastImmediateSaveTime != null) {
      final timeSinceLastSave = now.difference(_lastImmediateSaveTime!);

      // Always save if file changed or player closed
      if (!forceFileChange && !forcePlayerClosed) {
        // Don't save if less than 5 seconds have passed
        if (timeSinceLastSave.inSeconds < 5) {
          return;
        }

        // Check if more than 10 seconds of playback have occurred since last save
        if (currentPosition != null && _lastSavedPosition != null) {
          final positionDifference = (currentPosition.inSeconds - _lastSavedPosition!.inSeconds).abs();

          // If less than 10 seconds of progress, skip save
          if (positionDifference < 10) return;

          logTrace('Significant playback progress detected since last immediate save ($positionDifference s) -> proceeding with immediate save');
        }
      }
    }

    _progressSaveTimer?.cancel();
    _progressSaveTimer = null;

    // Perform immediate save
    await _saveLibrary();
    notifyListeners();
    Manager.setState();

    // Update throttling timestamps
    _lastImmediateSaveTime = now;
    _lastSavedPosition = currentPosition;

    logTrace('Immediately saved episode progress from media player monitoring');
  }

  /// Update episode information based on player status
  /// Returns true if the episode was set as watched/unwatched, false otherwise.
  bool _updateEpisodeFromPlayerStatus(Episode episode, MediaStatus status) {
    // Don't update episodes during library indexing to prevent conflicts
    if (_lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) {
      logTrace('Skipping episode update from player - library is indexing');
      return false;
    }

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
  Future<void> pauseCurrentPlayback() async {
    if (!await verifyPlayerConnection()) {
      logWarn('Cannot pause playback - player not connected');
      return;
    }
    await _playerManager?.pauseWithPoll();
  }

  Future<void> resumeCurrentPlayback() async {
    if (!await verifyPlayerConnection()) {
      logWarn('Cannot resume playback - player not connected');
      return;
    }
    await _playerManager?.playWithPoll();
  }

  Future<void> setPlaybackVolume(int volume) async {
    if (!await verifyPlayerConnection()) {
      logWarn('Cannot set volume - player not connected');
      return;
    }
    await _playerManager?.setVolumeWithPoll(volume);
  }

  Future<void> toggleMuteCurrentPlayback() async {
    if (!await verifyPlayerConnection()) {
      logWarn('Cannot toggle mute - player not connected');
      return;
    }
    final isMuted = _playerManager?.lastStatus?.isMuted ?? false;
    if (isMuted) {
      await _playerManager?.unmuteWithPoll();
    } else {
      await _playerManager?.muteWithPoll();
    }
  }

  /// Toggle play/pause with immediate status poll
  Future<void> togglePlayPauseCurrentPlayback() async {
    if (!await verifyPlayerConnection()) {
      logWarn('Cannot toggle play/pause - player not connected');
      return;
    }
    await _playerManager?.togglePlayPauseWithPoll();
  }

  /// Navigation controls with immediate status poll
  Future<void> nextCurrentVideo() async {
    if (!await verifyPlayerConnection()) {
      logWarn('Cannot go to next video - player not connected');
      return;
    }
    await _playerManager?.nextVideoWithPoll();
  }

  Future<void> previousCurrentVideo() async {
    if (!await verifyPlayerConnection()) {
      logWarn('Cannot go to previous video - player not connected');
      return;
    }
    await _playerManager?.previousVideoWithPoll();
  }

  Future<void> gotoCurrentVideo(int seconds) async {
    if (!await verifyPlayerConnection()) {
      logWarn('Cannot seek video - player not connected');
      return;
    }
    await _playerManager?.seekWithPoll(seconds);
  }

  /// Force immediate status update
  Future<void> pollCurrentPlayerStatus() async {
    if (!await verifyPlayerConnection()) {
      logWarn('Cannot poll player status - player not connected');
      return;
    }
    await _playerManager?.pollStatus();
  }
}
