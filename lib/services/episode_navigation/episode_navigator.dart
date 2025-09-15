import '../../models/episode.dart';
import '../../models/series.dart';

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
      // seasons
      for (final season in series.seasons) {
        if (season.episodes.contains(episode)) return series;
      }
      // related media
      if (series.relatedMedia.contains(episode)) return series;
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

  /// Find the season that contains this episode
  Season? findSeasonForEpisode(Episode episode, Series series) {
    // ID-based lookup
    if (episode.id != null) {
      for (final season in series.seasons) {
        final found = season.getEpisodeById(episode.id!);
        if (found != null) return season;
      }
    }
    
    // Fallback to contains check
    for (final season in series.seasons) {
      if (season.episodes.contains(episode)) return season;
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
      ...series.seasons.expand((s) => s.episodes),
      ...series.relatedMedia,
    ];

    allEpisodes.sort((a, b) {
      final aNum = a.episodeNumber ?? 0;
      final bNum = b.episodeNumber ?? 0;
      return aNum.compareTo(bNum);
    });

    return allEpisodes;
  }

  /// Get season index (1-based) for an episode
  int? getSeasonIndexForEpisode(Episode episode, Series series) {
    final season = findSeasonForEpisode(episode, series);
    if (season == null) return null;
    
    final index = series.seasons.indexOf(season);
    return index == -1 ? null : index + 1;
  }

  /// Get episode position within its season (1-based)
  int? getEpisodePositionInSeason(Episode episode, Series series) {
    final season = findSeasonForEpisode(episode, series);
    if (season == null) return null;
    
    final index = season.episodes.indexOf(episode);
    return index == -1 ? null : index + 1;
  }

  /// Check if episode is the first in its series
  bool isFirstEpisode(Episode episode, Series series) {
    final episodeNumber = episode.episodeNumber;
    if (episodeNumber == null) return false;
    
    final allEpisodes = getAllEpisodesInSeries(series);
    return allEpisodes.isNotEmpty && 
           allEpisodes.first.episodeNumber == episodeNumber;
  }

  /// Check if episode is the last in its series
  bool isLastEpisode(Episode episode, Series series) {
    final episodeNumber = episode.episodeNumber;
    if (episodeNumber == null) return false;
    
    final allEpisodes = getAllEpisodesInSeries(series);
    return allEpisodes.isNotEmpty && 
           allEpisodes.last.episodeNumber == episodeNumber;
  }
}