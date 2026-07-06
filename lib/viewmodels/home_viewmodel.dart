import 'package:fluent_ui/fluent_ui.dart';

import '../models/anilist/anime.dart';
import '../models/anilist/user_list.dart';
import '../models/episode.dart';
import '../models/season.dart';
import '../models/series.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/episode_navigation/anilist_progress_manager.dart';
import '../services/episode_navigation/episode_navigator.dart';
import '../services/library/library_provider.dart';
import '../services/mapping/custom_sonarr_mapping_service.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/time.dart';

/// ViewModel for the Home screen.
///
/// Owns the section data, the Sonarr episode-title cache, and the upcoming-episodes future cache.
///
/// Registered app-wide via `ChangeNotifierProxyProvider2<Library, AnilistProvider, HomeViewModel>` in `main.dart`.
class HomeViewModel extends ChangeNotifier {
  late Library _library;
  late AnilistProvider _anilist;
  bool _disposed = false;

  /// Called by the ChangeNotifierProxyProvider2 whenever [Library] or [AnilistProvider] notify
  void update(Library library, AnilistProvider anilist) {
    _library = library;
    _anilist = anilist;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // Continue Watching / Next Up

  /// Next unwatched episode for [series] (cross-season aware), or null.
  Episode? nextEpisodeFor(Series series) => AnilistProgressManager.instance.getNextEpisodeToWatch(series, _anilist);

  /// Linked, non-hidden library series present in the AniList "Watching" list, sorted by most recently updated then progress.
  ///
  /// Null when the watching list itself is unavailable (not logged in / not yet loaded).
  List<Series>? get watchingSeries {
    final watchingList = _anilist.userLists[AnilistListApiStatus.CURRENT.name_];
    if (watchingList == null) return null;

    final watchingIds = {for (final entry in watchingList.entries) entry.media.id};
    final result = filterWatching(
      librarySeries: _library.series,
      watchingIds: watchingIds,
      isHidden: (s) => _library.hiddenSeriesService.shouldFilterSeries(s),
    );
    sortByRecentlyUpdated(result, (s) => _anilist.getLatestUpdatedAt(s));
    return result;
  }

  /// Splits [watching] into (Continue Watching, Next Up): series whose next episode is partially watched vs not yet started
  (List<Series> started, List<Series> notStarted) sectionsFor(List<Series> watching) => //
      splitByStarted(watching, nextEpisodeFor, Library.progressThreshold);

  /// Random pick for the "Random Entry" button. Null when nothing is playable.
  (Series, Episode)? pickRandomEntry(List<Series> series) {
    if (series.isEmpty) return null;
    final startIndex = now.microsecondsSinceEpoch % series.length;

    for (var i = 0; i < series.length; i++) {
      final randomSeries = series[(startIndex + i) % series.length];
      final nextEpisode = nextEpisodeFor(randomSeries);
      if (nextEpisode != null) return (randomSeries, nextEpisode);

      if (i < series.length - 1) logDebug('Random entry: no playable episode found for ${randomSeries.name}, retrying...');
    }

    logDebug('Random entry: no playable episode found for any series! User is all caught up.');
    return null;
  }

  void playEpisode(Episode episode) => _library.playEpisode(episode);

  // Sonarr episode titles

  /// Sonarr episode title cache: series path → (episode path, title).
  ///
  /// Lives as long as the app, invalidated per-series when the next episode to watch changes.
  final Map<String, (PathString, String)> _sonarrTitleCache = {};

  /// Cached Sonarr title for a series' next episode, or null if not fetched
  String? sonarrTitleFor(Series series, Episode nextEpisode) {
    final cached = _sonarrTitleCache[series.path.path];
    if (cached != null && cached.$1 == nextEpisode.path) return cached.$2;
    return null;
  }

  /// Fetches Sonarr episode titles for series that aren't already cached.
  ///
  /// Fire-and-forget: notifies listeners when new titles arrive.
  void ensureSonarrTitles(List<Series> watchingSeries) {
    final sonarr = TorrentManager.sonarrRepository;
    if (sonarr == null || !TorrentManager.isEnabled) return;

    // Collect series that need fetching (cache miss or stale entry)
    final seriesToFetch = <(Series, Episode)>[];
    for (final series in watchingSeries) {
      final nextEpisode = nextEpisodeFor(series);
      if (nextEpisode == null) continue;

      final cached = _sonarrTitleCache[series.path.path];
      if (cached != null && cached.$1 == nextEpisode.path) continue; // Cache hit

      seriesToFetch.add((series, nextEpisode));
    }

    if (seriesToFetch.isEmpty) return;
    _fetchSonarrTitles(seriesToFetch, sonarr);
  }

  Future<void> _fetchSonarrTitles(List<(Series, Episode)> seriesToFetch, dynamic sonarr) async {
    final customMappings = CustomSonarrMappingService();
    bool anyNew = false;

    for (final (series, nextEpisode) in seriesToFetch) {
      try {
        // Resolve TVDB ID from any of the series' anilist mappings
        int? tvdbId;
        for (final mapping in series.anilistMappings) {
          tvdbId = await customMappings.getCustomTvdbId(mapping.anilistId);
          if (tvdbId != null) break;
          final plexMapping = await TorrentManager.plexBridge?.getMapping(mapping.anilistId);
          if (plexMapping != null) {
            tvdbId = plexMapping.tvdbId;
            break;
          }
        }
        if (tvdbId == null || tvdbId == 0) continue;

        // Fetch all episodes from Sonarr
        final sonarrSeriesId = await sonarr.getSeriesIdByTvdbId(tvdbId);
        if (sonarrSeriesId == null) continue;
        final sonarrEpisodes = await sonarr.getEpisodes(sonarrSeriesId);

        // Find the collection for this episode
        final collection = EpisodeNavigator.instance.findCollectionForEpisode(nextEpisode, series);
        final seasonNumber = (collection is Season) ? collection.seasonNumber : null;
        final epNumber = nextEpisode.episodeNumber;
        if (epNumber == null) continue;

        // Per-season match first
        String? matchedTitle;
        if (seasonNumber != null) {
          for (final sonarrEp in sonarrEpisodes) {
            if (sonarrEp.seasonNumber == seasonNumber && sonarrEp.episodeNumber == epNumber) {
              matchedTitle = sonarrEp.title;
              break;
            }
          }
        }

        // Absolute numbering fallback
        if (matchedTitle == null) {
          for (final sonarrEp in sonarrEpisodes) {
            if (sonarrEp.absoluteEpisodeNumber == epNumber) {
              matchedTitle = sonarrEp.title;
              break;
            }
          }
        }

        if (matchedTitle != null) {
          _sonarrTitleCache[series.path.path] = (nextEpisode.path, matchedTitle);
          anyNew = true;
        }
      } catch (e) {
        logDebug('Failed to fetch Sonarr title for ${series.name}: $e');
      }
    }

    if (anyNew) _notify();
  }

  // Upcoming Episodes

  Future<Map<int, AiringEpisode?>>? _cachedUpcomingEpisodesFuture;
  List<int>? _lastRequestedAnimeIds;
  int? _lastLibraryDataVersion;

  /// Linked library series present in the AniList "Watching" or "Planning" lists.
  ///
  /// Null when neither list is available.
  List<Series>? get watchPlanLinkedSeries {
    final watchingList = _anilist.userLists[AnilistListApiStatus.CURRENT.name_];
    final planningList = _anilist.userLists[AnilistListApiStatus.PLANNING.name_];

    final entries = [...watchingList?.entries ?? [], ...planningList?.entries ?? []];
    if (entries.isEmpty) return null;

    final ids = {for (final entry in entries) entry.media.id};
    return _library.series.where((series) {
      if (!series.isLinked) return false;
      return series.anilistMappings.any((mapping) => ids.contains(mapping.anilistId));
    }).toList();
  }

  /// Unique AniList IDs of RELEASING mappings across [series].
  List<int> releasingAnimeIds(List<Series> series) {
    final Set<int> animeIds = {};
    for (final s in series) {
      for (final mapping in s.anilistMappings) {
        if (mapping.anilistData?.status?.toAnimeStatus() == AnilistAnimeStatus.RELEASING) animeIds.add(mapping.anilistId);
      }
    }
    return animeIds.toList();
  }

  /// Cached upcoming episodes for [animeIds] (kicks off a background refresh).
  ///
  /// Invalidates the fresh-fetch future when the library data version changes.
  Map<int, AiringEpisode?> cachedUpcomingEpisodes(List<int> animeIds) {
    if (_lastLibraryDataVersion != null && _lastLibraryDataVersion != _library.dataVersion) {
      _cachedUpcomingEpisodesFuture = null;
      _lastRequestedAnimeIds = null;
    }
    _lastLibraryDataVersion = _library.dataVersion;

    return _anilist.getCachedUpcomingEpisodes(animeIds, refreshInBackground: true);
  }

  /// Memoized fresh fetch of upcoming episodes, keyed on [animeIds].
  ///
  /// Reused across rebuilds so FutureBuilder doesn't refire the request every frame.
  Future<Map<int, AiringEpisode?>> freshUpcomingEpisodes(List<int> animeIds) {
    if (_cachedUpcomingEpisodesFuture == null || _lastRequestedAnimeIds == null || !_listsEqual(_lastRequestedAnimeIds!, animeIds)) {
      _lastRequestedAnimeIds = animeIds;
      _cachedUpcomingEpisodesFuture = _anilist.getUpcomingEpisodes(animeIds);
    }
    return _cachedUpcomingEpisodesFuture!;
  }

  static bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Pure helpers

  /// Linked, non-hidden series whose mappings intersect [watchingIds]
  static List<Series> filterWatching({
    required List<Series> librarySeries,
    required Set<int> watchingIds,
    required bool Function(Series) isHidden,
  }) {
    return librarySeries.where((series) {
      if (!series.isLinked) return false;
      if (isHidden(series)) return false;
      return series.anilistMappings.any((mapping) => watchingIds.contains(mapping.anilistId));
    }).toList();
  }

  /// Sorts by most recently updated first, then by progress percentage (higher first)
  static void sortByRecentlyUpdated(List<Series> series, int? Function(Series) latestUpdatedAt) {
    series.sort((a, b) {
      final updatedComparison = (latestUpdatedAt(b) ?? 0).compareTo(latestUpdatedAt(a) ?? 0);
      if (updatedComparison != 0) return updatedComparison;
      return b.watchedPercentage.compareTo(a.watchedPercentage);
    });
  }

  /// Splits series into (started, notStarted) based on their next episode's progress.
  ///
  /// Series with no next episode are dropped.
  static (List<Series>, List<Series>) splitByStarted(
    List<Series> series,
    Episode? Function(Series) nextEpisodeOf,
    double progressThreshold,
  ) {
    final startedSeries = <Series>[];
    final notStartedSeries = <Series>[];

    for (final s in series) {
      final nextEpisode = nextEpisodeOf(s);
      if (nextEpisode == null) continue;

      if (nextEpisode.progress > 0 && nextEpisode.progress < progressThreshold && !nextEpisode.watched) {
        startedSeries.add(s);
      } else {
        notStartedSeries.add(s);
      }
    }

    return (startedSeries, notStartedSeries);
  }

  /// The earliest upcoming (airing) episode among [series]' mappings, with the AniList ID it belongs to.
  /// 
  /// Null when none is scheduled.
  static (AiringEpisode, int)? earliestAiring(Series series, Map<int, AiringEpisode?> upcomingEpisodesMap) {
    AiringEpisode? nextEpisode;
    int? correspondingAnilistId;

    for (final mapping in series.anilistMappings) {
      final episode = upcomingEpisodesMap[mapping.anilistId];
      if (episode?.airingAt != null) {
        if (nextEpisode == null || episode!.airingAt! < nextEpisode.airingAt!) {
          nextEpisode = episode;
          correspondingAnilistId = mapping.anilistId;
        }
      }
    }

    if (nextEpisode == null) return null;
    return (nextEpisode, correspondingAnilistId!);
  }

  /// Sorts series in place by their nearest upcoming airing time (earliest first)
  static void sortByNearestAiring(List<Series> series, Map<int, AiringEpisode?> upcomingEpisodesMap) {
    series.sort((a, b) {
      final aNext = earliestAiring(a, upcomingEpisodesMap)?.$1.airingAt;
      final bNext = earliestAiring(b, upcomingEpisodesMap)?.$1.airingAt;
      return (aNext ?? 0).compareTo(bNext ?? 0);
    });
  }
}
