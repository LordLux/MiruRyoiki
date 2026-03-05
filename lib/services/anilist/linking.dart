import 'package:miruryoiki/utils/time.dart';

import '../../models/anilist/anime_overview.dart';
import '../../models/anilist/anime.dart';
import '../../models/anilist/page_info.dart';
import '../../models/series.dart';
import '../../utils/logging.dart';
import 'queries/anilist_service.dart';

class _CachedOverview {
  final AnimeOverview data;
  final DateTime fetchedAt;
  _CachedOverview(this.data) : fetchedAt = now;
  bool get isStale => now.difference(fetchedAt) > const Duration(hours: 1);
}

class _CachedTabPage<T> {
  final List<T> items;
  final AnilistPageInfo pageInfo;
  final DateTime fetchedAt;
  _CachedTabPage(this.items, this.pageInfo) : fetchedAt = now;
  bool get isStale => now.difference(fetchedAt) > const Duration(hours: 1);
}

class _CachedStats {
  final AnimeStatsFull data;
  final DateTime fetchedAt;
  _CachedStats(this.data) : fetchedAt = now;
  bool get isStale => now.difference(fetchedAt) > const Duration(hours: 1);
}

class SeriesLinkService {
  final AnilistService _anilistService;

  /// In-memory cache for AnimeOverview to avoid redundant API calls
  /// when navigating between related series / recommendations.
  static final Map<int, _CachedOverview> _overviewCache = {};
  static const int _maxOverviewCacheSize = 50;

  // Per-tab paginated caches: mediaId -> page -> cached page
  static final Map<int, Map<int, _CachedTabPage<CharacterEdge>>> _characterCache = {};
  static final Map<int, Map<int, _CachedTabPage<StaffEdge>>> _staffCache = {};
  static final Map<int, Map<int, _CachedTabPage<MediaListSocial>>> _socialCache = {};
  static final Map<int, _CachedStats> _statsCache = {};

  SeriesLinkService({AnilistService? anilistService}) : _anilistService = anilistService ?? AnilistService();

  /// Try to link a series to Anilist by name
  Future<List<AnilistAnime>> findMatchesByName(Series series) async {
    // Clean up the series name to improve matching
    final searchQuery = _cleanSeriesName(series.name);
    return await _anilistService.searchAnimeMatch(searchQuery);
  }

  /// Search for anime by a raw query string
  Future<List<AnilistAnime>> searchByQuery(String query, {int limit = 10}) async {
    return await _anilistService.searchAnimeMatch(query, limit: limit);
  }

  Future<AnilistAnime?> fetchAnimeDetails(int anilistId) async {
    return await _anilistService.getAnimeDetails(anilistId);
  }

  Future<AnimeOverview?> fetchDetailedAnimeDetails(int anilistId) async {
    // Check in-memory cache first
    final cached = _overviewCache[anilistId];
    if (cached != null && !cached.isStale) {
      return cached.data;
    }

    final result = await _anilistService.getDetailedAnimeDetails(anilistId);
    if (result != null) {
      // Evict oldest entries if cache is full
      if (_overviewCache.length >= _maxOverviewCacheSize) {
        final oldest = _overviewCache.entries
            .reduce((a, b) => a.value.fetchedAt.isBefore(b.value.fetchedAt) ? a : b);
        _overviewCache.remove(oldest.key);
      }
      _overviewCache[anilistId] = _CachedOverview(result);
    }
    return result;
  }

  Future<Map<int, AnilistAnime?>> fetchMultipleAnimeDetails(List<int> anilistIds) async {
    return await _anilistService.getMultipleAnimesDetails(anilistIds);
  }

  Future<({List<CharacterEdge> characters, AnilistPageInfo pageInfo})?> fetchAnimeCharacters(
    int id, {
    int page = 1,
  }) async {
    final cached = _characterCache[id]?[page];
    if (cached != null && !cached.isStale) {
      return (characters: cached.items, pageInfo: cached.pageInfo);
    }
    final result = await _anilistService.getAnimeCharacters(id, page: page);
    if (result != null) {
      _characterCache.putIfAbsent(id, () => {})[page] = _CachedTabPage(result.characters, result.pageInfo);
    }
    return result;
  }

  Future<({List<StaffEdge> staff, AnilistPageInfo pageInfo})?> fetchAnimeStaff(
    int id, {
    int page = 1,
  }) async {
    final cached = _staffCache[id]?[page];
    if (cached != null && !cached.isStale) {
      return (staff: cached.items, pageInfo: cached.pageInfo);
    }
    final result = await _anilistService.getAnimeStaff(id, page: page);
    if (result != null) {
      _staffCache.putIfAbsent(id, () => {})[page] = _CachedTabPage(result.staff, result.pageInfo);
    }
    return result;
  }

  Future<({List<MediaListSocial> social, AnilistPageInfo pageInfo})?> fetchAnimeSocial(
    int id, {
    int page = 1,
  }) async {
    final cached = _socialCache[id]?[page];
    if (cached != null && !cached.isStale) {
      return (social: cached.items, pageInfo: cached.pageInfo);
    }
    final result = await _anilistService.getAnimeSocial(id, page: page);
    if (result != null) {
      _socialCache.putIfAbsent(id, () => {})[page] = _CachedTabPage(result.social, result.pageInfo);
    }
    return result;
  }

  Future<AnimeStatsFull?> fetchAnimeStats(int id) async {
    final cached = _statsCache[id];
    if (cached != null && !cached.isStale) return cached.data;
    final result = await _anilistService.getAnimeStats(id);
    if (result != null) _statsCache[id] = _CachedStats(result);
    return result;
  }

  /// Link a series to a specific Anilist ID
  Future<bool> linkSeries(Series series, int anilistId) async {
    try {
      final anime = await _anilistService.getAnimeDetails(anilistId);
      if (anime != null) {
        series.primaryAnilistId = anilistId;
        series.anilistData = anime;
        return true;
      }
    } catch (e) {
      logErr('Error linking series to Anilist', e);
    }
    return false;
  }

  /// Clean up series name for better search results
  String _cleanSeriesName(String name) {
    // Remove common patterns in filenames
    String cleaned = name
        .replaceAll(RegExp(r'\[.*?\]'), '') // Remove text in brackets
        .replaceAll(RegExp(r'\(.*?\)'), '') // Remove text in parentheses
        .replaceAll(RegExp(r'S\d{1,2}'), '') // Remove season indicators
        .replaceAll(RegExp(r'\d{3,4}p'), '') // Remove resolution
        .replaceAll(RegExp(r'BD|BluRay|dvd|webdl|webrip', caseSensitive: false), '')
        .replaceAll(RegExp(r'x\d{3}'), '') // Remove codec info
        .replaceAll('_', ' ')
        .replaceAll('.', ' ')
        .trim();

    // Remove multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned;
  }

  /// Refresh metadata for a linked series
  Future<bool> refreshMetadata(Series series) async {
    if (series.primaryAnilistId == null) return false;

    try {
      final anime = await _anilistService.getAnimeDetails(series.primaryAnilistId!);
      if (anime != null) {
        series.anilistData = anime;
        return true;
      }
    } catch (e) {
      logErr('Error refreshing Anilist metadata', e);
    }
    return false;
  }
}
