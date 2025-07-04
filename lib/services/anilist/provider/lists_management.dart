part of 'anilist_provider.dart';

extension AnilistProviderListsManagement on AnilistProvider {
  /// Refresh user lists
  Future<void> refreshUserLists() async {
    if (!isLoggedIn) return;

    final startTime = DateTime.now().millisecondsSinceEpoch;

    snackBar(
      'Refreshing user lists...',
      severity: InfoBarSeverity.info,
    );

    _isLoading = true;
    notifyListeners();

    try {
      final isOnline = await _checkConnectivity();

      if (isOnline) {
        await _loadUserLists();
        // Cache after refresh
        await _saveListsToCache();
      } else {
        // Try loading from cache if offline
        if (!await _loadListsFromCache()) //
          logWarn('Failed to refresh lists: Offline and no cache available');
      }
    } catch (e) {
      snackBar(
        'Failed to refresh user lists: ${e.toString()}',
        severity: InfoBarSeverity.error,
        exception: e,
      );
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    final endTime = DateTime.now().millisecondsSinceEpoch;
    if (endTime - startTime < 1000) await Future.delayed(Duration(milliseconds: 1000 - (endTime - startTime))); // Ensure at least 1 second delay
    
    snackBar(
      'User lists refreshed successfully',
      severity: InfoBarSeverity.success,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Save user lists to local cache
  Future<void> _saveListsToCache() async {
    if (!isLoggedIn || _userLists.isEmpty) return;

    try {
      final dir = miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$lists_cache.json');

      final Map<String, dynamic> cache = {
        'timestamp': now.toIso8601String(),
        'userId': _currentUser?.id,
        'lists': _userLists.map((key, list) {
          return MapEntry(key, {
            'name': list.name,
            'status': list.status?.name_,
            'isCustomList': list.isCustomList,
            'entries': list.entries.map((entry) => entry.toJson()).toList(),
          });
        }),
      };

      await file.writeAsString(jsonEncode(cache));
      _lastListsCacheTime = now;
      logDebug('Anilist lists cached successfully');
    } catch (e) {
      logErr('Error caching Anilist lists', e);
    }
  }

  /// Load user lists from local cache
  Future<bool> _loadListsFromCache() async {
    try {
      final dir = miruRyoiokiSaveDirectory;
      final file = File('${dir.path}/$lists_cache.json');

      if (!await file.exists()) {
        logDebug('No Anilist lists cache found');
        return false;
      }

      final cacheJson = await file.readAsString();
      final cache = jsonDecode(cacheJson) as Map<String, dynamic>;

      // Check if cache is for current user
      if (cache['userId'] != _currentUser?.id) {
        logDebug('Cached lists belong to different user');
        return false;
      }

      _lastListsCacheTime = DateTime.parse(cache['timestamp']);

      final cachedLists = cache['lists'] as Map<String, dynamic>;
      final Map<String, AnilistUserList> parsedLists = {};

      cachedLists.forEach((key, value) {
        final entries = (value['entries'] as List).map((e) => AnilistMediaListEntry.fromJson(e)).toList();

        parsedLists[key] = AnilistUserList(
          entries: entries,
          name: value['name'],
          status: value['status']?.toString().toListStatus(),
        );
      });

      _userLists = parsedLists;
      logDebug('Loaded Anilist lists from cache ($_lastListsCacheTime)');
      notifyListeners();
      return true;
    } catch (e) {
      logErr('Error loading Anilist lists from cache', e);
      return false;
    }
  }
}
