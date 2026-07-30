
part of 'anilist_provider.dart';

extension AnilistProviderMutations on AnilistProvider {
  /// Load pending mutations from database
  Future<void> loadMutationsQueue() async {
    try {
      // Get database instance from context
      final library = Provider.of<Library>(rootNavigatorKey.currentContext!, listen: false);
      final mutationsDao = library.database.mutationsDao;

      // Load all mutations from database
      _pendingMutations = await mutationsDao.getAllMutations();

      logDebug('Loaded ${_pendingMutations.length} pending mutations from database');
    } catch (e) {
      logErr('Error loading mutations queue', e);
    }
  }

  /// Reload mutations from database
  Future<void> _reloadMutationsFromDatabase() async {
    try {
      final library = Provider.of<Library>(rootNavigatorKey.currentContext!, listen: false);
      final mutationsDao = library.database.mutationsDao;
      _pendingMutations = await mutationsDao.getAllMutations();
    } catch (e) {
      logErr('Error reloading mutations from database', e);
    }
  }

  /// Queue a mutation for later sync
  Future<void> queueMutation(String type, int mediaId, Map<String, dynamic> changes) async {
    try {
      final mutation = AnilistMutation(
        type: type,
        mediaId: mediaId,
        changes: changes,
      );

      // Add to database first
      final library = Provider.of<Library>(rootNavigatorKey.currentContext!, listen: false);
      final mutationsDao = library.database.mutationsDao;
      await mutationsDao.addMutation(mutation);

      // Reload from database to keep in-memory list synchronized
      await _reloadMutationsFromDatabase();

      // Apply to local cache to update UI
      _applyMutationToLocalCache(mutation);

      notifyListeners();
    } catch (e) {
      logErr('Error queueing mutation', e);
    }
  }

  // Helpers

  /// Find the list key and entry index for a given mediaId across all user lists
  (String listKey, int entryIndex)? _findEntryInLists(int mediaId) {
    for (final entry in _userLists.entries) {
      final idx = entry.value.entries.indexWhere((e) => e.mediaId == mediaId);
      if (idx >= 0) return (entry.key, idx);
    }
    return null;
  }

  /// Fetch a single media list entry from the AniList API and merge it into the local [_userLists] cache
  ///
  /// Returns the merged entry, or `null` when the entry doesn't exist
  Future<AnilistMediaListEntry?> fetchMediaListEntry(int mediaId) async {
    final userId = _currentUser?.id;
    if (userId == null) return null;

    try {
      // Fetch entry and score format in parallel
      final results = await Future.wait([
        _anilistService.getMediaListEntry(mediaId, userId),
        _anilistService.getScoreFormat(),
      ]);

      final json = results[0] as Map<String, dynamic>?;
      final formatStr = results[1] as String?;

      // Update score format if it changed
      if (formatStr != null) {
        final newFormat = AnilistScoreFormat.fromString(formatStr);
        if (newFormat != null && newFormat != scoreFormat && _currentUser?.userData != null) {
          _currentUser = _currentUser!.copyWith(
            userData: _currentUser!.userData!.copyWith(scoreFormat: newFormat),
          );
        }
      }

      if (json == null) return null;

      final entry = AnilistMediaListEntry.fromJson(json);
      _mergeEntryIntoLists(entry);
      _saveListsToCache();
      notifyListeners();
      return entry;
    } catch (e) {
      logErr('Error fetching single media list entry ($mediaId)', e);
      return null;
    }
  }

  /// Merge/upsert a single [entry] into the in-memory [_userLists]
  void _mergeEntryIntoLists(AnilistMediaListEntry entry) {
    final targetListKey = entry.status.name_;
    final found = _findEntryInLists(entry.mediaId);

    if (found != null) {
      final (oldListKey, idx) = found;
      if (oldListKey == targetListKey) {
        // Same list -> just update the entry
        _userLists[oldListKey]!.entries[idx] = entry;
      } else {
        // Status changed -> move to new list
        _userLists[oldListKey]!.entries.removeAt(idx);
        _userLists.putIfAbsent(
          targetListKey,
          () => AnilistUserList(entries: [], name: targetListKey, status: entry.status),
        );
        _userLists[targetListKey]!.entries.insert(0, entry);
      }
    } else {
      // New entry -> insert into target list (create the list if it doesn't exist yet; happens when the user has never had an entry in this status)
      _userLists.putIfAbsent(
        targetListKey,
        () => AnilistUserList(entries: [], name: targetListKey, status: entry.status),
      );
      _userLists[targetListKey]!.entries.insert(0, entry);
    }

    // Update custom-list memberships
    _syncCustomListMembership(entry);

    // Rebuild the cached lookup set since an entry was updated/added
    _rebuildAllUserAnilistIds();
  }

