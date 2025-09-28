import '../../models/series.dart';
import '../../models/ui_episode.dart';
import '../../models/episode.dart';
import '../../utils/logging.dart';

/// Service for creating UIEpisode lists that combine downloaded, available, and future episodes
class UIEpisodeService {
  static UIEpisodeService? _instance;
  static UIEpisodeService get instance => _instance ??= UIEpisodeService._();
  UIEpisodeService._();

  /// Generate a complete list of UIEpisodes for a series
  /// This includes downloaded episodes, episodes available for download, and future episodes
  List<UIEpisode> generateUIEpisodes(Series series) {
    final List<UIEpisode> uiEpisodes = [];
    
    if (!series.isLinked) {
      // If series is not linked to AniList, only show local episodes
      return _getLocalEpisodesAsUI(series);
    }

    // Get total episode count from AniList
    final totalEpisodesFromAnilist = _getTotalEpisodesFromAnilist(series);
    if (totalEpisodesFromAnilist == 0) {
      // Fallback to local episodes if no AniList data
      return _getLocalEpisodesAsUI(series);
    }

    // Get all local episodes mapped by episode number
    final localEpisodeMap = _getLocalEpisodeMap(series);
    
    // Generate UIEpisodes for each episode number from 1 to total
    for (int episodeNumber = 1; episodeNumber <= totalEpisodesFromAnilist; episodeNumber++) {
      final localEpisode = localEpisodeMap[episodeNumber];
      
      if (localEpisode != null) {
        // Episode is downloaded locally
        uiEpisodes.add(UIEpisode.fromLocalEpisode(localEpisode));
      } else {
        // Episode is not downloaded - determine if it's available or future
        // For now, we'll assume episodes are available (this could be enhanced with airing data)
        uiEpisodes.add(UIEpisode.available(
          episodeNumber: episodeNumber,
          anilistTitle: _getEpisodeTitleFromCache(episodeNumber), // Could come from episode title service cache
        ));
      }
    }

    // Add any local episodes that exceed the AniList count (extras, OVAs, etc.)
    for (final episode in localEpisodeMap.values) {
      final episodeNumber = episode.episodeNumber;
      if (episodeNumber != null && episodeNumber > totalEpisodesFromAnilist) {
        uiEpisodes.add(UIEpisode.fromLocalEpisode(episode));
      }
    }

    logTrace('Generated ${uiEpisodes.length} UIEpisodes for series ${series.name}');
    return uiEpisodes;
  }

  /// Generate UIEpisodes showing future episodes based on airing data
  /// This is for the future feature showing upcoming episodes
  List<UIEpisode> generateFutureEpisodes(Series series, {int maxFutureEpisodes = 5}) {
    if (!series.isLinked) return [];

    final List<UIEpisode> futureEpisodes = [];
    final totalEpisodesFromAnilist = _getTotalEpisodesFromAnilist(series);
    final localEpisodeMap = _getLocalEpisodeMap(series);
    final lastDownloadedEpisode = _getLastDownloadedEpisodeNumber(localEpisodeMap);

    // Show episodes that are beyond what the user has downloaded
    int futureCount = 0;
    for (int episodeNumber = lastDownloadedEpisode + 1; 
         episodeNumber <= totalEpisodesFromAnilist && futureCount < maxFutureEpisodes; 
         episodeNumber++) {
      
      // Check if we should mark as available or future based on airing data
      // For now, we'll assume they're available (could be enhanced with AniList airing data)
      futureEpisodes.add(UIEpisode.available(
        episodeNumber: episodeNumber,
        anilistTitle: _getEpisodeTitleFromCache(episodeNumber),
      ));
      futureCount++;
    }

    return futureEpisodes;
  }

  /// Get all local episodes as UIEpisodes (fallback when not linked to AniList)
  List<UIEpisode> _getLocalEpisodesAsUI(Series series) {
    final List<UIEpisode> uiEpisodes = [];
    
    // Add episodes from all seasons
    for (final season in series.seasons) {
      for (final episode in season.episodes) {
        uiEpisodes.add(UIEpisode.fromLocalEpisode(episode));
      }
    }
    
    // Add related media (OVAs, ONAs, etc.)
    for (final episode in series.relatedMedia) {
      uiEpisodes.add(UIEpisode.fromLocalEpisode(episode));
    }
    
    // Sort by episode number
    uiEpisodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    
    return uiEpisodes;
  }

  /// Create a map of episode number to local episode
  Map<int, Episode> _getLocalEpisodeMap(Series series) {
    final Map<int, Episode> episodeMap = {};
    
    // Add episodes from all seasons
    for (final season in series.seasons) {
      for (final episode in season.episodes) {
        final episodeNumber = episode.episodeNumber;
        if (episodeNumber != null) {
          episodeMap[episodeNumber] = episode;
        }
      }
    }
    
    // Add related media
    for (final episode in series.relatedMedia) {
      final episodeNumber = episode.episodeNumber;
      if (episodeNumber != null) {
        episodeMap[episodeNumber] = episode;
      }
    }
    
    return episodeMap;
  }

  /// Get total episode count from AniList data
  int _getTotalEpisodesFromAnilist(Series series) {
    if (!series.isLinked) return 0;

    int total = 0;
    for (final mapping in series.anilistMappings) {
      final episodes = mapping.anilistData?.episodes;
      if (episodes != null) total += episodes;
    }
    return total;
  }

  /// Get the highest episode number that's been downloaded
  int _getLastDownloadedEpisodeNumber(Map<int, Episode> episodeMap) {
    if (episodeMap.isEmpty) return 0;
    return episodeMap.keys.fold(0, (max, episodeNumber) => episodeNumber > max ? episodeNumber : max);
  }

  /// Get episode title from cache (placeholder - could integrate with EpisodeTitleService)
  String? _getEpisodeTitleFromCache(int episodeNumber) {
    // TODO: Integrate with EpisodeTitleService cache
    // For now, return null to use default formatting
    return null;
  }

  /// Categorize UIEpisodes into downloaded, available, and future
  Map<String, List<UIEpisode>> categorizeUIEpisodes(List<UIEpisode> uiEpisodes) {
    final Map<String, List<UIEpisode>> categories = {
      'downloaded': <UIEpisode>[],
      'available': <UIEpisode>[],
      'future': <UIEpisode>[],
    };

    for (final episode in uiEpisodes) {
      switch (episode.state) {
        case EpisodeState.downloaded:
          categories['downloaded']!.add(episode);
          break;
        case EpisodeState.available:
          categories['available']!.add(episode);
          break;
        case EpisodeState.future:
          categories['future']!.add(episode);
          break;
        case EpisodeState.unknown:
          // Add unknown episodes to available for now
          categories['available']!.add(episode);
          break;
      }
    }

    return categories;
  }
}