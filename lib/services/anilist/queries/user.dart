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
      final result = await _client!.query(
        QueryOptions(
          document: gql(userQuery),
        ),
      );

      if (result.hasException) {
        logErr('Error getting user info', result.exception);
        return null;
      }

      final user = result.data?['Viewer'];
      return user != null ? AnilistUser.fromJson(user) : null;
    } catch (e) {
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
      final result = await _client!.query(
        QueryOptions(
          document: gql(userQuery),
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        if (result.exception is OperationException && result.exception!.linkException is UnknownException && result.exception!.linkException!.originalException is TimeoutException) {
          logWarn('Anilist user info GET request timed out');
          return null;
        }
        logErr('Error getting user info data', result.exception);
        return null;
      }

      final userData = result.data?['Viewer'];
      return userData != null ? AnilistUserData.fromJson(userData) : null;
    } catch (e) {
      logErr('Error querying Anilist', e);
      return null;
    }
  }
}
