part of 'anilist_service.dart';

extension AnilistBrowseSearch on AnilistService {
  List<AnilistAnime> _parseAnimeList(Map<String, dynamic> data) {
    if (data.isEmpty || 
        data['Page'] == null ||
        data['Page']['media'] == null) return [];

    final List<dynamic> mediaList = data['Page']['media'];
    return mediaList.map((json) => AnilistAnime.fromJson(json)).toList();
  }

  AnilistSearchPage<AnilistAnime>? _parseSearchPage(Map<String, dynamic> data) {
    if (data.isEmpty || data['Page'] == null) return null;
    
    final pageInfo = AnilistPageInfo.fromJson(data['Page']['pageInfo']);
    final results = _parseAnimeList(data);
    return AnilistSearchPage(pageInfo: pageInfo, results: results);
  }

  Future<Map<String, dynamic>> _executeBrowseQuery({
    required String query,
    required Map<String, dynamic> variables,
    required String operationName,
    FetchPolicy fetchPolicy = FetchPolicy.networkOnly,
  }) async {
    if (_client == null) return <String, dynamic>{};

    logTrace('Executing browse query: $operationName');

    try {
      final result = await RetryUtils.retry<Map<String, dynamic>>(
        (bool isOffline) async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(query),
              variables: variables,
              fetchPolicy: isOffline ? FetchPolicy.cacheOnly : fetchPolicy,
            ),
          );

          if (queryResult.hasException) {
            if (RetryUtils.isExpectedOfflineError(queryResult.exception)) return <String, dynamic>{};
            throw Exception('Error executing $operationName: ${queryResult.exception}');
          }

          return queryResult.data ?? <String, dynamic>{};
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: operationName,
        isOfflineAware: true,
      );

      return result ?? <String, dynamic>{};
    } catch (e, stackTrace) {
      if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
        logDebug('Skipping $operationName - device is offline');
        return <String, dynamic>{};
      }
      logErr('Error executing $operationName', e, stackTrace);
      return <String, dynamic>{};
    }
  }

  Future<AnilistSearchPage<AnilistAnime>?> getTrendingNow({int page = 1, int perPage = 6}) async {
    // Trending doesn't need season info, just the sort
    final data = await _executeBrowseQuery(
      query: homeSectionQuery,
      variables: {
        'page': page,
        'perPage': perPage,
        'sort': ['TRENDING_DESC'],
      },
      operationName: 'getTrendingNow',
    );
    return _parseSearchPage(data);
  }

  Future<AnilistSearchPage<AnilistAnime>?> getPopularThisSeason({int page = 1, int perPage = 6}) async {
    final seasonData = _getSeasonData(now);
    final data = await _executeBrowseQuery(
      query: homeSectionQuery,
      variables: {
        'page': page,
        'perPage': perPage,
        'season': seasonData['season'],
        'seasonYear': seasonData['year'],
        'sort': ['POPULARITY_DESC'],
      },
      operationName: 'getPopularThisSeason',
    );
    return _parseSearchPage(data);
  }

  Future<AnilistSearchPage<AnilistAnime>?> getUpcomingNextSeason({int page = 1, int perPage = 6}) async {
    final seasonData = _getNextSeasonData();
    final data = await _executeBrowseQuery(
      query: homeSectionQuery,
      variables: {
        'page': page,
        'perPage': perPage,
        'season': seasonData['season'],
        'seasonYear': seasonData['year'],
        'sort': ['POPULARITY_DESC'],
      },
      operationName: 'getUpcomingNextSeason',
    );
    return _parseSearchPage(data);
  }

  Future<AnilistSearchPage<AnilistAnime>?> getAllTimePopular({int page = 1, int perPage = 6}) async {
    final data = await _executeBrowseQuery(
      query: homeSectionQuery,
      variables: {
        'page': page,
        'perPage': perPage,
        'sort': ['POPULARITY_DESC'],
      },
      operationName: 'getAllTimePopular',
    );
    return _parseSearchPage(data);
  }

  Future<AnilistSearchPage<AnilistAnime>?> getTop100Anime({int page = 1, int perPage = 10}) async {
    // Requested first 10 for this specific section
    final data = await _executeBrowseQuery(
      query: homeSectionQuery,
      variables: {
        'page': page,
        'perPage': perPage,
        'sort': ['SCORE_DESC'],
      },
      operationName: 'getTop100Anime',
    );
    return _parseSearchPage(data);
  }

  /// "View All" (passing filters) and generic "Search" functionality.
  Future<AnilistSearchPage<AnilistAnime>?> searchAnime({
    required int page,
    int perPage = 20,
    String? search,
    List<String>? genres,
    List<String>? excludedGenres,
    List<String>? tags,
    List<String>? excludedTags,
    String? format, // TV, MOVIE, etc.
    String? status,
    String? seasonYear, // e.g., "2023%" for fuzzy search or specific year
    String? season, // WINTER, SPRING...
    int? yearLesser,
    int? yearGreater,
    int? episodeLesser,
    int? episodeGreater,
    int? durationLesser,
    int? durationGreater,
    bool? isAdult,
    bool? onList,
    bool? isLicensed,
    List<int>? licensedBy,
    int? minimumTagRank,
    String? countryOfOrigin,
    String? source,
    List<String> sort = const ['POPULARITY_DESC'],
  }) async {
    // Prepare variables, removing nulls so GraphQL doesn't complain
    final Map<String, dynamic> variables = {
      'page': page,
      'perPage': perPage,
      'sort': sort,
      'isAdult': isAdult ?? false,
    };

    if (search != null && search.isNotEmpty) variables['search'] = search;
    if (genres != null && genres.isNotEmpty) variables['genres'] = genres;
    if (excludedGenres != null && excludedGenres.isNotEmpty) variables['excludedGenres'] = excludedGenres;
    if (tags != null && tags.isNotEmpty) variables['tags'] = tags;
    if (excludedTags != null && excludedTags.isNotEmpty) variables['excludedTags'] = excludedTags;
    if (format != null) variables['format'] = [format];
    if (status != null) variables['status'] = status;
    if (season != null) variables['season'] = season;
    // Note: AniList "startDate_like" expects "2023%" for year searching usually,
    // or you can use separate seasonYear argument if strictly looking for a season's anime.
    if (seasonYear != null) variables['year'] = "$seasonYear%";
    if (yearLesser != null) variables['yearLesser'] = yearLesser;
    if (yearGreater != null) variables['yearGreater'] = yearGreater;
    if (episodeLesser != null) variables['episodeLesser'] = episodeLesser;
    if (episodeGreater != null) variables['episodeGreater'] = episodeGreater;
    if (durationLesser != null) variables['durationLesser'] = durationLesser;
    if (durationGreater != null) variables['durationGreater'] = durationGreater;
    if (onList != null) variables['onList'] = onList;
    if (isLicensed != null) variables['isLicensed'] = isLicensed;
    if (licensedBy != null && licensedBy.isNotEmpty) variables['licensedBy'] = licensedBy;
    if (minimumTagRank != null) variables['minimumTagRank'] = minimumTagRank;
    if (countryOfOrigin != null) variables['countryOfOrigin'] = countryOfOrigin;
    if (source != null) variables['source'] = source;

    final data = await _executeBrowseQuery(
      query: searchAnimeQuery,
      variables: variables,
      operationName: 'searchAnime',
    );
    return _parseSearchPage(data);
  }
}

