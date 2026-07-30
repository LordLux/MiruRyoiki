// import 'package:flutter/foundation.dart';

import '../models/anilist/anime_card.dart';
import '../models/anilist/page_info.dart';
import '../services/anilist/queries/anilist_service.dart';
import 'disposable_view_model.dart';

class SearchSectionData {
  final int id;
  final String type;
  List<AnimeCard> items = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  int perPage;
  String? errorMessage;
  bool isFetching = false;

  SearchSectionData({required this.id, required this.type, this.perPage = 6});
}

/// ViewModel for the Search screen (and search results).
///
/// Owns the section data (Trending, Popular, Upcoming, Top 100) and text search results.
/// 
/// Registered app-wide via `ChangeNotifierProvider` in `main.dart`.
class SearchViewModel extends DisposableViewModel {
  SearchViewModel({AnilistService? anilistService}) : _anilistServiceOverride = anilistService {
    _sectionManagers = {
      1: SearchSectionData(id: 1, type: 'trending'),
      2: SearchSectionData(id: 2, type: 'popular'),
      3: SearchSectionData(id: 3, type: 'upcoming'),
      4: SearchSectionData(id: 4, type: 'top100', perPage: 10),
    };
  }

  final AnilistService? _anilistServiceOverride;

  /// Resolved lazily: constructing [AnilistService] initializes the auth service (which reads .env),
  /// so pure-logic unit tests that never load data must not trigger it.
  late final AnilistService _anilistService = _anilistServiceOverride ?? AnilistService();



  late final Map<int, SearchSectionData> _sectionManagers;
  Map<int, SearchSectionData> get sectionManagers => _sectionManagers;

  Future<List<String>>? imagesFuture;

  // Text Search State
  int _searchRequestId = 0;
  String? _resultsQuery;
  Map<String, dynamic>? _resultsFilters;
  final List<AnimeCard> _resultsList = [];
  bool _resultsIsLoading = false;
  bool _resultsHasNextPage = true;
  int _resultsCurrentPage = 1;
  String? _resultsErrorMessage;

  int? _expandedSectionId;
  int? get expandedSectionId => _expandedSectionId;

  void setExpandedSection(int? id) {
    _expandedSectionId = id;
    notifySafe();
  }

  String? get resultsQuery => _resultsQuery;
  Map<String, dynamic>? get resultsFilters => _resultsFilters;
  List<AnimeCard> get resultsList => _resultsList;
  bool get resultsIsLoading => _resultsIsLoading;
  bool get resultsHasNextPage => _resultsHasNextPage;
  int get resultsCurrentPage => _resultsCurrentPage;
  String? get resultsErrorMessage => _resultsErrorMessage;

  void fetchInitialData() {
    for (var manager in _sectionManagers.values) {
      fetchSection(manager.id, reset: true, overridePerPage: manager.perPage);
    }
    imagesFuture = _aggregateImages();
    notifySafe();
  }

  Future<void> fetchSection(int sectionId, {bool reset = false, int? overridePerPage, bool preserveCurrentItems = false}) async {
    final manager = _sectionManagers[sectionId];
    if (manager == null) return;
    if (manager.isFetching) return;
    if (!manager.hasMore && !reset) return;

    manager.isFetching = true;

    if (manager.items.isEmpty || (reset && !preserveCurrentItems)) {
      manager.isLoading = true;
      notifySafe();
    }

    try {
      int reqPage = reset ? 1 : manager.currentPage;
      int reqPerPage = overridePerPage ?? manager.perPage;

      AnilistSearchPage<AnimeCard>? result;

      switch (manager.type) {
        case 'trending':
          result = await _anilistService.getTrendingNow(page: reqPage, perPage: reqPerPage);
          break;
        case 'popular':
          result = await _anilistService.getPopularThisSeason(page: reqPage, perPage: reqPerPage);
          break;
        case 'upcoming':
          result = await _anilistService.getUpcomingNextSeason(page: reqPage, perPage: reqPerPage);
          break;
        case 'top100':
          result = await _anilistService.getTop100Anime(page: reqPage, perPage: reqPerPage);
          break;
      }

      if (isDisposed) return;

      if (result != null) {
        if (reset) {
          if (!preserveCurrentItems) manager.items.clear();
          manager.currentPage = 1;
          if (overridePerPage != null) manager.perPage = overridePerPage;
        }

        if (result.results.isNotEmpty) {
          final newItems = result.results.where((newAnim) => !manager.items.any((existing) => existing.id == newAnim.id));
          manager.items.addAll(newItems);
        }
        manager.hasMore = result.pageInfo.hasNextPage;
        manager.currentPage++;
      }
    } catch (e) {
      if (isDisposed) return;
      manager.errorMessage = e.toString();
    } finally {
      if (!isDisposed) {
        manager.isLoading = false;
        manager.isFetching = false;
        notifySafe();
      }
    }
  }

