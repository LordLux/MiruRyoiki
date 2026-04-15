// lib/services/episode_navigation/anilist_progress_manager.dart
import 'package:collection/collection.dart';

import '../../models/anilist/mapping.dart';
import '../../models/episode.dart';
import '../../models/season.dart';
import '../../models/series.dart';
import '../anilist/provider/anilist_provider.dart';

class AnilistProgressManager {
  static AnilistProgressManager? _instance;
  static AnilistProgressManager get instance => _instance ??= AnilistProgressManager._();
  AnilistProgressManager._();

  /// Get total episodes from Anilist data (sum of all mappings)
  int getTotalEpisodesFromAnilist(Series series) {
    if (!series.isLinked) return 0;

    int total = 0;
    for (final mapping in series.anilistMappings) {
      final episodes = mapping.anilistData?.episodes;
      if (episodes != null) total += episodes;
    }
    return total;
  }

  /// Get total episodes, falling back to local count if not linked or no episodes
  int getTotalEpisodes(Series series) {
    if (series.isLinked) {
      final anilistTotal = getTotalEpisodesFromAnilist(series);
      if (anilistTotal > 0) return anilistTotal;
    }
    return series.localTotalEpisodes;
  }

  /// Get watched episodes from Anilist progress (sum of progress from all mappings)
  int getWatchedEpisodesFromAnilist(Series series, AnilistProvider provider) {
    if (!series.isLinked) return 0;

    final entries = provider.getMediaListEntries(series);
    int totalProgress = 0;

    for (final entry in entries.values) {
      if (entry?.progress != null) {
        totalProgress += entry!.progress!;
      }
    }

    return totalProgress;
  }

  /// Get watched episodes, falling back to local count if not linked
  int getWatchedEpisodes(Series series, AnilistProvider provider) {
    if (series.isLinked) {
      return getWatchedEpisodesFromAnilist(series, provider);
    }
    return series.localWatchedEpisodes;
  }

  /// Get series progress as percentage (0.0 - 1.0)
  double getSeriesProgress(Series series, AnilistProvider provider) {
    final total = getTotalEpisodesFromAnilist(series);
    if (total == 0) return 0.0;

    final watched = getWatchedEpisodesFromAnilist(series, provider);
    return (watched / total).clamp(0.0, 1.0);
  }

  /// Get the next episode number to watch (cumulative across all mappings)
  int? getNextEpisodeNumber(Series series, AnilistProvider provider) {
    final lastWatched = getWatchedEpisodesFromAnilist(series, provider);
    final total = getTotalEpisodesFromAnilist(series);

    if (lastWatched >= total) return null; // Series completed
    return lastWatched + 1; // Next episode
  }

  /// Get last watched episode based on Anilist progress (per-mapping aware)
  Episode? getLastWatchedEpisode(Series series, AnilistProvider provider) {
    if (!series.isLinked) return null;

    final orderedMappings = _getOrderedMappings(series);
    final entries = provider.getMediaListEntries(series);
    Episode? lastWatched;
    int absoluteOffset = 0;

    for (final (mapping, season) in orderedMappings) {
      final progress = entries[mapping.anilistId]?.progress ?? 0;
      final totalEps = mapping.anilistData?.episodes ?? 0;

      if (progress > 0) {
        Episode? ep;
        if (season != null) {
          ep = _findEpisodeInCollection(season, progress, absoluteOffset);
        } else {
          ep = _findEpisodeForFileMapping(mapping, series);
        }
        if (ep != null) lastWatched = ep;
      }

      absoluteOffset += totalEps;
    }

    return lastWatched;
  }

  /// Get the next episode after the last watched (per-mapping aware, ignores local progress)
  Episode? getNextEpisode(Series series, AnilistProvider provider) {
    if (!series.isLinked) return null;

    final orderedMappings = _getOrderedMappings(series);
    final entries = provider.getMediaListEntries(series);
    int absoluteOffset = 0;

    for (final (mapping, season) in orderedMappings) {
      final progress = entries[mapping.anilistId]?.progress ?? 0;
      final totalEpisodes = mapping.anilistData?.episodes ?? 0;

      // If this mapping is not complete, return next episode
      if (totalEpisodes == 0 || progress < totalEpisodes) {
        if (season != null) {
          final nextEp = _findEpisodeInCollection(season, progress + 1, absoluteOffset);
          if (nextEp != null) return nextEp;
        } else if (progress == 0) {
          final ep = _findEpisodeForFileMapping(mapping, series);
          if (ep != null) return ep;
        }
      }

      absoluteOffset += totalEpisodes;
    }

    return null;
  }

