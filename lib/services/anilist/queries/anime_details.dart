part of 'anilist_service.dart';

extension AnilistServiceAnimeDetails on AnilistService {
  /// Get detailed anime information by ID
  Future<AnilistAnime?> getAnimeDetails(int id) async {
    if (_client == null) return null;

    logTrace('Fetching Anilist details for ID: $id');

    const detailsQuery = r'''
      query GetAnimeDetails($id: Int!) {
        Media(id: $id, type: ANIME) {
          id
          title {
            romaji
            english
            native
            userPreferred
          }
          bannerImage
          coverImage {
            extraLarge
            color
          }
          description
          meanScore
          popularity
          favourites
          status
          format
          episodes
          seasonYear
          season
          genres
          averageScore
          trending
          rankings {
            rank
            type
            context
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
    ''';

    try {
      final result = await RetryUtils.retry<AnilistAnime?>(
        () async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(detailsQuery),
              variables: {
                'id': id,
              },
            ),
          );

          if (queryResult.hasException) {
            if (queryResult.exception is OperationException && 
                queryResult.exception!.linkException is UnknownException && 
                queryResult.exception!.linkException!.originalException is TimeoutException) {
              throw TimeoutException('Anilist anime details GET request timed out', const Duration(seconds: 30));
            }
            throw Exception('Error getting anime details: ${queryResult.exception}');
          }

          final media = queryResult.data?['Media'];
          return media != null ? AnilistAnime.fromJson(media) : null;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'getAnimeDetails(id: $id)',
      );

