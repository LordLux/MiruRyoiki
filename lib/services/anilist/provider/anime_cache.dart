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
      final dir = miruRyoiokiSaveDirectory;
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
      final dir = miruRyoiokiSaveDirectory;
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
}
