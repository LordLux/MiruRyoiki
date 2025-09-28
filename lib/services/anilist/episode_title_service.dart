import 'package:miruryoiki/utils/time.dart';
import 'package:provider/provider.dart';

import '../../models/anilist/mapping.dart';
import '../../models/episode.dart';
import '../../models/series.dart';
import '../../utils/logging.dart';
import '../../main.dart';
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
  Future<bool> fetchAndUpdateEpisodeTitles(Series series) async {
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
        anyUpdated |= await _updateEpisodesWithTitles(series, mapping, _titleCache[anilistId]!);
        continue;
      }

      try {
        final episodeTitles = await _anilistService.getEpisodeTitles(anilistId);

        if (episodeTitles.isNotEmpty) {
          // Cache the results
          _titleCache[anilistId] = episodeTitles;
          _cacheTimestamps[anilistId] = now;

          // Update episodes with fetched titles
          anyUpdated |= await _updateEpisodesWithTitles(series, mapping, episodeTitles);

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

  /// Update episodes in a series with the fetched titles
  Future<bool> _updateEpisodesWithTitles(Series series, AnilistMapping mapping, Map<int, String> episodeTitles) async {
    bool anyUpdated = false;

    logTrace('Applying episode titles for mapping: ${mapping.localPath.path}');

    // Get all episodes linked to this mapping using the new approach
    final linkedPaths = mapping.linkedEpisodePaths;
    logTrace('Found ${linkedPaths.length} linked episode paths for mapping');

    // Build episode-to-mapping relationship
    final linkedEpisodes = <Episode>[];
    for (final path in linkedPaths) {
      final episode = EpisodeNavigator.instance.findEpisodeByPath(path, series);
      if (episode != null) {
        linkedEpisodes.add(episode);
        logTrace('Linked episode: ${episode.path.path}');
      } else {
        logTrace('Could not find episode for path: ${path.path}');
      }
    }

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