  Future<List<String>> _aggregateImages() async {
    // Wait until section managers have loaded their initial data instead of
    // firing 4 duplicate AniList requests.
    const maxWaitMs = 10000;
    const pollMs = 100;
    var waited = 0;
    while (waited < maxWaitMs) {
      final hasData = _sectionManagers.values.any((m) => m.items.isNotEmpty);
      if (hasData) break;
      await Future.delayed(const Duration(milliseconds: pollMs));
      waited += pollMs;
      if (isDisposed) return [];
    }

    final Set<String> images = {};
    for (final manager in _sectionManagers.values) {
      for (final anime in manager.items) {
        if (anime.coverImage != null) images.add(anime.coverImage!);
      }
    }
    return images.toList()..shuffle();
  }

  void performTextSearch(String query, {Map<String, dynamic>? filters}) {
    _searchRequestId++;
    _resultsQuery = query;
    _resultsFilters = filters;
    _resultsList.clear();
    _resultsCurrentPage = 1;
    _resultsHasNextPage = true;
    _resultsIsLoading = false;
    _resultsErrorMessage = null;
    notifySafe();

    fetchTextSearchResults();
  }

  void clearTextSearch() {
    _searchRequestId++;
    _resultsQuery = null;
    _resultsFilters = null;
    _resultsList.clear();
    _resultsCurrentPage = 1;
    _resultsHasNextPage = true;
    _resultsIsLoading = false;
    _resultsErrorMessage = null;
    notifySafe();
  }

  Future<void> fetchTextSearchResults() async {
    if (_resultsIsLoading || isDisposed) return;
    _resultsIsLoading = true;
    _resultsErrorMessage = null;
    notifySafe();

    final requestId = _searchRequestId;

    try {
      final perPage = 42;

      AnilistSearchPage<AnimeCard>? result = await _anilistService.searchAnime(
        page: _resultsCurrentPage,
        perPage: perPage,
        search: _resultsQuery,
        genres: _resultsFilters?['genres'],
        sort: _resultsFilters?['sort'] ?? const ['POPULARITY_DESC'],
      );

      if (isDisposed || requestId != _searchRequestId) return;

      if (result == null) {
        _resultsIsLoading = false;
        _resultsErrorMessage = 'Failed to load data.';
        notifySafe();
        return;
      }

      final pageInfo = result.pageInfo;
      final media = result.results;

      _resultsList.addAll(media);
      _resultsHasNextPage = pageInfo.hasNextPage;
      _resultsCurrentPage++;
      _resultsIsLoading = false;
      notifySafe();
    } catch (e) {
      if (isDisposed || requestId != _searchRequestId) return;
      _resultsIsLoading = false;
      _resultsErrorMessage = 'Error: $e';
      notifySafe();
    }
  }

  // For SearchResultsScreen
  int _genericRequestId = 0;
  String? _genericQueryType;
  String? _genericSearchQuery;
  Map<String, dynamic>? _genericFilters;
  final List<AnimeCard> _genericResultsList = [];
  bool _genericIsLoading = false;
  bool _genericHasNextPage = true;
  int _genericCurrentPage = 1;
  String? _genericErrorMessage;