      return result;
    } catch (e, stackTrace) {
      logErr('Error querying Anilist anime details', e, stackTrace);
      return null;
    }
  }

  /// Get detailed anime information by ID
  Future<Map<int, AnilistAnime>> getMultipleAnimesDetails(List<int> ids, {int perPage = 50}) async {
    if (_client == null) return {};

    logTrace('Fetching Anilist details for IDs: $ids');

    final String batchQuery = '''
      query GetMultipleAnimesDetails(\$ids: [Int]) {
        Page(perPage: $perPage) {
          media(id_in: \$ids, type: ANIME) {
            id
            title {
              romaji
              english
              native
              userPreferred
            }
            bannerImage
            coverImage {
              extraLarge
              color
            }
            description
            meanScore
            popularity
            favourites
            status
            format
            episodes
            seasonYear
            season
            genres
            averageScore
            trending
            rankings {
              rank
              type
              context
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
      final result = await RetryUtils.retry<Map<int, AnilistAnime>>(
        () async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(batchQuery),
              variables: {
                'ids': ids,
              },
            ),
          );

          if (queryResult.hasException) {
            if (queryResult.exception is OperationException && 
                queryResult.exception!.linkException is UnknownException && 
                queryResult.exception!.linkException!.originalException is TimeoutException) {
              throw TimeoutException('Anilist animes details GET request timed out', const Duration(seconds: 30));
            }
            throw Exception('Error getting anime details: ${queryResult.exception}');
          }

          final mediaList = queryResult.data?['Page']['media'] as List<dynamic>? ?? [];
          final Map<int, AnilistAnime> animeMap = {};

          for (final item in mediaList) {
            final anime = AnilistAnime.fromJson(item);
            animeMap[anime.id] = anime;
          }

          return animeMap;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'getMultipleAnimesDetails(ids: ${ids.length} items)',
      );

      return result ?? {};
    } catch (e) {
      logErr('Error querying Anilist', e);
      return {};
    }
  }

  /// Get user anime lists (watching, completed, etc.)
  Future<Map<String, AnilistUserList>> getUserAnimeLists({String? userName, int? userId}) async {
    if (_client == null) return {};

    logTrace('2 | Fetching anime lists from Anilist for user $userName ($userId)...');

    const listsQuery = r'''
      query GetUserAnimeLists($userName: String, $userId: Int) {
        MediaListCollection(userName: $userName, userId: $userId, type: ANIME) {
          lists {
            name
            status
            entries {
              id
              mediaId
              status
              progress
              score(format: POINT_10)
              hiddenFromStatusLists
              priority
              createdAt
              updatedAt
              startedAt {
                year
                month
                day
              }
              completedAt {
                year
                month
                day
              }
              media {
                id
                title {
                  romaji
                  english
                  native
                  userPreferred
                }
                coverImage {
                  extraLarge
                  color
                }
                episodes
                format
                status
                seasonYear
                season
                nextAiringEpisode {
                  airingAt
                  episode
                  timeUntilAiring
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
                updatedAt
                isFavourite
                siteUrl
                mediaListEntry {
                  id
                }
              }
              customLists
            }
          }
          user {
            id
            name
            mediaListOptions {
              animeList {
                customLists
              }
            }
          }
        }
      }
    ''';

    try {
      final Map<String, dynamic> variables = {};
      if (userName != null) {
        variables['userName'] = userName;
      } else if (userId != null) {
        variables['userId'] = userId;
      }
      
      final result = await RetryUtils.retry<Map<String, AnilistUserList>>(
        () async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(listsQuery),
              variables: variables,
              fetchPolicy: FetchPolicy.noCache,
            ),
          );

          if (queryResult.hasException) {
            if (queryResult.exception is OperationException && 
                queryResult.exception!.linkException is UnknownException && 
                queryResult.exception!.linkException!.originalException is TimeoutException) {
              throw TimeoutException('Anilist anime lists GET request timed out', const Duration(seconds: 30));
            }
            throw Exception('2 | Error getting anime lists: ${queryResult.exception}');
          }

          final mediaListCollection = queryResult.data?['MediaListCollection'];
          if (mediaListCollection == null) return {};

          final Map<String, AnilistUserList> lists = {};

          final user = mediaListCollection['user'];
          final customListNames = user?['mediaListOptions']?['animeList']?['customLists'];

          final standardLists = mediaListCollection['lists'] as List<dynamic>? ?? [];
          // Standard lists (Watching, Completed, etc.)
          for (final list in standardLists) {
            final status = list['status'] as String?;
            if (status != null) {
              lists[status] = AnilistUserList.fromJson(
                {
                  'lists': [list]
                },
                StatusStatistic.statusNameToPretty(status),
              );
            }
          }

          // Custom lists
          if (customListNames != null) {
            for (final customListName in customListNames) {
              // Create a custom list with entries that have this custom list
              final entriesForCustomList = [];
              for (final list in standardLists) {
                for (final entry in list['entries'] ?? []) {
                  // Handle the customLists field properly
                  Map<String, dynamic>? entryCustomLists;

                  // Check what type of data we received
                  final customListsData = entry['customLists'];
                  if (customListsData is Map) {
                    // If it's already a Map, use it directly
                    entryCustomLists = Map<String, dynamic>.from(customListsData);
                  } else if (customListsData is String) {
                    try {
                      // Try to parse as JSON
                      entryCustomLists = jsonDecode(customListsData) as Map<String, dynamic>?;
                    } catch (e, stackTrace) {
                      // If JSON parsing fails, the string might not be proper JSON
                      logErr('Error parsing customLists', e, stackTrace);
                      logWarn('Raw customLists value: $customListsData');

                      // Continue to next entry, skip this one
                      continue;
                    }
                  } else if (customListsData != null) {
                    logErr('Unexpected customLists type: ${customListsData.runtimeType}');
                    continue;
                  } else {
                    // customLists is null
                    continue;
                  }

                  // Now check if this entry should be in this custom list
                  if (entryCustomLists != null && entryCustomLists.containsKey(customListName) && entryCustomLists[customListName] == true) {
                    entriesForCustomList.add(entry);
                  }
                }
              }

              if (entriesForCustomList.isNotEmpty) {
                lists['custom_$customListName'] = AnilistUserList.fromJson(
                  {
                    'lists': [
                      {'entries': entriesForCustomList}
                    ]
                  },
                  customListName,
                  isCustomList: true,
                );
              }
            }
          }

          return lists;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'getUserAnimeLists(user: $userName/$userId)',
      );

      return result ?? {};
    } catch (e) {
      logErr('Error querying Anilist', e);
      return {};
    }
  }

  /// Get upcoming episodes for a list of anime IDs
  Future<Map<int, AiringEpisode?>> getUpcomingEpisodes(List<int> animeIds) async {
    if (_client == null || animeIds.isEmpty) return {};

    logTrace('Fetching upcoming episodes for anime IDs: $animeIds');

    const String upcomingEpisodesQuery = '''
      query GetUpcomingEpisodes(\$ids: [Int]) {
        Page(perPage: 50) {
          media(id_in: \$ids, type: ANIME) {
            id
            nextAiringEpisode {
              airingAt
              episode
              timeUntilAiring
            }
            status
            format
          }
        }
      }
    ''';

    try {
      final result = await RetryUtils.retry<Map<int, AiringEpisode?>>(
        () async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(upcomingEpisodesQuery),
              variables: {'ids': animeIds},
              fetchPolicy: FetchPolicy.noCache, // Always get fresh airing data
            ),
          );

          if (queryResult.hasException) {
            if (queryResult.exception is OperationException && 
                queryResult.exception!.linkException is UnknownException && 
                queryResult.exception!.linkException!.originalException is TimeoutException) {
              throw TimeoutException('Anilist upcoming episodes GET request timed out', const Duration(seconds: 30));
            }
            throw Exception('Error getting upcoming episodes: ${queryResult.exception}');
          }

          final Map<int, AiringEpisode?> upcomingEpisodes = {};
          final mediaList = queryResult.data?['Page']?['media'] as List<dynamic>?;

          if (mediaList != null) {
            for (final media in mediaList) {
              final int? id = media['id'];
              final nextAiringData = media['nextAiringEpisode'];
              
              if (id != null) {
                if (nextAiringData != null) {
                  upcomingEpisodes[id] = AiringEpisode.fromJson(nextAiringData);
                } else {
                  upcomingEpisodes[id] = null; // No upcoming episode
                }
              }
            }
          }

          logTrace('Found upcoming episodes for ${upcomingEpisodes.length} series');
          return upcomingEpisodes;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'getUpcomingEpisodes(${animeIds.length} anime)',
      );

      return result ?? {};
    } catch (e) {
      logErr('Error querying upcoming episodes', e);
      return {};
    }
  }
}
