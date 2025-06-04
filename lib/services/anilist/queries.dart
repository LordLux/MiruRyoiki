import 'dart:convert';
import 'package:graphql/client.dart';
import '../../../models/anilist/anime.dart';
import '../../../models/anilist/user_list.dart';
import '../../main.dart';
import '../../manager.dart';
import '../../utils/logging.dart';
import 'auth.dart';

class AnilistService {
  // Singleton
  static final AnilistService _instance = AnilistService._internal();
  factory AnilistService() => _instance;
  AnilistService._internal() : _authService = AnilistAuthService();

  final AnilistAuthService _authService;
  GraphQLClient? _client;

  /// Initialize the service
  Future<bool> initialize() async {
    final authenticated = await _authService.init();

    if (authenticated) {
      logTrace('2 | Setting up GraphQL client...');
      _setupGraphQLClient();
      return true;
    }

    logTrace('2 | AnilistService initialization failed, not authenticated');
    return false;
  }

  /// Set up the GraphQL client
  void _setupGraphQLClient() {
    final authLink = AuthLink(
      getToken: () => 'Bearer ${_authService.client?.credentials.accessToken}',
    );

    final httpLink = HttpLink('https://graphql.anilist.co');
    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: authLink.concat(httpLink),
    );
    logTrace('2 | GraphQL client setup complete');
  }

  /// Start the login flow
  Future<void> login() async {
    await _authService.login();
  }

  /// Handle auth callback
  Future<bool> handleAuthCallback(Uri callbackUri) async {
    final success = await _authService.handleAuthCallback(callbackUri);
    if (success) {
      Manager.accounts.add('Anilist');
      // ignore: invalid_use_of_protected_member
      accountsKey.currentState?.setState(() {});
      _setupGraphQLClient();
    } else {
      await logout();
    }

    return success;
  }

  /// Logout from Anilist
  Future<void> logout() async {
    await _authService.logout();
    Manager.accounts.remove('Anilist');
    logInfo('Anilist logged out');
    _client = null;
  }

  /// Check if the user is logged in
  bool get isLoggedIn => _authService.isAuthenticated;

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
      final result = await _client!.query(
        QueryOptions(
          document: gql(searchQuery),
          variables: {
            'search': query,
            'limit': limit,
          },
        ),
      );

      if (result.hasException) {
        logErr('Error searching Anilist', result.exception);
        return [];
      }

      final List<dynamic> media = result.data?['Page']['media'] ?? [];
      return media.map((item) => AnilistAnime.fromJson(item)).toList();
    } catch (e) {
      logErr('Error querying Anilist', e);
      return [];
    }
  }

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

      final userData = result.data?['Viewer'];
      return userData != null ? AnilistUser.fromJson(userData) : null;
    } catch (e) {
      logErr('Error querying Anilist', e);
      return null;
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

  /// Update progress for an anime
  Future<bool> updateProgress(int mediaId, int progress) async {
    if (_client == null) return false;

    const mutation = r'''
    mutation UpdateProgress($mediaId: Int!, $progress: Int!) {
      SaveMediaListEntry(mediaId: $mediaId, progress: $progress) {
        id
        progress
      }
    }
  ''';

    try {
      final result = await _client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'mediaId': mediaId,
            'progress': progress,
          },
        ),
      );

      if (result.hasException) {
        logErr('Error updating progress', result.exception);
        return false;
      }

      return result.data?['SaveMediaListEntry'] != null;
    } catch (e) {
      logErr('Error updating progress', e);
      return false;
    }
  }

  /// Update status for an anime
  Future<bool> updateStatus(int mediaId, AnilistListStatus status) async {
    if (_client == null) return false;

    const mutation = r'''
    mutation UpdateStatus($mediaId: Int!, $status: MediaListStatus!) {
      SaveMediaListEntry(mediaId: $mediaId, status: $status) {
        id
        status
      }
    }
  ''';

    try {
      final result = await _client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'mediaId': mediaId,
            'status': status.name_,
          },
        ),
      );

      if (result.hasException) {
        logErr('Error updating status', result.exception);
        return false;
      }

      return result.data?['SaveMediaListEntry'] != null;
    } catch (e) {
      logErr('Error updating status', e);
      return false;
    }
  }

  Future<bool> updateScore(int mediaId, int score) async {
    if (_client == null) return false;

    const mutation = r'''
    mutation UpdateScore($mediaId: Int!, $score: Float!) {
      SaveMediaListEntry(mediaId: $mediaId, score: $score) {
        id
        score
      }
    }
  ''';

    try {
      final result = await _client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'mediaId': mediaId,
            'score': score.toDouble(),
          },
        ),
      );

      if (result.hasException) {
        logErr('Error updating score', result.exception);
        return false;
      }

      return result.data?['SaveMediaListEntry'] != null;
    } catch (e) {
      logErr('Error updating score', e);
      return false;
    }
  }

  /// Format status name for display
  String _formatStatusName(String status) {
    switch (status) {
      case 'CURRENT':
        return 'Watching';
      case 'PLANNING':
        return 'Plan to Watch';
      case 'COMPLETED':
        return 'Completed';
      case 'DROPPED':
        return 'Dropped';
      case 'PAUSED':
        return 'On Hold';
      case 'REPEATING':
        return 'Rewatching';
      default:
        return status;
    }
  }
}
