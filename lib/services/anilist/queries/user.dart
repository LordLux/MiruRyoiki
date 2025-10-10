part of 'anilist_service.dart';

extension AnilistServiceUser on AnilistService {
  /// Get current user information
  Future<AnilistUser?> getCurrentUser() async {
    if (_client == null) return null;

    logTrace('Fetching current user info from Anilist...');

    const userQuery = r'''
      query {
        Viewer {
          id
          name
          avatar {
            large
          }
          bannerImage
        }
      }
    ''';

    try {
      final result = await RetryUtils.retry<QueryResult>(
        (bool isOffline) async {
          return await _client!.query(
            QueryOptions(
              document: gql(userQuery),
              fetchPolicy: isOffline ? FetchPolicy.cacheOnly : FetchPolicy.networkOnly,
            ),
          );
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'getCurrentUser',
        isOfflineAware: true,
      );

      if (result == null) {
        logDebug('No user info available (offline with no cache)');
        return null;
      }

      if (result.hasException) {
        if (RetryUtils.isExpectedOfflineError(result.exception)) {
          logDebug('Skipping user info fetch - offline status');
          return null;
        }
        logErr('Error getting user info', result.exception);
        return null;
      }

      final user = result.data?['Viewer'];
      return user != null ? AnilistUser.fromJson(user) : null;
    } catch (e) {
      if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
        logDebug('Skipping user info query - device is offline');
        return null;
      }
      logErr('Error querying Anilist', e);
      return null;
    }
  }

  Future<AnilistUserData?> getCurrentUserData() async {
    if (_client == null) return null;

    logTrace('Fetching current user data from Anilist...');

    final userQuery = '''query {
    Viewer {
      about
      siteUrl
      options {
        titleLanguage
        displayAdultContent
        airingNotifications
        profileColor
        timezone
        activityMergeTime
        restrictMessagesToFollowing
        staffNameLanguage
      }
      favourites {
        anime {
          nodes {
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
            seasonYear
            format
            siteUrl
          }
        }
        characters {
          nodes {
            id
            name {
              full
              native
            }
            image {
              large
            }
            siteUrl
          }
        }
        staff {
          nodes {
            id
            name {
              full
              native
            }
            image {
              large
            }
            siteUrl
          }
        }
        studios {
          nodes {
            id
            name
            siteUrl
          }
        }
      }
      stats {
        activityHistory {
          date
          amount
          level
        }
      }
      statistics {
        anime {
          count
          meanScore
          standardDeviation
          minutesWatched
          episodesWatched
          genres {
            genre
            count
            meanScore
            minutesWatched
          }
          tags {
            tag {
              id
              name
            }
            count
            meanScore
            minutesWatched
          }
          formats {
            format
            count
            meanScore
            minutesWatched
          }
          statuses {
            status
            count
            meanScore
            minutesWatched
          }
        }
      }
      donatorTier
      donatorBadge
      createdAt
      updatedAt
    }
  }
  ''';
    try {
      final result = await RetryUtils.retry<AnilistUserData?>(
        (bool isOffline) async {
          final queryResult = await _client!.query(
            QueryOptions(
              document: gql(userQuery),
              fetchPolicy: isOffline ? FetchPolicy.cacheOnly : FetchPolicy.networkOnly,
              cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
            ),
          );

          if (queryResult.hasException) {
            // Check if offline before throwing
            if (RetryUtils.isExpectedOfflineError(queryResult.exception)) return null;

            if (queryResult.exception is OperationException && //
                queryResult.exception!.linkException is UnknownException &&
                queryResult.exception!.linkException!.originalException is TimeoutException) {
              throw TimeoutException('Anilist user info GET request timed out', const Duration(seconds: 30));
            }
            throw Exception('Error getting user info data: ${queryResult.exception}');
          }

          final userData = queryResult.data?['Viewer'];
          return userData != null ? AnilistUserData.fromJson(userData) : null;
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'getCurrentUserData',
        isOfflineAware: true,
      );

      return result;
    } catch (e) {
      if (ConnectivityService().isOffline && RetryUtils.isExpectedOfflineError(e)) {
        logDebug('Skipping user data query - device is offline');
        return null;
      }
      logErr('Error querying Anilist', e);
      return null;
    }
  }
}
