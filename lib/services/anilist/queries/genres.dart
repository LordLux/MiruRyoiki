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

    try {
      final result = await _client!.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) throw Exception('Error fetching genres: ${result.exception}');

      final List<dynamic> genresData = result.data?['GenreCollection'] ?? [];
      final List<String> genres = genresData.cast<String>();

      // Save to settings
      if (genres.isNotEmpty) Manager.settings.genres = genres;

      return genres;
    } catch (e) {
      logErr('Error fetching genres: $e');
      return Manager.settings.genres;
    }
  }
}
