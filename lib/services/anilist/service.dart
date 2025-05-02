import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import '../../../models/anilist/anime.dart';
import '../../../models/anilist/user_list.dart';
import 'auth.dart';

class AnilistService {
  final AnilistAuthService _authService;
  GraphQLClient? _client;

  AnilistService({AnilistAuthService? authService}) : 
    _authService = authService ?? AnilistAuthService();

  /// Initialize the service
  Future<bool> initialize() async {
    final authenticated = await _authService.init();
    
    if (authenticated) {
      _setupGraphQLClient();
      return true;
    }
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
  }

  /// Start the login flow
  Future<void> login() async {
    await _authService.login();
  }

  /// Handle auth callback
  Future<bool> handleAuthCallback(Uri callbackUri) async {
    final success = await _authService.handleAuthCallback(callbackUri);
    if (success) {
      _setupGraphQLClient();
    }
    return success;
  }

  /// Logout from Anilist
  Future<void> logout() async {
    await _authService.logout();
    _client = null;
  }

  /// Check if the user is logged in
  bool get isLoggedIn => _authService.isAuthenticated;

  /// Search for anime by title
  Future<List<AnilistAnime>> searchAnime(String query, {int limit = 10}) async {
    if (_client == null) return [];

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
            bannerImage
            description
            popularity
            averageScore
            episodes
            format
            status
            seasonYear
            season
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
        debugPrint('Error searching Anilist: ${result.exception}');
        return [];
      }

      final List<dynamic> media = result.data?['Page']['media'] ?? [];
      return media.map((item) => AnilistAnime.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error querying Anilist: $e');
      return [];
    }
  }

  /// Get detailed anime information by ID
  Future<AnilistAnime?> getAnimeDetails(int id) async {
    if (_client == null) return null;

    const detailsQuery = r'''
      query GetAnimeDetails($id: Int!) {
        Media(id: $id, type: ANIME) {
          id
          title {
            romaji
            english
            native
          }
          bannerImage
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
        debugPrint('Error getting anime details: ${result.exception}');
        return null;
      }

      final media = result.data?['Media'];
      return media != null ? AnilistAnime.fromJson(media) : null;
    } catch (e) {
      debugPrint('Error querying Anilist: $e');
      return null;
    }
  }

  /// Get current user information
  Future<AnilistUser?> getCurrentUser() async {
    if (_client == null) return null;

    const userQuery = r'''
      query {
        Viewer {
          id
          name
          avatar {
            large
          }
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
        debugPrint('Error getting user info: ${result.exception}');
        return null;
      }

      final userData = result.data?['Viewer'];
      return userData != null ? AnilistUser.fromJson(userData) : null;
    } catch (e) {
      debugPrint('Error querying Anilist: $e');
      return null;
    }
  }

  /// Get user anime lists (watching, completed, etc.)
  Future<Map<String, AnilistUserList>> getUserAnimeLists() async {
    if (_client == null) return {};

    const listsQuery = r'''
      query {
        Viewer {
          id
          mediaListOptions {
            animeList {
              customLists
            }
          }
          animeLists: mediaListCollection(type: ANIME) {
            lists {
              name
              status
              entries {
                id
                mediaId
                status
                progress
                score(format: POINT_10)
                media {
                  id
                  title {
                    romaji
                    english
                    native
                  }
                  coverImage {
                    large
                  }
                  episodes
                }
                customLists
              }
            }
          }
        }
      }
    ''';

    try {
      final result = await _client!.query(
        QueryOptions(
          document: gql(listsQuery),
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        debugPrint('Error getting anime lists: ${result.exception}');
        return {};
      }

      final viewer = result.data?['Viewer'];
      if (viewer == null) return {};
      
      final animeLists = viewer['animeLists'];
      final Map<String, AnilistUserList> lists = {};
      
      // Standard lists (Watching, Completed, etc.)
      for (final list in animeLists['lists']) {
        final status = list['status'] as String?;
        if (status != null) {
          lists[status] = AnilistUserList.fromJson(
            {'lists': [list]}, 
            _formatStatusName(status),
          );
        }
      }
      
      // Custom lists
      final customListNames = viewer['mediaListOptions']?['animeList']?['customLists'];
      if (customListNames != null) {
        for (final customListName in customListNames) {
          // Create a custom list with entries that have this custom list
          final entriesForCustomList = [];
          for (final list in animeLists['lists']) {
            for (final entry in list['entries'] ?? []) {
              final entryCustomListsStr = entry['customLists']?.toString() ?? '{}';
              final entryCustomLists = jsonDecode(entryCustomListsStr) as Map?;
              
              if (entryCustomLists != null && 
                  entryCustomLists.containsKey(customListName) && 
                  entryCustomLists[customListName] == true) {
                entriesForCustomList.add(entry);
              }
            }
          }
          
          if (entriesForCustomList.isNotEmpty) {
            lists['custom_$customListName'] = AnilistUserList.fromJson(
              {'lists': [{'entries': entriesForCustomList}]},
              customListName,
              isCustomList: true,
            );
          }
        }
      }
      
      return lists;
    } catch (e) {
      debugPrint('Error querying Anilist: $e');
      return {};
    }
  }
  
  /// Format status name for display
  String _formatStatusName(String status) {
    switch (status) {
      case 'CURRENT': return 'Watching';
      case 'PLANNING': return 'Plan to Watch';
      case 'COMPLETED': return 'Completed';
      case 'DROPPED': return 'Dropped';
      case 'PAUSED': return 'On Hold';
      case 'REPEATING': return 'Rewatching';
      default: return status;
    }
  }
}