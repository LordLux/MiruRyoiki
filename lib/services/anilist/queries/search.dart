part of 'anilist_service.dart';

extension AnilistServiceSearch on AnilistService {
  /// Search for anime by title
  Future<List<AnilistAnime>> searchAnimeMatch(String query, {int limit = 10}) async {
    if (_client == null) {
      // Try to initialize if not already initialized
      if (isLoggedIn && !await initialize()) {
        logErr('Failed to initialize Anilist client');
        return [];
      }

      // Still null after attempted initialization
      if (_client == null) {
        logErr('Anilist client is null, cannot search');
        return [];
      }
    }

    logTrace('Searching Anilist for "$query"...');

    final result = await executeQuery<Query$SearchAnime>(
      options: QueryOptions(
        document: documentNodeQuerySearchAnime,
        variables: Variables$Query$SearchAnime(
          search: query,
          perPage: limit,
        ).toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'searchAnimeMatch',
      parser: (data) => Query$SearchAnime.fromJson(data),
    );

    if (result == null || result.Page == null || result.Page!.media == null) return [];

    return result.Page!.media!
        .whereType<Query$SearchAnime$Page$media>()
        .map((media) => AnilistAnime.fromSearchMedia(media))
        .toList();
  }
}
