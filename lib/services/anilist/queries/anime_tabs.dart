part of 'anilist_service.dart';

extension AnilistServiceAnimeTabs on AnilistService {
  // Characters
  Future<({List<CharacterEdge> characters, AnilistPageInfo pageInfo})?> getAnimeCharacters(
    int id, {
    int page = 1,
  }) async {
    if (_client == null) return null;

    logTrace('Fetching characters for media ID $id (page $page)');

    final result = await executeQuery<Query$GetAnimeCharacters>(
      options: QueryOptions(
        document: documentNodeQueryGetAnimeCharacters,
        variables: Variables$Query$GetAnimeCharacters(id: id, page: page).toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetAnimeCharacters',
      parser: (data) => Query$GetAnimeCharacters.fromJson(data),
    );

    final chars = result?.Media?.characters;
    if (chars == null) return null;

    final pi = chars.pageInfo;
    final edges = chars.edges //
            ?.whereType<Query$GetAnimeCharacters$Media$characters$edges>()
            .map(CharacterEdge.fromFullQuery)
            .toList() ??
        [];

    return (
      characters: edges,
      pageInfo: AnilistPageInfo(
        total: pi?.total ?? 0,
        perPage: pi?.perPage ?? 25,
        currentPage: pi?.currentPage ?? page,
        lastPage: pi?.lastPage ?? 1,
        hasNextPage: pi?.hasNextPage ?? false,
      ),
    );
  }

  // Staff
  Future<({List<StaffEdge> staff, AnilistPageInfo pageInfo})?> getAnimeStaff(
    int id, {
    int page = 1,
  }) async {
    if (_client == null) return null;

    logTrace('Fetching staff for media ID $id (page $page)');

    final result = await executeQuery<Query$GetAnimeStaff>(
      options: QueryOptions(
        document: documentNodeQueryGetAnimeStaff,
        variables: Variables$Query$GetAnimeStaff(id: id, page: page).toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetAnimeStaff',
      parser: (data) => Query$GetAnimeStaff.fromJson(data),
    );

    final staffData = result?.Media?.staff;
    if (staffData == null) return null;

    final pi = staffData.pageInfo;
    final edges = staffData.edges //
            ?.whereType<Query$GetAnimeStaff$Media$staff$edges>()
            .map(StaffEdge.fromFullQuery)
            .toList() ??
        [];

    return (
      staff: edges,
      pageInfo: AnilistPageInfo(
        total: pi?.total ?? 0,
        perPage: pi?.perPage ?? 25,
        currentPage: pi?.currentPage ?? page,
        lastPage: pi?.lastPage ?? 1,
        hasNextPage: pi?.hasNextPage ?? false,
      ),
    );
  }

  // Social
  Future<({List<MediaListSocial> social, AnilistPageInfo pageInfo})?> getAnimeSocial(
    int id, {
    int page = 1,
  }) async {
    if (_client == null) return null;

    logTrace('Fetching social activity for media ID $id (page $page)');

    final result = await executeQuery<Query$GetAnimeSocial>(
      options: QueryOptions(
        document: documentNodeQueryGetAnimeSocial,
        variables: Variables$Query$GetAnimeSocial(id: id, page: page).toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetAnimeSocial',
      parser: (data) => Query$GetAnimeSocial.fromJson(data),
    );

    final pageData = result?.Page;
    if (pageData == null) return null;

    final pi = pageData.pageInfo;
    final items = pageData.mediaList //
            ?.whereType<Query$GetAnimeSocial$Page$mediaList>()
            .map(MediaListSocial.fromFragment)
            .toList() ??
        [];

    return (
      social: items,
      pageInfo: AnilistPageInfo(
        total: pi?.total ?? 0,
        perPage: pi?.perPage ?? 25,
        currentPage: pi?.currentPage ?? page,
        lastPage: pi?.lastPage ?? 1,
        hasNextPage: pi?.hasNextPage ?? false,
      ),
    );
  }

  // Stats
  Future<AnimeStatsFull?> getAnimeStats(int id) async {
    if (_client == null) return null;

    logTrace('Fetching stats for media ID $id');

    final result = await executeQuery<Query$GetAnimeStats>(
      options: QueryOptions(
        document: documentNodeQueryGetAnimeStats,
        variables: Variables$Query$GetAnimeStats(id: id).toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetAnimeStats',
      parser: (data) => Query$GetAnimeStats.fromJson(data),
    );

    if (result?.Media == null) return null;
    return AnimeStatsFull.fromQuery(result!.Media!);
  }
}
