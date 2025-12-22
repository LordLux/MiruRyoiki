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

    const query = r'''
      query GenreCollection {
        GenreCollection
      }
    ''';

    final result = await executeQuery<List<String>>(
      options: QueryOptions(
        document: gql(query),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'getGenres',
      parser: (data) {
        final List<dynamic> genresData = data['GenreCollection'] ?? [];
        return genresData.cast<String>();
      },
    );

    if (result != null && result.isNotEmpty) {
      Manager.settings.genres = result;
      return result;
    }

    return Manager.settings.genres;
  }
}
