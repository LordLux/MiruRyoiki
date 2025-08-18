part of 'anilist_service.dart';

extension AnilistServiceSearch on AnilistService {
  /// Search for anime by title
  Future<List<AnilistAnime>> searchAnime(String query, {int limit = 10}) async {
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
    const searchQuery = r'''
      query SearchAnime($search: String, $limit: Int) {
        Page(perPage: $limit) {
          media(type: ANIME, search: $search) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              extraLarge
              color
            }
            bannerImage
            description
            popularity
            averageScore
            episodes
            format
            status
            seasonYear
            season
            
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
            updatedAt
            nextAiringEpisode {
              airingAt
              episode
              timeUntilAiring
            }
            isFavourite
            siteUrl
          }
        }
      }
    ''';

    try {
      final result = await RetryUtils.retry<List<AnilistAnime>>(
        () async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(searchQuery),
              variables: {
                'search': query,
                'limit': limit,
              },
            ),
          );

          if (queryResult.hasException) {
            throw Exception('Error searching Anilist: ${queryResult.exception}');
          }

          final List<dynamic> media = queryResult.data?['Page']['media'] ?? [];
          return media.map((item) => AnilistAnime.fromJson(item)).toList();
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'searchAnime(query: $query)',
      );

      return result ?? [];
    } catch (e) {
      logErr('Error querying Anilist', e);
      return [];
    }
  }
}