  /// Get next episode to watch considering local watch progress and cross-season transitions
  ///
  /// Handles both per-season numbering (Episode 1 of Season 2), and absolute numbering (Episode 13 for Season 2 after a 12-episode Season 1) by trying per-season first, then falling back to absolute.
  Episode? getNextEpisodeToWatch(Series series, AnilistProvider provider) {
    if (!series.isLinked) return null;

    final orderedMappings = _getOrderedMappings(series);
    final entries = provider.getMediaListEntries(series);
    int absoluteOffset = 0;

    for (final (mapping, season) in orderedMappings) {
      final progress = entries[mapping.anilistId]?.progress ?? 0;
      final totalEpisodes = mapping.anilistData?.episodes ?? 0;

      // Check if the last Anilist-tracked episode has incomplete local progress
      if (progress > 0) {
        Episode? lastWatchedEp;
        if (season != null) {
          lastWatchedEp = _findEpisodeInCollection(season, progress, absoluteOffset);
        } else {
          lastWatchedEp = _findEpisodeForFileMapping(mapping, series);
        }

        if (lastWatchedEp != null && !lastWatchedEp.watched && lastWatchedEp.progress > 0) {
          return lastWatchedEp;
        }
      }

      // If this mapping is not complete, return next episode
      if (totalEpisodes == 0 || progress < totalEpisodes) {
        if (season != null) {
          final nextEp = _findEpisodeInCollection(season, progress + 1, absoluteOffset);
          if (nextEp != null) return nextEp;
        } else if (progress == 0) {
          final ep = _findEpisodeForFileMapping(mapping, series);
          if (ep != null) return ep;
        }
      }

      // Mapping is complete or episode not found locally; advance to next season
      absoluteOffset += totalEpisodes;
    }

    return null;
  }

  /// Get progress for specific mapping
  int getProgressForMapping(AnilistMapping mapping, AnilistProvider provider) {
    final entries = provider.userLists.values.expand((list) => list.entries).where((entry) => entry.mediaId == mapping.anilistId);

    return entries.isEmpty ? 0 : entries.first.progress ?? 0;
  }

  /// Check if series is completed according to Anilist
  bool isSeriesCompleted(Series series, AnilistProvider provider) {
    final watched = getWatchedEpisodesFromAnilist(series, provider);
    final total = getTotalEpisodesFromAnilist(series);
    return total > 0 && watched >= total;
  }

  /// Get all episodes that should be marked as watched according to Anilist progress
  List<Episode> getWatchedEpisodesFromProgress(Series series, AnilistProvider provider) {
    if (!series.isLinked) return [];

    final orderedMappings = _getOrderedMappings(series);
    final entries = provider.getMediaListEntries(series);
    final result = <Episode>[];
    int absoluteOffset = 0;

    for (final (mapping, season) in orderedMappings) {
      final progress = entries[mapping.anilistId]?.progress ?? 0;
      final totalEps = mapping.anilistData?.episodes ?? 0;

      if (season != null && progress > 0) {
        for (final episode in season.episodes) {
          final epNum = episode.episodeNumber;
          if (epNum == null) continue;
          // Per-season numbering: episode number within the mapping's range
          if (epNum <= progress) {
            result.add(episode);
          } else if (absoluteOffset > 0 && epNum > absoluteOffset && epNum <= absoluteOffset + progress) {
            // Absolute numbering: episode uses absolute numbers
            result.add(episode);
          }
        }
      } else if (season == null && progress > 0) {
        final ep = _findEpisodeForFileMapping(mapping, series);
        if (ep != null) result.add(ep);
      }

      absoluteOffset += totalEps;
    }

    return result;
  }

