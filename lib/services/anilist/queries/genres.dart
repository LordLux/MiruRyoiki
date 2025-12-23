part of 'anilist_service.dart';

extension AnilistServiceGenres on AnilistService {
  Future<List<String>> getGenres({bool forceRefresh = false}) async {
    // Return cached genres if available and not forcing refresh
    if (!forceRefresh && Manager.settings.genres.isNotEmpty) return Manager.settings.genres;

    if (_client == null) {
      if (isLoggedIn && !await initialize()) {
        logErr('Failed to initialize Anilist client');
        return Manager.settings.genres; // Return cached even if init fails
      }
      if (_client == null) {
        logErr('Anilist client is null, cannot fetch genres');
        return Manager.settings.genres;
      }
    }

    final result = await executeQuery<Query$GetGenreCollection>(
      options: QueryOptions(
        document: documentNodeQueryGetGenreCollection,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetGenreCollection',
      parser: (data) => Query$GetGenreCollection.fromJson(data),
    );

    if (result != null && result.GenreCollection != null) {
      final genres = result.GenreCollection!.whereType<String>().toList();
      Manager.settings.genres = genres;
      return genres;
    }

    return Manager.settings.genres;
  }
}