  List<AnimeCard> get genericResultsList => _genericResultsList;
  bool get genericIsLoading => _genericIsLoading;
  bool get genericHasNextPage => _genericHasNextPage;
  int get genericCurrentPage => _genericCurrentPage;
  String? get genericErrorMessage => _genericErrorMessage;

  void initGenericSearch(String queryType, String? searchQuery, Map<String, dynamic>? filters) {
    _genericRequestId++;
    _genericQueryType = queryType;
    _genericSearchQuery = searchQuery;
    _genericFilters = filters;
    _genericResultsList.clear();
    _genericCurrentPage = 1;
    _genericHasNextPage = true;
    _genericIsLoading = false;
    _genericErrorMessage = null;
    notifySafe();
    fetchGenericData();
  }

  Future<void> fetchGenericData([int perPage = 20]) async {
    if (_genericIsLoading || isDisposed) return;
    _genericIsLoading = true;
    _genericErrorMessage = null;
    notifySafe();

    final requestId = _genericRequestId;

    try {
      AnilistSearchPage<AnimeCard>? result = await switch (_genericQueryType) {
        'trending' => _anilistService.getTrendingNow(page: _genericCurrentPage, perPage: perPage),
        'popular' => _anilistService.getPopularThisSeason(page: _genericCurrentPage, perPage: perPage),
        'upcoming' => _anilistService.getUpcomingNextSeason(page: _genericCurrentPage, perPage: perPage),
        'top100' => _anilistService.getTop100Anime(page: _genericCurrentPage, perPage: perPage),
        'search' => _anilistService.searchAnime(
            page: _genericCurrentPage,
            perPage: perPage,
            search: _genericSearchQuery,
            genres: _genericFilters?['genres'],
            seasonYear: _genericFilters?['year'],
            season: _genericFilters?['season'],
            format: _genericFilters?['format'],
            countryOfOrigin: _genericFilters?['countryOfOrigin'],
            durationGreater: _genericFilters?['durationGreater'],
            durationLesser: _genericFilters?['durationLesser'],
            episodeGreater: _genericFilters?['episodeGreater'],
            episodeLesser: _genericFilters?['episodeLesser'],
            excludedGenres: _genericFilters?['excludedGenres'],
            excludedTags: _genericFilters?['excludedTags'],
            isAdult: _genericFilters?['isAdult'],
            isLicensed: _genericFilters?['isLicensed'],
            sort: _genericFilters?['sort'] ?? const ['POPULARITY_DESC'],
            licensedBy: _genericFilters?['licensedBy'],
            minimumTagRank: _genericFilters?['minimumTagRank'],
            onList: _genericFilters?['onList'],
            source: _genericFilters?['source'],
            status: _genericFilters?['status'],
            tags: _genericFilters?['tags'],
            yearGreater: _genericFilters?['yearGreater'],
            yearLesser: _genericFilters?['yearLesser'],
          ),
        _ => null,
      };

      if (isDisposed || requestId != _genericRequestId) return;

      if (result == null) {
        final bool isValidQuery = ['trending', 'popular', 'upcoming', 'top100', 'search'].contains(_genericQueryType);
        _genericIsLoading = false;
        if (isValidQuery) {
          _genericErrorMessage = 'Failed to load data. Please check your connection.';
        } else {
          _genericErrorMessage = 'Invalid query type: $_genericQueryType';
        }
        notifySafe();
        return;
      }

      final pageInfo = result.pageInfo;
      final media = result.results;

      _genericResultsList.addAll(media);
      _genericHasNextPage = pageInfo.hasNextPage;
      _genericCurrentPage++;
      _genericIsLoading = false;
      notifySafe();
    } catch (e) {
      if (isDisposed || requestId != _genericRequestId) return;
      _genericIsLoading = false;
      _genericErrorMessage = 'An error occurred: $e';
      notifySafe();
    }
  }
}