  /// Get remaining episodes to watch
  List<Episode> getRemainingEpisodes(Series series, AnilistProvider provider) {
    if (!series.isLinked) return [];

    final orderedMappings = _getOrderedMappings(series);
    final entries = provider.getMediaListEntries(series);
    final result = <Episode>[];
    int absoluteOffset = 0;

    for (final (mapping, season) in orderedMappings) {
      final progress = entries[mapping.anilistId]?.progress ?? 0;
      final totalEps = mapping.anilistData?.episodes ?? 0;

      if (season != null) {
        for (final episode in season.episodes) {
          final epNum = episode.episodeNumber;
          if (epNum == null) continue;
          final isWatchedPerSeason = epNum <= progress;
          final isWatchedAbsolute = absoluteOffset > 0 && epNum > absoluteOffset && epNum <= absoluteOffset + progress;
          if (!isWatchedPerSeason && !isWatchedAbsolute) {
            result.add(episode);
          }
        }
      } else if (progress == 0) {
        final ep = _findEpisodeForFileMapping(mapping, series);
        if (ep != null) result.add(ep);
      }

      absoluteOffset += totalEps;
    }

    return result;
  }

  /// Get progress details for debugging
  /// ```dart
  /// {
  ///   int    totalEpisodes:      "Total episodes in series"
  ///   int    watchedEpisodes:    "Watched episodes according to Anilist"
  ///   double progressPercentage: "Progress percentage (0.0 - 1.0)"
  ///   bool   isCompleted:        "Whether the series is completed"
  ///   int    mappingsCount:      "Number of Anilist mappings for the series"
  ///   int?   nextEpisodeNumber:  "Next episode number to watch"
  /// }
  /// ```
  Map<String, dynamic> getProgressDetails(Series series, AnilistProvider provider) {
    final total = getTotalEpisodesFromAnilist(series);
    final watched = getWatchedEpisodesFromAnilist(series, provider);
    final percentage = getSeriesProgress(series, provider);

    return {
      'totalEpisodes': total,
      'watchedEpisodes': watched,
      'progressPercentage': percentage,
      'isCompleted': isSeriesCompleted(series, provider),
      'mappingsCount': series.anilistMappings.length,
      'nextEpisodeNumber': getNextEpisodeNumber(series, provider),
    };
  }

  /// Build an ordered list of (mapping, season?) pairs, sorted by season number
  /// 
  /// Season-matched mappings come first (sorted by season number), then file-based (unmapped) mappings at the end.
  List<(AnilistMapping, EpisodeCollection?)> _getOrderedMappings(Series series) {
    final matched = <(AnilistMapping, EpisodeCollection, int?)>[];
    final unmatched = <AnilistMapping>[];

    for (final mapping in series.anilistMappings) {
      final collection = series.collections.firstWhereOrNull(
        (c) => c.path.path == mapping.localPath.path,
      );

      if (collection != null) {
        final seasonNum = collection is Season ? collection.seasonNumber : null;
        matched.add((mapping, collection, seasonNum));
      } else {
        unmatched.add(mapping);
      }
    }

    // Sort matched mappings by season number (nulls at end)
    matched.sort((a, b) {
      final aNum = a.$3;
      final bNum = b.$3;
      if (aNum == null && bNum == null) return 0;
      if (aNum == null) return 1;
      if (bNum == null) return -1;
      return aNum.compareTo(bNum);
    });

    final result = <(AnilistMapping, EpisodeCollection?)>[];
    for (final (mapping, collection, _) in matched) {
      result.add((mapping, collection));
    }
    for (final mapping in unmatched) {
      result.add((mapping, null));
    }
    return result;
  }

  /// Try to find an episode by number within a collection
  ///
  /// Handles both per-season and absolute numbering schemes
  Episode? _findEpisodeInCollection(EpisodeCollection collection, int episodeNumber, int absoluteOffset) {
    // Try per-collection numbering first
    final perCollection = collection.getEpisodeByNumber(episodeNumber);
    if (perCollection != null) return perCollection;

    // Fallback: try absolute numbering
    if (absoluteOffset > 0) {
      return collection.getEpisodeByNumber(absoluteOffset + episodeNumber);
    }

    return null;
  }

  /// Find an episode for a file-based mapping (movies/OVAs) by matching path
  Episode? _findEpisodeForFileMapping(AnilistMapping mapping, Series series) {
    for (final collection in series.collections) {
      for (final episode in collection.episodes) {
        if (episode.path.path == mapping.localPath.path) return episode;
      }
    }
    return null;
  }
}