  /// Remove an entry from the local cache by mediaId
  void _removeEntryFromLists(int mediaId) {
    // Remove from standard/status lists
    final found = _findEntryInLists(mediaId);
    if (found != null) {
      final (listKey, idx) = found;
      _userLists[listKey]!.entries.removeAt(idx);
    }

    // Also remove from all custom lists
    for (final list in _userLists.values) {
      if (!list.isCustomList) continue;
      list.entries.removeWhere((e) => e.mediaId == mediaId);
    }

    // Rebuild the cached lookup set since an entry was removed
    _rebuildAllUserAnilistIds();
  }

  /// Synchronise custom-list membership for [entry] based on its customLists field
  void _syncCustomListMembership(AnilistMediaListEntry entry) {
    Map<String, dynamic>? customListsMap;
    if (entry.customLists != null) {
      try {
        customListsMap = jsonDecode(entry.customLists!) as Map<String, dynamic>?;
      } catch (_) {}
    }

    for (final mapEntry in _userLists.entries) {
      if (!mapEntry.value.isCustomList) continue;
      final key = mapEntry.key;
      final displayName = key.startsWith(AnilistService.statusListPrefixCustom) ? key.substring(AnilistService.statusListPrefixCustom.length) : key;

      final shouldBeInList = customListsMap != null && customListsMap[displayName] == true;
      final existingIdx = mapEntry.value.entries.indexWhere((e) => e.mediaId == entry.mediaId);

      if (shouldBeInList && existingIdx < 0) {
        mapEntry.value.entries.insert(0, entry);
      } else if (shouldBeInList && existingIdx >= 0) {
        mapEntry.value.entries[existingIdx] = entry;
      } else if (!shouldBeInList && existingIdx >= 0) {
        mapEntry.value.entries.removeAt(existingIdx);
      }
    }
  }

  /// Apply a mutation to the local cache
  void _applyMutationToLocalCache(AnilistMutation mutation) {
    final nowDate = now.millisecondsSinceEpoch ~/ 1000;

    switch (mutation.type) {
      case 'progress':
        final found = _findEntryInLists(mutation.mediaId);
        if (found == null) return;

        final (listKey, idx) = found;
        final entry = _userLists[listKey]!.entries[idx];
        final newProgress = mutation.changes['progress'] as int?;
        if (newProgress != null) _userLists[listKey]!.entries[idx] = entry.copyWith(progress: newProgress, updatedAt: nowDate);

      case 'status':
        final newStatus = (mutation.changes['status'] as String?)?.toListStatus();
        if (newStatus == null) return;

        final found = _findEntryInLists(mutation.mediaId);
        if (found == null) return;

        final (oldListKey, idx) = found;
        final entry = _userLists[oldListKey]!.entries[idx];
        final updatedEntry = entry.copyWith(status: newStatus, updatedAt: nowDate);

        // Move entry to the new status list
        final newListKey = newStatus.name_;
        _userLists[oldListKey]!.entries.removeAt(idx);
        if (_userLists.containsKey(newListKey)) _userLists[newListKey]!.entries.insert(0, updatedEntry);

      case 'score':
        final found = _findEntryInLists(mutation.mediaId);
        if (found == null) return;

        final (listKey, idx) = found;
        final entry = _userLists[listKey]!.entries[idx];
        final newScore = mutation.changes['score'] as int?;
        if (newScore != null) _userLists[listKey]!.entries[idx] = entry.copyWith(score: newScore, updatedAt: nowDate);

      case 'save_entry':
        final changes = mutation.changes;
        final found = _findEntryInLists(mutation.mediaId);
        if (found == null) return;

        final (oldListKey, idx) = found;
        final entry = _userLists[oldListKey]!.entries[idx];

        final newStatus = (changes['status'] as String?)?.toListStatus();
        final updatedEntry = entry.copyWith(
          status: newStatus,
          score: changes['score'] as int?,
          progress: changes['progress'] as int?,
          repeat: changes['repeat'] as int?,
          notes: changes['notes'] as String?,
          private: changes['private'] as bool?,
          hiddenFromStatusLists: changes['hiddenFromStatusLists'] as bool?,
          priority: changes['priority'] as int?,
          startedAt: changes['startedAt'] != null ? DateValue.fromJson(Map<String, dynamic>.from(changes['startedAt'])) : null,
          completedAt: changes['completedAt'] != null ? DateValue.fromJson(Map<String, dynamic>.from(changes['completedAt'])) : null,
          updatedAt: nowDate,
        );

        // Move to new list if status changed
        final newListKey = (newStatus ?? entry.status).name_;
        if (newListKey != oldListKey) {
          _userLists[oldListKey]!.entries.removeAt(idx);
          if (_userLists.containsKey(newListKey)) _userLists[newListKey]!.entries.insert(0, updatedEntry);
        } else {
          _userLists[oldListKey]!.entries[idx] = updatedEntry;
        }

      case 'delete_entry':
        final found = _findEntryInLists(mutation.mediaId);
        if (found == null) return;

        final (listKey, idx) = found;
        _userLists[listKey]!.entries.removeAt(idx);
    }

    _rebuildAllUserAnilistIds();
    _saveListsToCache();
  }

