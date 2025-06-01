part of 'anilist_provider.dart';

extension AnilistProviderBackgroundSync on AnilistProvider {
  /// Start the background sync service
  void startBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => _performBackgroundSync());

    // Also perform an immediate sync
    _performBackgroundSync();
  }

  /// Stop the background sync service
  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
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

    for (final mutation in mutations) {
      try {
        bool success = false;

        switch (mutation.type) {
          // TODO use enum for mutation types
          case 'progress':
            final progress = mutation.changes['progress'] as int?;
            if (progress != null) //
              success = await _anilistService.updateProgress(mutation.mediaId, progress);

            break;

          case 'status':
            final statusStr = mutation.changes['status'] as String?;
            if (statusStr != null) {
              final status = statusStr.toListStatus();
              if (status != null) //
                success = await _anilistService.updateStatus(mutation.mediaId, status);
            }
            break;

          case 'score':
            final score = mutation.changes['score'] as int?;
            if (score != null) //
              success = await _anilistService.updateScore(mutation.mediaId, score);

            break;

          // TODO Handle other mutation types
        }

        if (success) {
          _pendingMutations.remove(mutation);
          successCount++;
        }
      } catch (e) {
        logErr('Error processing mutation', e);
        // Keep the mutation in the queue to try again later
      }
    }

    // Save the updated queue
    if (successCount > 0) {
      await saveMutationsQueue();

      // Refresh lists to ensure consistency
      await _loadUserLists();

      syncStatusMessage.value = 'Synced $successCount changes';
      await Future.delayed(Duration(seconds: 3));
      syncStatusMessage.value = null;
    }
  }
}