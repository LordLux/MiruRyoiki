import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:miruryoiki/services/connectivity/connectivity_service.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_query_executor.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:miruryoiki/models/anilist/anime.dart';

// A concrete implementation of the mixin for testing
class RealApiExecutor with AnilistQueryExecutor {
  final GraphQLClient _client;
  RealApiExecutor(this._client);

  @override
  GraphQLClient? get client => _client;
}

// Mock connectivity that always reports online for the integration test
class AlwaysOnlineStrategy implements ConnectivityStrategy {
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value([ConnectivityResult.wifi]);

  @override
  Future<bool> hasInternetAccess() async => true;
}

void main() {
  // SET YOUR TOKEN HERE IF NEEDED FOR AUTHENTICATED TESTS
  const String? userToken = null; 

  late RealApiExecutor executor;

  setUpAll(() async {
    // Initialize Logging to see output (optional, but good for debugging)
    // initializeLoggingSession(); // Requires path_provider which might fail in pure unit test env without mocks

    // Force connectivity to be "online" so we don't depend on the actual device state logic
    // (though for a real integration test, we assume the machine has internet)
    ConnectivityService().setStrategy(AlwaysOnlineStrategy());
    await ConnectivityService().initialize();

    final HttpLink httpLink = HttpLink('https://graphql.anilist.co');
    
    Link link = httpLink;
    if (userToken != null && userToken.isNotEmpty) {
      final AuthLink authLink = AuthLink(getToken: () => 'Bearer $userToken');
      link = authLink.concat(httpLink);
    }

    final client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );

    executor = RealApiExecutor(client);
  });

  group('Real AniList API Integration', () {
    test('Fetch Public Anime Data (Cowboy Bebop)', () async {
      const query = r'''
        query {
          Media(id: 1, type: ANIME) {
            id
            title {
              romaji
              english
            }
            episodes
            status
          }
        }
      ''';

      print('Executing query against https://graphql.anilist.co...');

      final result = await executor.executeQuery<AnilistAnime>(
        options: QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        operationName: 'RealApiTest_CowboyBebop',
        parser: (data) => AnilistAnime.fromJson(data['Media']),
      );

      print('Result: $result');

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.title.english, 'Cowboy Bebop');
      expect(result.episodes, 26);
      expect(result.status, 'FINISHED');
    });

    test('Search for "Naruto"', () async {
      const query = r'''
        query($search: String) {
          Page(perPage: 5) {
            media(search: $search, type: ANIME) {
              id
              title {
                english
              }
            }
          }
        }
      ''';

      final result = await executor.executeQuery<List<AnilistAnime>>(
        options: QueryOptions(
          document: gql(query),
          variables: {'search': 'Naruto'},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        operationName: 'RealApiTest_SearchNaruto',
        parser: (data) {
          final List<dynamic> media = data['Page']['media'];
          return media.map((json) => AnilistAnime.fromJson(json)).toList();
        },
      );

      print('Found ${result?.length} results for "Naruto"');
      
      expect(result, isNotNull);
      expect(result!.isNotEmpty, true);
      // Check if any result contains "Naruto"
      final hasNaruto = result.any((anime) => 
        (anime.title.english)?.contains('Naruto') ?? false
      );
      expect(hasNaruto, true);
    });
  });
}
