import 'package:miruryoiki/utils/time.dart';
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../models/anilist/mapping.dart';
import '../../models/series.dart';
import '../../utils/logging.dart';
import '../../main.dart';
import '../../utils/path.dart';
import '../episode_navigation/episode_navigator.dart';
import '../library/library_provider.dart';
import 'queries/anilist_service.dart';

/// Service for fetching and caching episode titles from AniList
class EpisodeTitleService {
  static EpisodeTitleService? _instance;
  static EpisodeTitleService get instance => _instance ??= EpisodeTitleService._();
  EpisodeTitleService._();

  final AnilistService _anilistService = AnilistService();

  /// Cache to avoid repeated API calls for the same anime
  final Map<int, Map<int, String>> _titleCache = {};
  final Map<int, DateTime> _cacheTimestamps = {};

  /// Cache validity period (1 week)
  static const Duration _cacheValidityPeriod = Duration(days: 7);

  /// Fetch episode titles for a series and update local episodes
  /// Returns the updated series with episode titles applied and saved to database
  @Deprecated('Use fetchAndUpdateEpisodeTitlesFromMapping instead')
  Future<bool> fetchAndUpdateEpisodeTitles(Series series) async {
    // Check if AniList episode titles are enabled
    if (!Manager.enableAnilistEpisodeTitles) {
      logTrace('AniList episode titles are disabled, skipping fetch for series: ${series.name}');
      return false;
    }

    if (!series.isLinked || series.anilistMappings.isEmpty) {
      logTrace('Series ${series.name} is not linked to AniList, skipping episode title fetch');
      return false;
    }

    bool anyUpdated = false;

    logTrace('Processing ${series.anilistMappings.length} AniList mappings for series: ${series.name}');

    // Fetch episode titles for each AniList mapping
    for (final mapping in series.anilistMappings) {
      final anilistId = mapping.anilistId;

      // Check cache first
      if (_isCacheValid(anilistId)) {
        logTrace('Using cached episode titles for AniList ID: $anilistId');
        anyUpdated |= _applyEpisodeTitlesToSeries(series, mapping, _titleCache[anilistId]!);
        continue;
      }

      try {
        final episodeTitles = await _anilistService.getEpisodeTitles(anilistId);

        if (episodeTitles.isNotEmpty) {
          // Cache the results
          _titleCache[anilistId] = episodeTitles;
          _cacheTimestamps[anilistId] = now;

          // Update episodes with fetched titles
          anyUpdated |= _applyEpisodeTitlesToSeries(series, mapping, episodeTitles);

          logInfo('Successfully fetched ${episodeTitles.length} episode titles for ${series.name}');
        } else {
          logTrace('No episode titles found for AniList ID: $anilistId');
        }
      } catch (e) {
        logErr('Failed to fetch episode titles for AniList ID: $anilistId', e);
      }
    }

    // If any episodes were updated, save the series to the database
    if (anyUpdated) {
      await _saveUpdatedSeriesToDatabase(series);
    }

    return anyUpdated;
  }