const String mediaFragment = r'''
  fragment media on Media {
    id
    title {
      userPreferred
      romaji
      english
      native
    }
    coverImage {
      extraLarge
      large
      medium
      color
    }
    startDate {
      year
      month
      day
    }
    endDate {
      year
      month
      day
    }
    bannerImage
    season
    seasonYear
    description
    type
    format
    status(version: 2)
    episodes
    duration
    chapters
    volumes
    genres
    isAdult
    averageScore
    popularity
    nextAiringEpisode {
      airingAt
      timeUntilAiring
      episode
    }
    studios(isMain: true) {
      edges {
        isMain
        node {
          id
          name
        }
      }
    }
  }
''';

// Query for the specific "Preview" sections (Trending, Popular, etc.)
// We use hardcoded "perPage: 6" for previews as requested, but you can override it.
const String homeSectionQuery = r'''
query ($page: Int, $perPage: Int, $season: MediaSeason, $seasonYear: Int, $sort: [MediaSort], $status: MediaStatus) {
  Page(page: $page, perPage: $perPage) {
    pageInfo {
      total
      perPage
      currentPage
      lastPage
      hasNextPage
    }
    media(season: $season, seasonYear: $seasonYear, sort: $sort, type: ANIME, status: $status, isAdult: false) {
      ...media
    }
  }
}
''' + mediaFragment;

// The Main Search Query (Supports Filters & Pagination)
const String searchAnimeQuery = r'''
query (
  $page: Int,
  $perPage: Int,
  $search: String,
  $genres: [String],
  $excludedGenres: [String],
  $tags: [String],
  $excludedTags: [String],
  $format: [MediaFormat],
  $status: MediaStatus,
  $season: MediaSeason,
  $year: String,
  $yearLesser: FuzzyDateInt,
  $yearGreater: FuzzyDateInt,
  $episodeLesser: Int,
  $episodeGreater: Int,
  $durationLesser: Int,
  $durationGreater: Int,
  $onList: Boolean,
  $isLicensed: Boolean,
  $licensedBy: [Int],
  $minimumTagRank: Int,
  $countryOfOrigin: CountryCode,
  $source: MediaSource,
  $sort: [MediaSort],
  $isAdult: Boolean
) {
  Page(page: $page, perPage: $perPage) {
    pageInfo {
      total
      perPage
      currentPage
      lastPage
      hasNextPage
    }
    media(
      search: $search,
      genre_in: $genres,
      genre_not_in: $excludedGenres,
      tag_in: $tags,
      tag_not_in: $excludedTags,
      format_in: $format,
      status: $status,
      season: $season,
      startDate_like: $year,
      startDate_lesser: $yearLesser,
      startDate_greater: $yearGreater,
      episodes_lesser: $episodeLesser,
      episodes_greater: $episodeGreater,
      duration_lesser: $durationLesser,
      duration_greater: $durationGreater,
      onList: $onList,
      isLicensed: $isLicensed,
      licensedById_in: $licensedBy,
      minimumTagRank: $minimumTagRank,
      countryOfOrigin: $countryOfOrigin,
      source: $source,
      sort: $sort,
      type: ANIME,
      isAdult: $isAdult
    ) {
      ...media
    }
  }
}
''' + mediaFragment;
  