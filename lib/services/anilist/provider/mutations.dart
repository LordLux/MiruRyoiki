part of 'anilist_provider.dart';

extension AnilistProviderMutations on AnilistProvider {
  /// Save pending mutations to disk
  Future<void> saveMutationsQueue() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$mutations_queue');

      final mutations = _pendingMutations.map((m) => m.toJson()).toList();
      await file.writeAsString(jsonEncode(mutations));

      logDebug('Saved ${mutations.length} pending mutations to disk');
    } catch (e) {
      logErr('Error saving mutations queue', e);
    }
  }

  /// Load pending mutations from disk
  Future<void> loadMutationsQueue() async {
    try {
      final dir = await miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$mutations_queue');

      if (!await file.exists()) {
        logDebug('No mutations queue file found');
        return;
      }

      final queueJson = await file.readAsString();
      final queueData = jsonDecode(queueJson) as List;

      _pendingMutations = queueData.map((item) => AnilistMutation.fromJson(item)).toList();

      logDebug('Loaded ${_pendingMutations.length} pending mutations from disk');
    } catch (e) {
      logErr('Error loading mutations queue', e);
    }
  }

  /// Queue a mutation for later sync
  Future<void> queueMutation(String type, int mediaId, Map<String, dynamic> changes) async {
    final mutation = AnilistMutation(
      type: type,
      mediaId: mediaId,
      changes: changes,
    );

    _pendingMutations.add(mutation);
    await saveMutationsQueue();

    _applyMutationToLocalCache(mutation);

    notifyListeners();
  }

  /// Apply a mutation to the local cache
  void _applyMutationToLocalCache(AnilistMutation mutation) {
    for (final list in _userLists.values) {
      final entryIndex = list.entries.indexWhere((e) => e.mediaId == mutation.mediaId);
      if (entryIndex >= 0 && entryIndex < list.entries.length) {
        final entry = list.entries[entryIndex];
        final nowDate = now.millisecondsSinceEpoch ~/ 1000;

        switch (mutation.type) {
          // TODO use enum for mutation types
          case 'progress':
            final newProgress = mutation.changes['progress'] as int?;
            if (newProgress != null) {
              final updatedEntry = entry.copyWith(
                progress: newProgress,
                updatedAt: nowDate,
              );

              list.entries[entryIndex] = updatedEntry;
            }
            break;

          case 'status':
            final newStatus = (mutation.changes['status'] as String?)?.toListStatus();
            if (newStatus != null) {
              final updatedEntry = entry.copyWith(
                status: newStatus,
                updatedAt: nowDate,
              );

              list.entries[entryIndex] = updatedEntry;
            }
            break;

          case 'score':
            final newScore = mutation.changes['score'] as int?;
            if (newScore != null) {
              final updatedEntry = entry.copyWith(
                score: newScore,
                updatedAt: nowDate,
              );

              list.entries[entryIndex] = updatedEntry;
            }
            break;

          // TODO Handle other mutation types
        }

        _saveListsToCache();
        return;
      }
    }
  }

  /// Update progress for an anime (works online or offline)
  Future<bool> updateProgress(int mediaId, int progress) async {
    if (!_isOffline) {
      try {
        // Try to update online
        final success = await _anilistService.updateProgress(mediaId, progress);
        if (success) {
          // Update local cache and return
          await refreshUserLists();
          return true;
        }
      } catch (e) {
        logErr('Error updating progress online', e);
        // Fall through to offline queue
      }
    }

    // Queue for later if offline or online update failed
    await queueMutation('progress', mediaId, {'progress': progress});
    return true; // Return true since we've queued it
  }

  /// Update status for an anime (works online or offline)
  Future<bool> updateStatus(int mediaId, AnilistListStatus status) async {
    if (!_isOffline) {
      try {
        // Try to update online
        final success = await _anilistService.updateStatus(mediaId, status);
        if (success) {
          // Update local cache and return
          await refreshUserLists();
          return true;
        }
      } catch (e) {
        logErr('Error updating status online', e);
        // Fall through to offline queue
      }
    }

    // Queue for later if offline or online update failed
    await queueMutation('status', mediaId, {'status': status.name_});
    return true; // Return true since we've queued it
  }

  /// Update score for an anime (works online or offline)
  Future<bool> updateScore(int mediaId, int score) async {
    if (!_isOffline) {
      try {
        final success = await _anilistService.updateScore(mediaId, score);
        if (success) {
          await refreshUserLists();
          return true;
        }
      } catch (e) {
        logErr('Error updating score online', e);
      }
    }

    await queueMutation('score', mediaId, {'score': score});
    return true;
  }
}