  /// Fetch episode titles for multiple series in batches and update local episodes
  /// Returns a map of series to whether they were updated
  @Deprecated('Use fetchAndUpdateEpisodeTitlesBatch instead')
  Future<Map<Series, bool>> fetchAndUpdateEpisodeTitlesBatch(List<Series> seriesList) async {
    // Check if AniList episode titles are enabled
    if (!Manager.enableAnilistEpisodeTitles) {
      logTrace('AniList episode titles are disabled, skipping batch fetch for ${seriesList.length} series');
      final Map<Series, bool> results = {};
      for (final series in seriesList) results[series] = false;
      return results;
    }

    final Map<Series, bool> results = {};

    final linkedSeries = seriesList.where((series) => series.isLinked && series.anilistMappings.isNotEmpty).toList();

    if (linkedSeries.isEmpty) {
      logTrace('No linked series found for batch episode title fetch');
      for (final series in seriesList) results[series] = false;
      return results;
    }

    // Collect all unique AniList ids that need fetching (not in cache)
    final Set<int> anilistIdsToFetch = {};
    final Map<int, Set<Series>> anilistIdToSeries = {};

    for (final series in linkedSeries) {
      for (final mapping in series.anilistMappings) {
        final anilistId = mapping.anilistId;

        anilistIdToSeries.putIfAbsent(anilistId, () => <Series>{}).add(series);

        // Check if we need to fetch this id
        if (!_isCacheValid(anilistId)) anilistIdsToFetch.add(anilistId);
      }
    }

    logInfo('Batch fetching episode titles for ${anilistIdsToFetch.length} AniList IDs affecting ${linkedSeries.length} series');

    // Fetch episode titles in batch
    Map<int, Map<int, String>> batchResults = {};
    if (anilistIdsToFetch.isNotEmpty) {
      try {
        batchResults = await _anilistService.getMultipleEpisodeTitles(anilistIdsToFetch.toList());

        // Cache the results
        for (final entry in batchResults.entries) {
          final anilistId = entry.key;
          final episodeTitles = entry.value;
          _titleCache[anilistId] = episodeTitles;
          _cacheTimestamps[anilistId] = now;
        }

        logInfo('Successfully batch fetched episode titles for ${batchResults.length} anime');
      } catch (e) {
        logErr('Failed to batch fetch episode titles', e);
      }
    }

    // Process each series
    for (final series in linkedSeries) {
      bool anyUpdated = false;

      for (final mapping in series.anilistMappings) {
        final anilistId = mapping.anilistId;

        // Get episode titles (from batch result, cache, or empty if failed)
        Map<int, String> episodeTitles = {};

        if (batchResults.containsKey(anilistId))
          episodeTitles = batchResults[anilistId]!;
        else //
        if (_isCacheValid(anilistId)) episodeTitles = _titleCache[anilistId]!;

        if (episodeTitles.isNotEmpty)
          anyUpdated |= _applyEpisodeTitlesToSeries(series, mapping, episodeTitles);
        else
          logTrace('No episode titles available for AniList ID: $anilistId');
      }

      // Save the series if any episodes were updated
      if (anyUpdated) await _saveUpdatedSeriesToDatabase(series);

      results[series] = anyUpdated;
    }

    // Add non-linked series as not updated
    for (final series in seriesList) {
      if (!results.containsKey(series)) results[series] = false;
    }

    logInfo('Batch episode title fetch completed: ${results.values.where((updated) => updated).length} series updated');
    return results;
  }

  /// Fetch episode titles for a series and update local episodes
  /// Returns true if any episodes were updated
  Future<(Series?, bool)> fetchAndUpdateEpisodeTitlesFromMapping(AnilistMapping mapping, {bool updateSeries = false}) async {
    // Check if AniList episode titles are enabled
    if (!Manager.enableAnilistEpisodeTitles) {
      logTrace('AniList episode titles are disabled, skipping fetch for series: ${mapping.title}');
      return (null, false);
    }

    logTrace('Processing ${mapping.title} AniList mapping for episode titles');

    final anilistId = mapping.anilistId;

    // Get episode titles
    Map<int, String> episodeTitles;

    // Check cache first
    if (_isCacheValid(anilistId)) {
      logTrace('Using cached episode titles for AniList ID: $anilistId');
      episodeTitles = _titleCache[anilistId]!;
    } else {
      try {
        episodeTitles = await _anilistService.getEpisodeTitles(anilistId);

        if (episodeTitles.isNotEmpty) {
          // Cache the results
          _titleCache[anilistId] = episodeTitles;
          _cacheTimestamps[anilistId] = now;
          logInfo('Successfully fetched ${episodeTitles.length} episode titles for ${mapping.title}');
        } else {
          logTrace('No episode titles found for AniList ID: $anilistId');
          return (null, false);
        }
      } catch (e) {
        logErr('Failed to fetch episode titles for AniList ID: $anilistId', e);
        return (null, false);
      }
    }

    if (!updateSeries) return (null, false);

    final library = Provider.of<Library>(rootNavigatorKey.currentContext!, listen: false);

    // Apply the episode titles to the actual series in state management
    final anyUpdated = library.applyFunctionToSeriesByAnilistId(anilistId, (series) {
      return _applyEpisodeTitlesToSeries(series, mapping, episodeTitles);
    });

    // If any episodes were updated, save the series to the database
    Series? series;
    if (anyUpdated == true) {
      series = library.getSeriesByAnilistId(anilistId);
      if (series != null) await library.updateSeries(series, invalidateCache: false);
    }

    return (series, anyUpdated ?? false);
  }

