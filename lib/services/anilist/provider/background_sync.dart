// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'anilist_provider.dart';

extension AnilistProviderBackgroundSync on AnilistProvider {
  /// Start the background sync service
  void startBackgroundSync() {
    _syncTimer?.cancel();
    _userDataRefreshTimer?.cancel();

    // Sync timer
    _syncTimer = Timer.periodic(_syncInterval, (_) => _performBackgroundSync());

    // Start user data refresh timer with foreground interval
    _startUserDataRefreshTimer(inForeground: true);

    // Perform immediate sync
    _performBackgroundSync();
  }

  /// Stop the background sync service
  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;

    _userDataRefreshTimer?.cancel();
    _userDataRefreshTimer = null;
  }

  /// Perform a background sync operation
  Future<void> _performBackgroundSync() async {
    // Don't start a new sync if one is already in progress
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      // Check connectivity first
      final isOnline = await _checkConnectivity();
      if (!isOnline) {
        _isSyncing = false;
        return;
      }

      // We're online, notify listeners about connectivity change if it was offline before
      if (_isOffline) {
        _isOffline = false;
        notifyListeners();
      }

      // Process pending mutations
      await processPendingMutations();

      // Refresh user lists if they're stale
      if (_lastListsCacheTime == null || now.difference(_lastListsCacheTime!) > Duration(hours: 3)) {
        syncStatusMessage.value = 'Refreshing Anilist data...';
        await _loadUserLists();
        syncStatusMessage.value = 'Anilist data updated';
        await Future.delayed(Duration(seconds: 3));
        syncStatusMessage.value = null;
      }
    } catch (e) {
      logErr('Error during background sync', e);
      syncStatusMessage.value = 'Sync error: ${e.toString()}';
      await Future.delayed(Duration(seconds: 5));
      syncStatusMessage.value = null;
    } finally {
      _isSyncing = false;
    }
  }

  /// Process all pending mutations
  Future<void> processPendingMutations() async {
    if (_pendingMutations.isEmpty) return;

    // Create a copy to avoid issues if new mutations are added during processing
    final mutations = List<AnilistMutation>.from(_pendingMutations);
    int successCount = 0;

    syncStatusMessage.value = 'Syncing changes...';

    final library = Provider.of<Library>(rootNavigatorKey.currentContext!, listen: false);
    final mutationsDao = library.database.mutationsDao;

    for (final mutation in mutations) {
      try {
        bool success = false;
        final changes = mutation.changes;

        switch (mutation.type) {
          case 'progress':
            final progress = changes['progress'] as int?;
            if (progress != null)
              success = await _anilistService.updateProgress(mutation.mediaId, progress);

          case 'status':
            final statusStr = changes['status'] as String?;
            if (statusStr != null) {
              final status = statusStr.toListStatus();
              if (status != null)
                success = await _anilistService.updateStatus(mutation.mediaId, status);
            }

          case 'score':
            final score = changes['score'] as int?;
            if (score != null)
              success = await _anilistService.updateScore(mutation.mediaId, score);

          case 'save_entry':
            final entry = await _anilistService.saveMediaListEntry(
              mediaId: mutation.mediaId,
              status: (changes['status'] as String?)?.toListStatus(),
              scoreRaw: changes['score'] as int?,
              progress: changes['progress'] as int?,
              repeat: changes['repeat'] as int?,
              priority: changes['priority'] as int?,
              private: changes['private'] as bool?,
              notes: changes['notes'] as String?,
              hiddenFromStatusLists: changes['hiddenFromStatusLists'] as bool?,
              customLists: (changes['customLists'] as List?)?.cast<String>(),
              startedAt: changes['startedAt'] != null ? DateValue.fromJson(Map<String, dynamic>.from(changes['startedAt'])) : null,
              completedAt: changes['completedAt'] != null ? DateValue.fromJson(Map<String, dynamic>.from(changes['completedAt'])) : null,
            );
            success = entry != null;

          case 'delete_entry':
            final entryId = changes['entryId'] as int?;
            if (entryId != null)
              success = await _anilistService.deleteMediaListEntry(entryId);
        }

        if (success) {
          // Remove from database
          await mutationsDao.deleteMutationByProperties(
            type: mutation.type,
            mediaId: mutation.mediaId,
            createdAt: mutation.createdAt,
          );
          successCount++;
        }
      } catch (e) {
        logErr('Error processing mutation', e);
        // Keep the mutation in the queue to try again later
      }
    }

    // Reload from database to sync in-memory list
    if (successCount > 0) {
      _pendingMutations = await mutationsDao.getAllMutations();

      // Refresh lists to ensure consistency
      await _loadUserLists();

      syncStatusMessage.value = 'Synced $successCount changes';
      await Future.delayed(Duration(seconds: 3));
      syncStatusMessage.value = null;
    }
  }

  /// Start or restart the user data refresh timer with appropriate interval
  void _startUserDataRefreshTimer({required bool inForeground}) {
    _userDataRefreshTimer?.cancel();

    final duration = inForeground
        ? const Duration(minutes: 15) // 15 minutes in foreground
        : const Duration(minutes: 60); // 60 minutes in background

    _userDataRefreshTimer = Timer.periodic(duration, (_) {
      if (!_isOffline && isLoggedIn) {
        refreshUserData();
        logTrace('Auto-refreshing user data (${inForeground ? 'foreground' : 'background'} mode)');
      }
    });
  }

  /// Handle app lifecycle state changes
  void handleAppLifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // logTrace('App resumed'); // refreshing data and switching to foreground refresh rate
        // App came to foreground, switch to shorter refresh interval
        _startUserDataRefreshTimer(inForeground: true);

        // Immediate refresh when app comes to foreground only if the timer has run off
        if (isLoggedIn && !_isOffline && (_lastUserDataRefreshTime == null || now.difference(_lastUserDataRefreshTime!).inMinutes >= 15)) {
          refreshUserData();
          refreshUserLists(showSnackBar: false);
          _refreshNotifications();
        }
        break;

      case AppLifecycleState.paused:
        logTrace('App paused - switching to background refresh rate');
        // App went to background, switch to longer refresh interval
        _startUserDataRefreshTimer(inForeground: false);
        break;

      default:
        // No action needed for other states
        break;
    }
  }

  /// Refresh notifications in the background
  Future<void> _refreshNotifications() async {
    if (!isLoggedIn || _isOffline) return;

    // Don't refresh too frequently
    if (_lastNotificationRefresh != null && now.difference(_lastNotificationRefresh!).inMinutes < 10) return;
    _lastNotificationRefresh = now;

    try {
      // We can't access the context here, but the notification widgets will
      // refresh themselves when they're shown, so we'll just trigger a refresh
      // on the release notification widget if it exists
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        final library = Provider.of<Library>(context, listen: false);
        await _anilistService.syncNotifications(
          database: library.database,
          types: [NotificationType.AIRING, NotificationType.RELATED_MEDIA_ADDITION, NotificationType.MEDIA_DATA_CHANGE],
          maxPages: 2,
        );
      }
    } catch (e) {
      if (!isExpectedOfflineError(e)) {
        logErr('Background notification refresh failed', e);
      } else {
        logTrace('Background notification refresh skipped - offline');
      }
    }
  }
}
