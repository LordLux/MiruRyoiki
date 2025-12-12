part of 'anilist_service.dart';

extension AnilistServiceSearch on AnilistService {
  Map<String, dynamic> _getSeasonData(DateTime date) {
    // 1 = Winter, 2 = Spring, 3 = Summer, 4 = Fall
    // Standard Anime Seasons:
    // Winter: Jan, Feb, Mar
    // Spring: Apr, May, Jun
    // Summer: Jul, Aug, Sep
    // Fall: Oct, Nov, Dec
    
    int month = date.month;
    String season;
    int year = date.year;

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
  
  Map<String, dynamic> _getNextSeasonData() {
    DateTime now = DateTime.now();
    // Add 3 months to roughly jump to next season, then recalculate
    return _getSeasonData(now.add(const Duration(days: 90))); 
  }
  
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
        (bool isOffline) async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(searchQuery),
              variables: {
                'search': query,
                'limit': limit,
              },
              fetchPolicy: isOffline ? FetchPolicy.cacheOnly : FetchPolicy.cacheFirst,
            ),
          );

          if (queryResult.hasException) {
            // Check if offline before throwing
            if (RetryUtils.isExpectedOfflineError(queryResult.exception)) return <AnilistAnime>[];

            throw Exception('Error searching Anilist: ${queryResult.exception}');
          }

          final List<dynamic> media = queryResult.data?['Page']['media'] ?? [];
          return media.map((item) => AnilistAnime.fromJson(item)).toList();
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'searchAnime(query: $query)',
        isOfflineAware: true,
      );

      return result ?? [];
    } catch (e) {
      if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
        logDebug('Skipping anime search - device is offline');
        return [];
      }
      logErr('Error querying Anilist', e);
      return [];
    }
  }
}
