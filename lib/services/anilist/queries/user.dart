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

    return await executeQuery<AnilistUser?>(
      options: QueryOptions(
        document: gql(userQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'getCurrentUser',
      parser: (data) {
        final user = data['Viewer'];
        return user != null ? AnilistUser.fromJson(user) : null;
      },
    );
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
    return await executeQuery<AnilistUserData?>(
      options: QueryOptions(
        document: gql(userQuery),
        fetchPolicy: FetchPolicy.networkOnly,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
      operationName: 'getCurrentUserData',
      parser: (data) {
        final userData = data['Viewer'];
        return userData != null ? AnilistUserData.fromJson(userData) : null;
      },
    );
  }
}
