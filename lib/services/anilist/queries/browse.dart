part of 'anilist_service.dart';

class _AnimeSeasonUtil {
  static const List<String> _seasons = ['WINTER', 'SPRING', 'SUMMER', 'FALL'];

  /// Returns the current season and year based on the current date
  static Map<String, dynamic> getCurrentSeasonData() {
    final now = DateTime.now();
    return _getSeasonForMonth(now.month, now.year);
  }

  /// Returns the strictly defined next season
  static Map<String, dynamic> getNextSeasonData() {
    final now = DateTime.now();
    final currentData = _getSeasonForMonth(now.month, now.year);
    
    String currentSeason = currentData['season'];
    int currentYear = currentData['year'];

    // Find the index of the current season
    int currentIndex = _seasons.indexOf(currentSeason);

    int nextIndex = (currentIndex + 1) % 4;
    
    // If we wrapped from 3 (Fall) back to 0 (Winter), increment the year
    int nextYear = (nextIndex == 0) ? currentYear + 1 : currentYear;

    return {
      'season': _seasons[nextIndex],
      'year': nextYear
    };
  }

  // Helper to determine season from month
  static Map<String, dynamic> _getSeasonForMonth(int month, int year) {
    String season;
    if (month >= 1 && month <= 3) {
      season = 'WINTER';
    } else if (month >= 4 && month <= 6) {
      season = 'SPRING';
    } else if (month >= 7 && month <= 9) {
      season = 'SUMMER';
    } else {
      season = 'FALL';
    }
    return {'season': season, 'year': year};
  }
}

