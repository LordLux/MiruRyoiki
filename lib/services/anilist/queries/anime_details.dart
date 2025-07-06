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
      final result = await _client!.query(
        QueryOptions(
          document: gql(detailsQuery),
          variables: {
            'id': id,
          },
        ),
      );

      if (result.hasException) {
        logErr('Error getting anime details', result.exception);
        return null;
      }

      final media = result.data?['Media'];
      return media != null ? AnilistAnime.fromJson(media) : null;
    } catch (e) {
      logErr('Error querying Anilist', e);
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
      final result = await _client!.query(
        QueryOptions(
          document: gql(batchQuery),
          variables: {
            'ids': ids,
          },
        ),
      );

      if (result.hasException) {
        logErr('Error getting anime details', result.exception);
        return {};
      }

      final mediaList = result.data?['Page']['media'] as List<dynamic>? ?? [];
      final Map<int, AnilistAnime> animeMap = {};

      for (final item in mediaList) {
        final anime = AnilistAnime.fromJson(item);
        animeMap[anime.id] = anime;
      }

      return animeMap;
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
      final result = await _client!.query(
        QueryOptions(
          document: gql(listsQuery),
          variables: variables,
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        logErr('2 | Error getting anime lists', result.exception);
        return {};
      }

      final mediaListCollection = result.data?['MediaListCollection'];
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
            _formatStatusName(status),
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
    } catch (e) {
      logErr('Error querying Anilist', e);
      return {};
    }
  }
}