  Future<bool> updateProgress(int mediaId, int progress) => saveEntry(mediaId: mediaId, progress: progress);

  Future<bool> updateStatus(int mediaId, AnilistListApiStatus status) => saveEntry(mediaId: mediaId, status: status);

  Future<bool> updateScore(int mediaId, int score) => saveEntry(mediaId: mediaId, score: score);

  /// Comprehensive save of a media list entry
  ///
  /// Only non-null fields are sent
  ///
  /// Returns true if the save succeeded or was queued
  Future<bool> saveEntry({
    required int mediaId,
    AnilistListApiStatus? status,
    int? score,
    int? progress,
    int? repeat,
    int? priority,
    bool? private,
    String? notes,
    bool? hiddenFromStatusLists,
    List<String>? customLists,
    DateValue? startedAt,
    DateValue? completedAt,
  }) async {
    if (!_isOffline) {
      try {
        final responseJson = await _anilistService.saveMediaListEntry(
          mediaId: mediaId,
          status: status,
          scoreRaw: score,
          progress: progress,
          repeat: repeat,
          priority: priority,
          private: private,
          notes: notes,
          hiddenFromStatusLists: hiddenFromStatusLists,
          customLists: customLists,
          startedAt: startedAt,
          completedAt: completedAt,
        );
        if (responseJson != null) {
          // Merge the mutation response directly — authoritative and avoids any
          // AniList eventual-consistency window that would make a follow-up GET
          // return null for a brand-new entry
          try {
            final entry = AnilistMediaListEntry.fromJson(responseJson);
            _mergeEntryIntoLists(entry);
            _saveListsToCache();
            notifyListeners();
          } catch (e) {
            logErr('Error parsing SaveMediaListEntry response for $mediaId — falling back to refetch', e);
            await fetchMediaListEntry(mediaId);
          }
          return true;
        }
      } catch (e) {
        logErr('Error saving entry online', e);
      }
    }

    // Build changes map with only non-null fields
    final changes = <String, dynamic>{
      if (status != null) 'status': status.name_,
      if (score != null) 'score': score,
      if (progress != null) 'progress': progress,
      if (repeat != null) 'repeat': repeat,
      if (priority != null) 'priority': priority,
      if (private != null) 'private': private,
      if (notes != null) 'notes': notes,
      if (hiddenFromStatusLists != null) 'hiddenFromStatusLists': hiddenFromStatusLists,
      if (customLists != null) 'customLists': customLists,
      if (startedAt != null) 'startedAt': startedAt.toJson(),
      if (completedAt != null) 'completedAt': completedAt.toJson(),
    };

    await queueMutation('save_entry', mediaId, changes);
    return true;
  }

  /// Delete a media list entry
  Future<bool> deleteEntry({required int mediaId, required int entryId}) async {
    if (!_isOffline) {
      try {
        final success = await _anilistService.deleteMediaListEntry(entryId);
        if (success) {
          _removeEntryFromLists(mediaId);
          _saveListsToCache();
          notifyListeners();
          return true;
        }
      } catch (e) {
        logErr('Error deleting entry online', e);
      }
    }

    await queueMutation('delete_entry', mediaId, {'entryId': entryId});
    return true;
  }

  /// Toggle favourite status for an anime on AniList
  ///
  /// Returns `true` if the API call succeeded
  Future<bool> toggleFavourite(int animeId) async {
    if (_isOffline) return false;

    try {
      return await _anilistService.toggleFavourite(animeId);
    } catch (e) {
      logErr('Error toggling favourite for anime $animeId', e);
      return false;
    }
  }
}
