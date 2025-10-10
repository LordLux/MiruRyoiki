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
        (bool isOffline) async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(detailsQuery),
              variables: {
                'id': id,
              },
              fetchPolicy: isOffline ? FetchPolicy.cacheOnly : FetchPolicy.cacheFirst,
            ),
          );

          if (queryResult.hasException) {
            // Check if offline before throwing
            if (RetryUtils.isExpectedOfflineError(queryResult.exception)) return null;

            if (queryResult.exception is OperationException && //
                queryResult.exception!.linkException is UnknownException &&
                queryResult.exception!.linkException!.originalException is TimeoutException) {
              throw TimeoutException('Anilist anime details GET request timed out');
            }
            if (queryResult.exception is OperationException && //
                queryResult.exception!.linkException is ServerException &&
                queryResult.exception!.linkException!.originalException is HandshakeException ||
                queryResult.exception!.linkException!.originalException is ClientException) {
              throw HandshakeException('Anilist anime details GET request no internet connection');
            }
            throw Exception('Error getting anime details: ${queryResult.exception}');
          }

          final media = queryResult.data?['Media'];
          return media != null ? AnilistAnime.fromJson(media) : null;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'getAnimeDetails(id: $id)',
        isOfflineAware: true,
      );

      return result;
    } catch (e, stackTrace) {
      if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
        logDebug('Skipping anime details query - device is offline');
        return null;
      }
      logErr('Error querying Anilist anime details', e, stackTrace);
      return null;
    }
  }

  /// Get detailed anime information by ID
  Future<Map<int, AnilistAnime>> getMultipleAnimesDetails(List<int> ids, {int perPage = 50}) async {
    if (_client == null) return <int, AnilistAnime>{};

    // AniList API has a limit of 50 items per page, so we need to chunk large requests
    final Map<int, AnilistAnime> allResults = {};

    // Process in chunks of maxChunkSize to respect API limits
    const int maxChunkSize = 50;

    for (int i = 0; i < ids.length; i += maxChunkSize) {
      final chunkEnd = (i + maxChunkSize < ids.length) ? i + maxChunkSize : ids.length;
      final chunk = ids.sublist(i, chunkEnd);

      // log('${i ~/ maxChunkSize + 1} | Fetching chunk ${i ~/ maxChunkSize + 1}/${(ids.length / maxChunkSize).ceil()}: ${chunk.length} IDs');

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
          (bool isOffline) async {
            final queryResult = await _client!.query(
              QueryOptions(
                document: gql(batchQuery),
                variables: {
                  'ids': chunk,
                },
                fetchPolicy: isOffline ? FetchPolicy.cacheOnly : FetchPolicy.cacheFirst,
              ),
            );

            if (queryResult.hasException) {
              // Check if offline before throwing
              if (RetryUtils.isExpectedOfflineError(queryResult.exception)) return <int, AnilistAnime>{};

              if (queryResult.exception is OperationException && //
                  queryResult.exception!.linkException is UnknownException &&
                  queryResult.exception!.linkException!.originalException is TimeoutException) {
                throw TimeoutException('Anilist animes details GET request timed out');
              }
              if (queryResult.exception is OperationException && //
                  queryResult.exception!.linkException is ServerException &&
                  queryResult.exception!.linkException!.originalException is HandshakeException ||
                  queryResult.exception!.linkException!.originalException is ClientException) {
                throw HandshakeException('Anilist animes details GET request no internet connection');
              }
              throw Exception('Error getting anime details: ${queryResult.exception}');
            }

            final mediaList = queryResult.data?['Page']['media'] as List<dynamic>? ?? [];
            final Map<int, AnilistAnime> chunkResults = {};

            for (final item in mediaList) {
              final anime = AnilistAnime.fromJson(item);
              chunkResults[anime.id] = anime;
            }

            logTrace('${i ~/ maxChunkSize + 1} | Fetched details for ${chunkResults.length} out of ${chunk.length} requested AniList IDs');

            return chunkResults;
          },
          maxRetries: 3,
          retryIf: RetryUtils.shouldRetryAnilistError,
          operationName: 'getMultipleAnimesDetails(chunk: ${chunk.length} items)',
          isOfflineAware: true,
        );

        // Merge chunk results into the overall results
        if (result != null) allResults.addAll(result);

        // Log missing IDs for this chunk
        final missingIds = chunk.where((id) => !allResults.containsKey(id)).toList();
        if (missingIds.isNotEmpty) {
          if (ConnectivityService().isOffline)
            logWarn('Failed to fetch AniList details for ${missingIds.length} Animes - device is offline');
          else
            logWarn('Failed to fetch AniList details for ${missingIds.length} Animes - animes may not exist or be restricted');
        }
      } catch (e) {
        if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
          logDebug('Skipping anime details chunk ${i ~/ maxChunkSize + 1} - device is offline');
        } else {
          logErr('Error querying Anilist chunk ${i ~/ maxChunkSize + 1}', e);

          // Log all IDs in this chunk as failed
          if (ConnectivityService().isOffline)
            logWarn('Failed to fetch AniList details for ${chunk.length} animes - device is offline');
          else
            logWarn('Failed to fetch AniList details for ${chunk.length} animes - chunk request failed');
        }
      }
    }

    logTrace('Fetched details for ${allResults.length} out of ${ids.length} requested AniList IDs');
    return allResults;
  }

  /// Get user anime lists (watching, completed, etc.)
  Future<Map<String, AnilistUserList>> getUserAnimeLists({String? userName, int? userId}) async {
    if (_client == null) return <String, AnilistUserList>{};

    if (userName == null && userId == null) {
      logWarn('No user identifier provided for fetching anime lists');
      return <String, AnilistUserList>{};
    }

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
        (bool isOffline) async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(listsQuery),
              variables: variables,
              fetchPolicy: isOffline ? FetchPolicy.cacheOnly : FetchPolicy.networkOnly,
            ),
          );

          if (queryResult.hasException) {
            // Check if offline before throwing
            if (RetryUtils.isExpectedOfflineError(queryResult.exception)) return <String, AnilistUserList>{};

            if (queryResult.exception is OperationException && //
                queryResult.exception!.linkException is UnknownException &&
                queryResult.exception!.linkException!.originalException is TimeoutException) {
              throw TimeoutException('Anilist anime lists GET request timed out');
            }
            if (queryResult.exception is OperationException && //
                queryResult.exception!.linkException is ServerException &&
                queryResult.exception!.linkException!.originalException is HandshakeException ||
                queryResult.exception!.linkException!.originalException is ClientException) {
              throw HandshakeException('Anilist anime lists GET request no internet connection');
            }
            throw Exception('2 | Error getting anime lists: ${queryResult.exception}');
          }

          final mediaListCollection = queryResult.data?['MediaListCollection'];
          if (mediaListCollection == null) return <String, AnilistUserList>{};

          final Map<String, AnilistUserList> lists = <String, AnilistUserList>{};

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
        isOfflineAware: true,
      );

      return result ?? <String, AnilistUserList>{};
    } catch (e) {
      if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
        logDebug('Skipping anime lists query - device is offline');
        return <String, AnilistUserList>{};
      }
      logErr('Error querying Anilist', e);
      return <String, AnilistUserList>{};
    }
  }

  /// Get upcoming episodes for a list of anime IDs
  Future<Map<int, AiringEpisode?>> getUpcomingEpisodes(List<int> animeIds) async {
    if (_client == null || animeIds.isEmpty) return <int, AiringEpisode?>{};

    logTrace('Fetching upcoming episodes for anime IDs: $animeIds');

    // AniList API has a limit of 50 items per page, so we need to chunk large requests
    final Map<int, AiringEpisode?> allResults = {};

    // Process in chunks of maxChunkSize to respect API limits
    const int maxChunkSize = 50;

    for (int i = 0; i < animeIds.length; i += maxChunkSize) {
      final chunkEnd = (i + maxChunkSize < animeIds.length) ? i + maxChunkSize : animeIds.length;
      final chunk = animeIds.sublist(i, chunkEnd);

      logTrace('Fetching upcoming episodes chunk ${i ~/ maxChunkSize + 1}/${(animeIds.length / maxChunkSize).ceil()}: ${chunk.length} IDs');

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
              episodes
            }
          }
        }
      ''';

      try {
        final result = await RetryUtils.retry<Map<int, AiringEpisode?>>(
          (bool isOffline) async {
            final queryResult = await _client!.query(
              QueryOptions(
                document: gql(upcomingEpisodesQuery),
                variables: {'ids': chunk},
                fetchPolicy: isOffline ? FetchPolicy.cacheOnly : FetchPolicy.cacheFirst,
              ),
            );

            if (queryResult.hasException) {
              // Check if offline before throwing
              if (RetryUtils.isExpectedOfflineError(queryResult.exception)) return <int, AiringEpisode?>{};

              if (queryResult.exception is OperationException && //
                  queryResult.exception!.linkException is UnknownException &&
                  queryResult.exception!.linkException!.originalException is TimeoutException) {
                throw TimeoutException('Anilist upcoming episodes GET request timed out');
              }
              if (queryResult.exception is OperationException && //
                  queryResult.exception!.linkException is ServerException &&
                  queryResult.exception!.linkException!.originalException is HandshakeException ||
                  queryResult.exception!.linkException!.originalException is ClientException) {
                throw HandshakeException('Anilist upcoming episodes GET request no internet connection');
              }
              throw Exception('Error getting upcoming episodes: ${queryResult.exception}');
            }

            final Map<int, AiringEpisode?> chunkResults = {};
            final mediaList = queryResult.data?['Page']?['media'] as List<dynamic>?;

            if (mediaList != null) {
              for (final media in mediaList) {
                final int? id = media['id'];
                final nextAiringData = media['nextAiringEpisode'];

                if (id != null) {
                  if (nextAiringData != null) {
                    chunkResults[id] = AiringEpisode.fromJson(nextAiringData);
                  } else {
                    chunkResults[id] = null; // No upcoming episode
                  }
                }
              }
            }

            logTrace('Found ${chunkResults.length} upcoming episodes for ${chunk.length} anime in chunk');
            return chunkResults;
          },
          maxRetries: 3,
          retryIf: RetryUtils.shouldRetryAnilistError,
          operationName: 'getUpcomingEpisodes(chunk: ${chunk.length} anime)',
          isOfflineAware: true,
        );

        // Merge chunk results into the overall results
        if (result != null) {
          allResults.addAll(result);
        }
      } catch (e) {
        if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
          logDebug('Skipping upcoming episodes chunk ${i ~/ maxChunkSize + 1} - device is offline');
        } else {
          logErr('Error querying upcoming episodes for chunk ${i ~/ maxChunkSize + 1}', e);
        }
      }
    }

    if (allResults.isNotEmpty) logTrace('Found ${allResults.length} upcoming episodes for ${animeIds.length} anime total');
    return allResults;
  }

  /// Get episode titles for a specific anime using MediaStreamingEpisode
  Future<Map<int, String>> getEpisodeTitles(int animeId) async {
    if (_client == null) return <int, String>{};

    logTrace('Fetching episode titles for anime ID: $animeId');

    const String episodeTitlesQuery = '''
      query GetEpisodeTitles(\$id: Int!) {
        Media(id: \$id, type: ANIME) {
          id
          streamingEpisodes {
            title
          }
        }
      }
    ''';

    try {
      final result = await RetryUtils.retry<Map<int, String>>(
        (bool isOffline) async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(episodeTitlesQuery),
              variables: {'id': animeId},
              fetchPolicy: isOffline ? FetchPolicy.cacheOnly : FetchPolicy.cacheFirst,
            ),
          );

          if (queryResult.hasException) {
            // Check if offline before throwing
            if (RetryUtils.isExpectedOfflineError(queryResult.exception)) return <int, String>{};

            if (queryResult.exception is OperationException && //
                queryResult.exception!.linkException is UnknownException &&
                queryResult.exception!.linkException!.originalException is TimeoutException) {
              throw TimeoutException('Anilist episode titles GET request timed out');
            }
            if (queryResult.exception is OperationException && //
                queryResult.exception!.linkException is ServerException &&
                queryResult.exception!.linkException!.originalException is HandshakeException ||
                queryResult.exception!.linkException!.originalException is ClientException) {
              throw HandshakeException('Anilist episode titles GET request no internet connection');
            }
            throw Exception('Error fetching episode titles: ${queryResult.exception}');
          }

          final Map<int, String> episodeTitles = {};
          final mediaData = queryResult.data?['Media'];

          if (mediaData != null) {
            final streamingEpisodes = mediaData['streamingEpisodes'] as List<dynamic>? ?? [];

            for (final episodeData in streamingEpisodes) {
              final title = episodeData['title'] as String?;
              if (title != null && title.isNotEmpty) {
                // Parse episode number from title (format: "Episode DD - Title")
                final match = RegExp(r'^Episode\s+(\d+)').firstMatch(title);
                if (match != null) {
                  final episodeNumber = int.tryParse(match.group(1)!);
                  if (episodeNumber != null) {
                    episodeTitles[episodeNumber] = title;
                  }
                }
              }
            }
          }

          logTrace('Fetched ${episodeTitles.length} episode titles for anime $animeId');
          return episodeTitles;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'getEpisodeTitles(anime: $animeId)',
        isOfflineAware: true,
      );

      return result ?? <int, String>{};
    } catch (e) {
      logErr('Error querying episode titles for anime $animeId', e);
      return <int, String>{};
    }
  }

  /// Get episode titles for multiple anime IDs in batches
  Future<Map<int, Map<int, String>>> getMultipleEpisodeTitles(List<int> animeIds, {int perPage = 50}) async {
    if (_client == null || animeIds.isEmpty) return <int, Map<int, String>>{};

    logTrace('Fetching episode titles for ${animeIds.length} anime IDs');

    // AniList API has a limit of 50 items per page, so we need to chunk large requests
    final Map<int, Map<int, String>> allResults = {};

    // Process in chunks of maxChunkSize to respect API limits
    const int maxChunkSize = 50;

    for (int i = 0; i < animeIds.length; i += maxChunkSize) {
      final chunkEnd = (i + maxChunkSize < animeIds.length) ? i + maxChunkSize : animeIds.length;
      final chunk = animeIds.sublist(i, chunkEnd);

      logTrace('Fetching episode titles chunk ${i ~/ maxChunkSize + 1}/${(animeIds.length / maxChunkSize).ceil()}: ${chunk.length} IDs');
      // log('Fetching following ids: $chunk');

      const String batchEpisodeTitlesQuery = '''
        query GetMultipleEpisodeTitles(\$ids: [Int]) {
          Page(perPage: 50) {
            media(id_in: \$ids, type: ANIME) {
              id
              streamingEpisodes {
                title
              }
            }
          }
        }
      ''';

      try {
        final result = await RetryUtils.retry<Map<int, Map<int, String>>>(
          (bool isOffline) async {
            final queryResult = await _client!.query(
              QueryOptions(
                document: gql(batchEpisodeTitlesQuery),
                variables: {'ids': chunk},
                fetchPolicy: isOffline ? FetchPolicy.cacheOnly : FetchPolicy.cacheFirst,
              ),
            );

            if (queryResult.hasException) {
              // Check if offline before throwing
              if (RetryUtils.isExpectedOfflineError(queryResult.exception)) return <int, Map<int, String>>{};

              if (queryResult.exception is OperationException && //
                  queryResult.exception!.linkException is UnknownException &&
                  queryResult.exception!.linkException!.originalException is TimeoutException) {
                throw TimeoutException('Anilist episode titles batch GET request timed out');
              }
              if (queryResult.exception is OperationException && //
                      queryResult.exception!.linkException is ServerException &&
                      queryResult.exception!.linkException!.originalException is HandshakeException ||
                  queryResult.exception!.linkException!.originalException is ClientException) {
                throw HandshakeException('Anilist episode titles batch GET request no internet connection');
              }
              throw Exception('Error fetching episode titles batch: ${queryResult.exception}');
            }

            final Map<int, Map<int, String>> chunkResults = {};
            final mediaList = queryResult.data?['Page']?['media'] as List<dynamic>? ?? [];
            final List<int> animeWithEpisodes = [];
            final List<int> animeWithoutEpisodes = [];
            final List<int> animeNotFound = chunk.toList();

            for (final mediaData in mediaList) {
              final animeId = mediaData['id'] as int?;
              if (animeId == null) continue;

              // Remove from not found list since we got a response for this ID
              animeNotFound.remove(animeId);

              final Map<int, String> episodeTitles = {};
              final streamingEpisodes = mediaData['streamingEpisodes'] as List<dynamic>? ?? [];

              if (streamingEpisodes.isEmpty) {
                animeWithoutEpisodes.add(animeId);
              } else {
                for (final episodeData in streamingEpisodes) {
                  final title = episodeData['title'] as String?;
                  if (title != null && title.isNotEmpty) {
                    // Parse episode number from title (format: "Episode DD - Title")
                    final match = RegExp(r'^Episode\s+(\d+)').firstMatch(title);
                    if (match != null) {
                      final episodeNumber = int.tryParse(match.group(1)!);
                      if (episodeNumber != null) episodeTitles[episodeNumber] = title;
                    }
                  }
                }

                if (episodeTitles.isNotEmpty) {
                  chunkResults[animeId] = episodeTitles;
                  animeWithEpisodes.add(animeId);
                } else {
                  // Had streamingEpisodes data but no parseable titles
                  animeWithoutEpisodes.add(animeId);
                }
              }
            }

            // Log detailed breakdown
            logTrace('  Chunk ${i ~/ maxChunkSize + 1} episode title results:');
            // log('    ${animeWithEpisodes.length} anime with episode titles: $animeWithEpisodes');
            if (animeWithoutEpisodes.isNotEmpty) logTrace('    ${animeWithoutEpisodes.length} anime with empty/unparseable episodes: $animeWithoutEpisodes');
            if (animeNotFound.isNotEmpty) logTrace('    ${animeNotFound.length} anime not found in AniList: $animeNotFound');

            logTrace('Fetched episode titles for ${chunkResults.length} out of ${chunk.length} anime in chunk (${animeWithEpisodes.length} with episodes, ${animeWithoutEpisodes.length} without, ${animeNotFound.length} not found)');
            return chunkResults;
          },
          maxRetries: 3,
          retryIf: RetryUtils.shouldRetryAnilistError,
          operationName: 'getMultipleEpisodeTitles(chunk: ${chunk.length} anime)',
          isOfflineAware: true,
        );

        // Merge chunk results into the overall results
        if (result != null) {
          allResults.addAll(result);
        }
      } catch (e) {
        if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
          logDebug('Skipping episode titles chunk ${i ~/ maxChunkSize + 1} - device is offline');
        } else {
          logErr('Error querying episode titles for chunk ${i ~/ maxChunkSize + 1}', e);
        }
      }
    }

    // Calculate final statistics
    final totalWithEpisodes = allResults.length;
    final totalRequested = animeIds.length;
    final totalWithoutEpisodes = totalRequested - totalWithEpisodes;

    // logTrace('Episode titles batch summary:');
    // logTrace(' $totalWithEpisodes anime with episode titles');
    // logTrace(' $totalWithoutEpisodes anime without episode titles');
    // logTrace(' Success rate: ${(totalWithEpisodes / totalRequested * 100).toStringAsFixed(1)}%');

    logTrace('Fetched episode titles for $totalWithEpisodes out of $totalRequested anime total ($totalWithoutEpisodes without any streamingepisodes)');
    return allResults;
  }
}
