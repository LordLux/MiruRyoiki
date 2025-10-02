part of 'anilist_provider.dart';

extension AnilistProviderAnimeCache on AnilistProvider {
  /// Get anime details, using cache if available
  Future<AnilistAnime?> getAnimeDetails(int id, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh && _animeCache.containsKey(id)) //
      return _animeCache[id];

    if (!_isOffline) {
      try {
        final anime = await _anilistService.getAnimeDetails(id);
        if (anime != null) {
          _animeCache[id] = anime;
          // Save to disk periodically
          saveAnimeCacheToStorage();
        }
        return anime;
      } catch (e) {
        logErr('Error fetching anime details online', e);
        // Continue with cached version if available
      }
    }

    // If we're offline or the fetch failed, return cached version
    return _animeCache[id];
  }

  /// Search for anime by title
  Future<List<AnilistAnime>> searchAnime(String query) async {
    final results = await _anilistService.searchAnime(query);

    // Cache results
    for (final anime in results) {
      _animeCache[anime.id] = anime;
    }

    return results;
  }

  /// Save anime details to persistent cache
  Future<void> saveAnimeCacheToStorage() async {
    try {
      final dir = miruRyoikiSaveDirectory;
      final file = File('${dir.path}/$anime_cache');

      // Sort by MRU and limit to maxCachedAnimeCount
      final sortedCache = Map.fromEntries(_animeCache.entries.take(maxCachedAnimeCount).map((e) => MapEntry(e.key.toString(), {
            'data': e.value.toJson(),
            'timestamp': now.toIso8601String(),
          })));

      await file.writeAsString(jsonEncode(sortedCache));
      logDebug('Cached ${sortedCache.length} anime details to disk');
    } catch (e) {
      logErr('Error caching anime details', e);
    }
  }

  /// Load anime details from persistent cache
  Future<void> loadAnimeCacheFromStorage() async {
    try {
      final dir = miruRyoikiSaveDirectory;
      final file = File('${dir.path}/$anime_cache');

      if (!await file.exists()) {
        logDebug('No anime cache file found');
        return;
      }

      final cacheJson = await file.readAsString();
      final cache = jsonDecode(cacheJson) as Map<String, dynamic>;

      for (final entry in cache.entries) {
        try {
          final animeId = int.parse(entry.key);
          final data = entry.value as Map<String, dynamic>;
          final animeData = data['data'] as Map<String, dynamic>;
          final timestamp = DateTime.parse(data['timestamp'] as String);

          // Check if cache is still valid
          if (now.difference(timestamp) <= animeCacheValidityPeriod) {
            _animeCache[animeId] = AnilistAnime.fromJson(animeData);
          }
        } catch (e) {
          logErr('Error parsing cached anime: ${entry.key}', e);
        }
      }

      logDebug('Loaded ${_animeCache.length} anime from cache');
    } catch (e, st) {
      logErr('Error loading anime cache', e, st);
    }
  }

  /// Get upcoming episodes for a list of anime IDs
  Future<Map<int, AiringEpisode?>> getUpcomingEpisodes(List<int> animeIds) async {
    if (!isLoggedIn) return {};
    
    // If there's already a request in progress, wait for it instead of making a new one
    if (_currentUpcomingEpisodesRequest != null) {
      logTrace('Waiting for existing upcoming episodes request to complete');
      return await _currentUpcomingEpisodesRequest!;
    }
    
    // Check if we have cached data and it's still valid
    final bool hasCachedData = _upcomingEpisodesCache.isNotEmpty;
    final bool cacheIsValid = _lastUpcomingEpisodesFetch != null &&
        now.difference(_lastUpcomingEpisodesFetch!) < upcomingEpisodesCacheValidityPeriod;
    
    // If cache is valid and contains data for requested IDs, return it
    if (cacheIsValid && hasCachedData) {
      final bool hasAllRequestedIds = animeIds.every((id) => _upcomingEpisodesCache.containsKey(id));
      if (hasAllRequestedIds) {
        logTrace('Returning cached upcoming episodes data');
        return Map.fromEntries(
          animeIds.map((id) => MapEntry(id, _upcomingEpisodesCache[id]))
        );
      }
    }
    
    // If offline, return cached data (even if expired)
    if (_isOffline && hasCachedData) {
      logTrace('Offline: returning cached upcoming episodes data');
      return Map.fromEntries(
        animeIds.map((id) => MapEntry(id, _upcomingEpisodesCache[id]))
      );
    }
    
    try {
      logTrace('Fetching fresh upcoming episodes data from API');
      
      // Create and store the request to prevent duplicates
      _currentUpcomingEpisodesRequest = _anilistService.getUpcomingEpisodes(animeIds);
      final freshData = await _currentUpcomingEpisodesRequest!;
      
      // Update cache with fresh data
      _upcomingEpisodesCache.addAll(freshData);
      _lastUpcomingEpisodesFetch = now;
      
      // Clean old entries that weren't requested (keep cache size manageable)
      final requestedIds = animeIds.toSet();
      _upcomingEpisodesCache.removeWhere((id, _) => !requestedIds.contains(id));
      
      return freshData;
    } catch (e) {
      logErr('Error fetching upcoming episodes', e);
      
      // If we have cached data, return it even if fetch failed
      if (hasCachedData) {
        logWarn('API failed: returning cached upcoming episodes data');
        return Map.fromEntries(
          animeIds.map((id) => MapEntry(id, _upcomingEpisodesCache[id]))
        );
      }
      
      return {};
    } finally {
      // Clear the current request to allow new ones
      _currentUpcomingEpisodesRequest = null;
    }
  }

  /// Get upcoming episodes with immediate cache return
  /// Returns cached data immediately and optionally refreshes in background
  Map<int, AiringEpisode?> getCachedUpcomingEpisodes(List<int> animeIds, {bool refreshInBackground = true}) {
    final cachedResults = Map<int, AiringEpisode?>.fromEntries(
      animeIds.map((id) => MapEntry(id, _upcomingEpisodesCache[id]))
    );
    
    // Check if we should refresh in background
    if (refreshInBackground && isLoggedIn && !_isOffline && _currentUpcomingEpisodesRequest == null) {
      final bool cacheIsStale = _lastUpcomingEpisodesFetch == null ||
          now.difference(_lastUpcomingEpisodesFetch!) > upcomingEpisodesCacheValidityPeriod;
      
      if (cacheIsStale) {
        // Refresh in background without awaiting
        getUpcomingEpisodes(animeIds).catchError((e) {
          logErr('Background refresh of upcoming episodes failed', e);
          return <int, AiringEpisode?>{};
        });
      }
    }
    
    return cachedResults;
  }
}