  /// Apply episode titles to a series and return true if any episodes were updated
  bool _applyEpisodeTitlesToSeries(Series series, AnilistMapping mapping, Map<int, String> episodeTitles) {
    bool anyUpdated = false;

    logTrace('Applying episode titles for mapping: ${mapping.localPath.path}');

    // Get all episodes linked to this mapping using the new approach
    final List<PathString> linkedPaths = mapping.linkedEpisodePaths;
    logTrace('Found ${linkedPaths.length} linked episode paths for mapping');

    // Build episode-to-mapping relationship
    final linkedEpisodes = EpisodeNavigator.instance.findEpisodesByPath(linkedPaths, series);
    logTrace('Mapped to ${linkedEpisodes.length} episodes in series: ${series.name}');

    // Apply episode titles only to linked episodes
    for (final episode in linkedEpisodes) {
      final episodeNumber = episode.episodeNumber;

      if (episodeNumber != null && episodeTitles.containsKey(episodeNumber)) {
        // Only apply title if we have a clear episode number match
        final newTitle = episodeTitles[episodeNumber]!;
        if (episode.anilistTitle != newTitle) {
          episode.anilistTitle = newTitle;
          anyUpdated = true;
          logTrace('Updated episode ${episode.episodeNumber} title: $newTitle');
        }
      } else {
        // Don't apply potentially wrong titles
        if (episode.anilistTitle != null) {
          episode.anilistTitle = null;
          anyUpdated = true;
          logTrace('Cleared uncertain AniList title for episode ${episode.episodeNumber ?? "?"} - will use filename instead');
        }
        logTrace('Skipping title update for episode ${episode.episodeNumber ?? "?"} - no clear episode number match (available: ${episodeTitles.keys.toList()})');
      }
    }

    logTrace('Updated ${linkedEpisodes.length} episodes for mapping ${mapping.anilistId}');
    return anyUpdated;
  }

  /// Check if cached data is still valid
  bool _isCacheValid(int anilistId) {
    if (!_titleCache.containsKey(anilistId) || !_cacheTimestamps.containsKey(anilistId)) {
      return false;
    }

    final cacheTime = _cacheTimestamps[anilistId]!;
    return DateTime.now().difference(cacheTime) < _cacheValidityPeriod;
  }

  /// Clear cache for a specific anime or all cache
  void clearCache([int? anilistId]) {
    if (anilistId != null) {
      _titleCache.remove(anilistId);
      _cacheTimestamps.remove(anilistId);
      logTrace('Cleared episode title cache for AniList ID: $anilistId');
    } else {
      _titleCache.clear();
      _cacheTimestamps.clear();
      logTrace('Cleared all episode title cache');
    }
  }

  /// Clear cache for a specific series
  void clearCacheForSeries(Series series) {
    if (!series.isLinked || series.anilistMappings.isEmpty) {
      logTrace('Series ${series.name} is not linked to AniList, nothing to clear');
      return;
    }

    for (final mapping in series.anilistMappings) clearCache(mapping.anilistId);

    logTrace('Cleared episode title cache for series: ${series.name}');
  }

  /// Get cached episode titles for an anime (if available)
  Map<int, String>? getCachedTitles(int anilistId) {
    if (_isCacheValid(anilistId)) {
      return Map.from(_titleCache[anilistId]!);
    }
    return null;
  }

  /// Force refresh episode titles for a series
  Future<bool> refreshEpisodeTitles(Series series) async {
    // Clear cache for all mappings in this series
    for (final mapping in series.anilistMappings) {
      clearCache(mapping.anilistId);
    }

    return await fetchAndUpdateEpisodeTitles(series);
  }

  /// Force refresh episode titles for multiple series using batch fetching
  Future<Map<Series, bool>> refreshEpisodeTitlesBatch(List<Series> seriesList) async {
    // Clear cache for all mappings in these series
    for (final series in seriesList) {
      for (final mapping in series.anilistMappings) clearCache(mapping.anilistId);
    }

    return await fetchAndUpdateEpisodeTitlesBatch(seriesList);
  }

  /// Save the updated series to database to persist episode title changes
  Future<void> _saveUpdatedSeriesToDatabase(Series series) async {
    try {
      // Access the library through the global navigator context
      if (rootNavigatorKey.currentContext != null) {
        final library = Provider.of<Library>(rootNavigatorKey.currentContext!, listen: false);
        await library.seriesDao.syncSeries(series);
        logTrace('Successfully saved episode title updates to database for series: ${series.name}');
      } else {
        logErr('Navigator context not available, cannot save episode title updates');
      }
    } catch (e) {
      logErr('Failed to save episode title updates to database for series: ${series.name}', e);
    }
  }
}
