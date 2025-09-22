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
    _stopForcedSaveTimer();
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
        _stopForcedSaveTimer();
        notifyListeners();
      },
    );

    // Start the forced save timer when monitoring begins
    _startForcedSaveTimer();
  }

  /// Handle player status updates - integrate with your episode tracking
  void _handlePlayerStatusUpdate(MediaStatus status) {
    final currentFile = status.filePath;
    final currentEpisode = currentFile.isNotEmpty ? _findEpisodeByPath(currentFile) : null;

    // Always update episode progress if we have a valid episode
    bool progressUpdated = false;
    if (currentEpisode != null) progressUpdated = _updateEpisodeFromPlayerStatus(currentEpisode, status);

    // Check for immediate save triggers (important status changes)
    final shouldSaveImmediately = _shouldTriggerImmediateSave(status, currentEpisode) || progressUpdated;

    // Save immediately if triggered by important status changes
    if (shouldSaveImmediately) _saveImmediately();

    // Update state tracking for next comparison
    _updateStateTracking(status, currentEpisode);
  }

  /// Find an episode by file path across all series
  Episode? _findEpisodeByPath(String filePath) {
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

  /// Fallback method using original approach
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
      logInfo('Player closed - triggering immediate save');
      return true;
    }

    // Video changed (different file being played)
    if (lastFile.isNotEmpty && currentFile.isNotEmpty && lastFile != currentFile) {
      logInfo('Video changed from "$lastFile" to "$currentFile" - triggering immediate save');
      return true;
    }

    // Player stopped playing (was playing, now not)
    if (_lastPlayingState == true && !currentPlaying) {
      logInfo('Player stopped/paused - triggering immediate save');
      return true;
    }

    // Episode became null (had episode, now doesn't)
    if (_lastEpisode != null && currentEpisode == null) {
      logInfo('Episode tracking lost - triggering immediate save');
      return true;
    }

    return false;
  }

  /// Start the forced save timer for regular progress updates
  void _startForcedSaveTimer() {
    // Cancel any existing forced save timer
    _forcedSaveTimer?.cancel();

    // Check and save every 90 seconds if player status has changed
    _forcedSaveTimer = Timer.periodic(const Duration(seconds: 90), (timer) async {
      final currentStatus = _playerManager?.lastStatus;

      // Only save if we have a valid status and it has changed
      if (currentStatus != null && _hasPlayerStatusChanged(currentStatus)) {
        final currentEpisode = currentStatus.filePath.isNotEmpty ? _findEpisodeByPath(currentStatus.filePath) : null;

        if (currentEpisode != null) {
          // Update episode progress with current player status
          _updateEpisodeFromPlayerStatus(currentEpisode, currentStatus);
          logTrace('Updated episode progress during periodic check: ${(currentEpisode.progress * 100).toStringAsFixed(1)}%');

          // Save to database and update UI
          await _saveLibrary();
          notifyListeners();
          Manager.setState();
          logTrace('Auto-saved episode progress from media player monitoring (periodic)');

          // Update tracking after successful save
          _updateStateTracking(currentStatus, currentEpisode);
        }
      }
    });
  }

  /// Check if the player status has meaningfully changed since last check
  bool _hasPlayerStatusChanged(MediaStatus currentStatus) {
    final lastFile = _lastFilePath ?? '';

    // Status changed if file changed, playing state changed, or significant progress made
    return lastFile != currentStatus.filePath || _lastPlayingState != currentStatus.isPlaying || (currentStatus.filePath.isNotEmpty && _lastEpisode != null && (currentStatus.currentPosition.inMilliseconds - (_lastEpisode!.progress * currentStatus.totalDuration.inMilliseconds)).abs() > 5000); // 5 second threshold
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
    // Cancel any pending debounced save (if any exists)
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
        logInfo('Auto-marked episode "${episode.name}" as watched (progress: ${(progress * 100).toStringAsFixed(1)}%)');
        return true;
      } else if (episode.watched && progress < Library.progressThreshold) {
        // or mark as unwatched if progress < threshold
        markEpisodeWatched(episode, watched: false, save: false);
        logInfo('Auto-unmarked episode "${episode.name}" as watched (progress: ${(progress * 100).toStringAsFixed(1)}%)');
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

  /// Cleanup media player resources
  Future<void> disposeMediaPlayerIntegration() async {
    await stopPlayerAutoConnection();
    _progressSaveTimer?.cancel();
    _progressSaveTimer = null;
    _stopForcedSaveTimer();
    _playerManager?.dispose();
    _playerManager = null;
    _detectedPlayers.clear();
  }
}
