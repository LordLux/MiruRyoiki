import '../../models/episode.dart';
import '../../models/season.dart';
import '../../models/series.dart';
import '../../utils/path.dart';

class EpisodeNavigator {
  static EpisodeNavigator? _instance;
  static EpisodeNavigator get instance => _instance ??= EpisodeNavigator._();
  EpisodeNavigator._();

  /// Find the series that contains this episode
  Series? findSeriesForEpisode(Episode episode, List<Series> allSeries) {
    // ID-based lookup
    if (episode.id != null) {
      for (final series in allSeries) {
        final found = series.getEpisodeById(episode.id!);
        if (found != null) return series;
      }
    }

    // Fallback to contains check (episodes without ID)
    for (final series in allSeries) {
      for (final collection in series.collections) {
        if (collection.episodes.contains(episode)) return series;
      }
    }
    return null;
  }

  /// Fast ID-based episode lookup across all series
  Episode? getEpisodeById(int episodeId, List<Series> allSeries) {
    for (final series in allSeries) {
      final episode = series.getEpisodeById(episodeId);
      if (episode != null) return episode;
    }
    return null;
  }

  /// Find the collection that contains this episode
  EpisodeCollection? findCollectionForEpisode(Episode episode, Series series) {
    // ID-based lookup
    if (episode.id != null) {
      for (final collection in series.collections) {
        final found = collection.getEpisodeById(episode.id!);
        if (found != null) return collection;
      }
    }

    // Fallback to contains check
    for (final collection in series.collections) {
      if (collection.episodes.contains(episode)) return collection;
    }
    return null;
  }

  /// Get episode by number within a series (searches all seasons)
  Episode? getEpisodeInSeries(Series series, int episodeNumber, {int? seasonNumber}) {
    return series.getEpisodeByNumber(episodeNumber, seasonNumber: seasonNumber);
  }

  /// Get next episode in series (by episode number)
  Episode? getNextEpisode(Episode currentEpisode, Series series) {
    final currentNumber = currentEpisode.episodeNumber;
    if (currentNumber == null) return null;

    return series.getEpisodeByNumber(currentNumber + 1);
  }

  /// Get previous episode in series (by episode number)
  Episode? getPreviousEpisode(Episode currentEpisode, Series series) {
    final currentNumber = currentEpisode.episodeNumber;
    if (currentNumber == null || currentNumber <= 1) return null;

    return series.getEpisodeByNumber(currentNumber - 1);
  }

  /// Get all episodes in series (ordered by episode number)
  List<Episode> getAllEpisodesInSeries(Series series) {
    final allEpisodes = <Episode>[
      ...series.collections.expand((c) => c.episodes),
    ];

    allEpisodes.sort((a, b) {
      final aNum = a.episodeNumber ?? 0;
      final bNum = b.episodeNumber ?? 0;
      return aNum.compareTo(bNum);
    });

    return allEpisodes;
  }

  /// Get collection index (1-based) for an episode
  int? getSeasonIndexForEpisode(Episode episode, Series series) {
    final collection = findCollectionForEpisode(episode, series);
    if (collection == null) return null;

    final index = series.collections.indexOf(collection);
    return index == -1 ? null : index + 1;
  }

  /// Get episode position within its season (1-based)
  int? getEpisodePositionInSeason(Episode episode, Series series) {
    final season = findCollectionForEpisode(episode, series);
    if (season == null) return null;

    final index = season.episodes.indexOf(episode);
    return index == -1 ? null : index + 1;
  }

  /// Check if episode is the first in its series
  bool isFirstEpisode(Episode episode, Series series) {
    final episodeNumber = episode.episodeNumber;
    if (episodeNumber == null) return false;

    final allEpisodes = getAllEpisodesInSeries(series);
    return allEpisodes.isNotEmpty && //
        allEpisodes.first.episodeNumber == episodeNumber;
  }

  /// Check if episode is the last in its series
  bool isLastEpisode(Episode episode, Series series) {
    final episodeNumber = episode.episodeNumber;
    if (episodeNumber == null) return false;

    final allEpisodes = getAllEpisodesInSeries(series);
    return allEpisodes.isNotEmpty && //
        allEpisodes.last.episodeNumber == episodeNumber;
  }

  /// Find episode by file path within a series
  Episode? findEpisodeByPath(PathString path, Series series) {
    for (final collection in series.collections) {
      for (final episode in collection.episodes) {
        if (episode.path.path == path.path) return episode;
      }
    }
    return null;
  }

  /// Find episodes by file paths within a series
  List<Episode> findEpisodesByPath(List<PathString> paths, Series series) {
    final foundEpisodes = <Episode>[];
    for (final collection in series.collections) {
      for (final episode in collection.episodes) {
        if (paths.any((path) => episode.path.path == path.path)) foundEpisodes.add(episode);
      }
    }
    return foundEpisodes;
  }

  bool? arePreviousEpisodesWatched(dynamic episode, Series series) {
    if (episode is int) {
      final ep = getEpisodeInSeries(series, episode);
      if (ep == null) return null;
      return arePreviousEpisodesWatched(ep, series);
    }
    if (episode is! Episode) return null;

    final episodeNumber = episode.episodeNumber;
    if (episodeNumber == null || episodeNumber <= 1) return null;

    final season = EpisodeNavigator.instance.findCollectionForEpisode(episode, series);
    for (final ep in season?.episodes ?? []) {
      if (ep.episodeNumber != null && ep.episodeNumber! < episodeNumber) {
        if (!ep.watched) return false;
      }
    }
    return true;
  }
}
