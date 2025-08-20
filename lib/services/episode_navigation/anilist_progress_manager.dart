// lib/services/episode_navigation/anilist_progress_manager.dart
import '../../models/anilist/mapping.dart';
import '../../models/episode.dart';
import '../../models/series.dart';
import '../anilist/provider/anilist_provider.dart';
import 'episode_navigator.dart';

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

  /// Get watched episodes from Anilist progress (max progress from all mappings)
  int getWatchedEpisodesFromAnilist(Series series, AnilistProvider provider) {
    if (!series.isLinked) return 0;

    final entries = series.getMediaListEntries(provider);
    int maxProgress = 0;

    for (final entry in entries.values) {
      if (entry?.progress != null && entry!.progress! > maxProgress) {
        maxProgress = entry.progress!;
      }
    }

    return maxProgress;
  }

  /// Get series progress as percentage (0.0 - 1.0)
  double getSeriesProgress(Series series, AnilistProvider provider) {
    final total = getTotalEpisodesFromAnilist(series);
    if (total == 0) return 0.0;

    final watched = getWatchedEpisodesFromAnilist(series, provider);
    return watched / total;
  }

  /// Get the episode number the user should watch next
  int? getNextEpisodeToWatch(Series series, AnilistProvider provider) {
    final lastWatched = getWatchedEpisodesFromAnilist(series, provider);
    final total = getTotalEpisodesFromAnilist(series);

    if (lastWatched >= total) return null; // Series completed
    return lastWatched + 1;
  }

  /// Get last watched episode based on Anilist progress
  Episode? getLastWatchedEpisode(Series series, AnilistProvider provider) {
    final lastWatchedNumber = getWatchedEpisodesFromAnilist(series, provider);
    if (lastWatchedNumber == 0) return null;

    return EpisodeNavigator.instance.getEpisodeInSeries(series, lastWatchedNumber);
  }

  /// Get next episode to watch based on Anilist progress
  Episode? getNextEpisodeToWatchEpisode(Series series, AnilistProvider provider) {
    final nextNumber = getNextEpisodeToWatch(series, provider);
    if (nextNumber == null) return null;

    return EpisodeNavigator.instance.getEpisodeInSeries(series, nextNumber);
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
    final watchedCount = getWatchedEpisodesFromAnilist(series, provider);
    if (watchedCount == 0) return [];

    final allEpisodes = EpisodeNavigator.instance.getAllEpisodesInSeries(series);
    return allEpisodes.where((episode) {
      final episodeNumber = episode.resolvedEpisodeNumber;
      return episodeNumber != null && episodeNumber <= watchedCount;
    }).toList();
  }

  /// Get remaining episodes to watch
  List<Episode> getRemainingEpisodes(Series series, AnilistProvider provider) {
    final watchedCount = getWatchedEpisodesFromAnilist(series, provider);

    final allEpisodes = EpisodeNavigator.instance.getAllEpisodesInSeries(series);
    return allEpisodes.where((episode) {
      final episodeNumber = episode.resolvedEpisodeNumber;
      return episodeNumber != null && episodeNumber > watchedCount;
    }).toList();
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
      'nextEpisodeNumber': getNextEpisodeToWatch(series, provider),
    };
  }
}