extension AnilistBrowseSearch on AnilistService {
  Future<AnilistSearchPage<AnimeCard>?> _executeHomeSectionQuery({
    required Variables$Query$GetHomeSection variables,
    required String operationName,
  }) async {
    if (_client == null) return null;

    final result = await executeQuery<Query$GetHomeSection>(
      options: QueryOptions(
        document: documentNodeQueryGetHomeSection,
        variables: variables.toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: operationName,
      parser: (data) => Query$GetHomeSection.fromJson(data),
    );

    if (result == null || result.Page == null) return null;

    final pageInfo = AnilistPageInfo(
      total: result.Page!.pageInfo?.total ?? 0,
      perPage: result.Page!.pageInfo?.perPage ?? 0,
      currentPage: result.Page!.pageInfo?.currentPage ?? 1,
      lastPage: result.Page!.pageInfo?.lastPage ?? 1,
      hasNextPage: result.Page!.pageInfo?.hasNextPage ?? false,
    );

    final mediaList = result.Page!.media
            ?.whereType<Fragment$AnimeCard>()
            .map((media) => AnimeCard.fromFragment(media))
            .toList() ??
        [];

    return AnilistSearchPage(pageInfo: pageInfo, results: mediaList);
  }

  Future<AnilistSearchPage<AnimeCard>?> getTrendingNow({int page = 1, int perPage = 6}) async {
    return _executeHomeSectionQuery(
      variables: Variables$Query$GetHomeSection(
        page: page,
        perPage: perPage,
        sort: [Enum$MediaSort.TRENDING_DESC],
      ),
      operationName: 'getTrendingNow',
    );
  }

  Future<AnilistSearchPage<AnimeCard>?> getPopularThisSeason({int page = 1, int perPage = 6}) async {
    final seasonData = _AnimeSeasonUtil.getCurrentSeasonData();
    return _executeHomeSectionQuery(
      variables: Variables$Query$GetHomeSection(
        page: page,
        perPage: perPage,
        season: _parseSeason(seasonData['season']),
        seasonYear: seasonData['year'],
        sort: [Enum$MediaSort.POPULARITY_DESC],
      ),
      operationName: 'getPopularThisSeason',
    );
  }

  Future<AnilistSearchPage<AnimeCard>?> getUpcomingNextSeason({int page = 1, int perPage = 6}) async {
    final seasonData = _AnimeSeasonUtil.getNextSeasonData();
    return _executeHomeSectionQuery(
      variables: Variables$Query$GetHomeSection(
        page: page,
        perPage: perPage,
        season: _parseSeason(seasonData['season']),
        seasonYear: seasonData['year'],
        sort: [Enum$MediaSort.POPULARITY_DESC],
      ),
      operationName: 'getUpcomingNextSeason',
    );
  }

  Future<AnilistSearchPage<AnimeCard>?> getAllTimePopular({int page = 1, int perPage = 6}) async {
    return _executeHomeSectionQuery(
      variables: Variables$Query$GetHomeSection(
        page: page,
        perPage: perPage,
        sort: [Enum$MediaSort.POPULARITY_DESC],
      ),
      operationName: 'getAllTimePopular',
    );
  }

  Future<AnilistSearchPage<AnimeCard>?> getTop100Anime({int page = 1, int perPage = 10}) async {
    return _executeHomeSectionQuery(
      variables: Variables$Query$GetHomeSection(
        page: page,
        perPage: perPage,
        sort: [Enum$MediaSort.SCORE_DESC],
      ),
      operationName: 'getTop100Anime',
    );
  }

  Enum$MediaSeason? _parseSeason(String? season) {
    if (season == null) return null;
    return Enum$MediaSeason.values.firstWhereOrNull((e) => e.name == season);
  }

  Enum$MediaSort? _parseSort(String? sort) {
    if (sort == null) return null;
    return Enum$MediaSort.values.firstWhereOrNull((e) => e.toJson() == sort);
  }

  Enum$MediaFormat? _parseFormat(String? format) {
    if (format == null) return null;
    return Enum$MediaFormat.values.firstWhereOrNull((e) => e.toJson() == format);
  }

  Enum$MediaStatus? _parseStatus(String? status) {
    if (status == null) return null;
    return Enum$MediaStatus.values.firstWhereOrNull((e) => e.toJson() == status);
  }

  Enum$MediaSource? _parseSource(String? source) {
    if (source == null) return null;
    return Enum$MediaSource.values.firstWhereOrNull((e) => e.toJson() == source);
  }

  /// "View All" (passing filters) and generic "Search" functionality.
  Future<AnilistSearchPage<AnimeCard>?> searchAnime({
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
    if (_client == null) return null;

    final variables = Variables$Query$SearchAnime(
      page: page,
      perPage: perPage,
      search: search,
      genres: genres,
      excludedGenres: excludedGenres,
      tags: tags,
      excludedTags: excludedTags,
      format: format != null ? [_parseFormat(format)] : null,
      status: _parseStatus(status),
      season: _parseSeason(season),
      year: seasonYear != null ? "$seasonYear%" : null,
      yearLesser: yearLesser,
      yearGreater: yearGreater,
      episodeLesser: episodeLesser,
      episodeGreater: episodeGreater,
      durationLesser: durationLesser,
      durationGreater: durationGreater,
      onList: onList,
      isLicensed: isLicensed,
      licensedBy: licensedBy,
      minimumTagRank: minimumTagRank,
      countryOfOrigin: countryOfOrigin,
      source: _parseSource(source),
      sort: sort.map((s) => _parseSort(s)).whereType<Enum$MediaSort>().toList(),
      isAdult: isAdult ?? false,
    );

    final result = await executeQuery<Query$SearchAnime>(
      options: QueryOptions(
        document: documentNodeQuerySearchAnime,
        variables: variables.toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'searchAnime',
      parser: (data) => Query$SearchAnime.fromJson(data),
    );

    if (result == null || result.Page == null) return null;

    final pageInfo = AnilistPageInfo(
      total: result.Page!.pageInfo?.total ?? 0,
      perPage: result.Page!.pageInfo?.perPage ?? 0,
      currentPage: result.Page!.pageInfo?.currentPage ?? 1,
      lastPage: result.Page!.pageInfo?.lastPage ?? 1,
      hasNextPage: result.Page!.pageInfo?.hasNextPage ?? false,
    );

    final mediaList = result.Page!.media
            ?.whereType<Query$SearchAnime$Page$media>()
            .map((media) => AnimeCard.fromFragment(media)) // TODO fromFragment accepts Fragment$AnimeCard but given Query$SearchAnime$Page$media
            .toList() ??
        [];

    return AnilistSearchPage(pageInfo: pageInfo, results: mediaList);
  }
}

  