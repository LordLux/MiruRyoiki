import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:miruryoiki/services/connectivity/connectivity_service.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/settings.dart';

// Mock ConnectivityStrategy
class MockConnectivityStrategy implements ConnectivityStrategy {
  final StreamController<List<ConnectivityResult>> _controller = StreamController<List<ConnectivityResult>>.broadcast();
  bool _hasInternet = true;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> hasInternetAccess() async => _hasInternet;

  void setOnline(bool online) {
    _hasInternet = online;
    _controller.add(online ? [ConnectivityResult.wifi] : [ConnectivityResult.none]);
  }
}

// Fake GraphQLClient
class FakeGraphQLClient extends GraphQLClient {
  FakeGraphQLClient() : super(link: Link.function((request, [forward]) => const Stream.empty()), cache: GraphQLCache());

  Future<QueryResult<T>> Function<T>(QueryOptions<T>)? queryHandler;
  Future<QueryResult<T>> Function<T>(MutationOptions<T>)? mutationHandler;

  @override
  Future<QueryResult<T>> query<T>(QueryOptions<T> options) async {
    if (queryHandler != null) return queryHandler!(options);
    return QueryResult(options: options, source: QueryResultSource.network, data: {});
  }

  @override
  Future<QueryResult<T>> mutate<T>(MutationOptions<T> options) async {
    if (mutationHandler != null) return mutationHandler!(options);
    return QueryResult(options: options, source: QueryResultSource.network, data: {});
  }
}

void main() {
  late MockConnectivityStrategy mockConnectivity;
  late FakeGraphQLClient mockClient;
  late AnilistService service;

  setUpAll(() async {
    // Load dummy env vars
    dotenv.testLoad(fileInput: '''
ANILIST_CLIENT_ID=dummy_id
ANILIST_CLIENT_SECRET=dummy_secret
''');
    
    Manager.mockSettings = SettingsManager();
  });

  setUp(() async {
    mockConnectivity = MockConnectivityStrategy();
    ConnectivityService().setStrategy(mockConnectivity);
    
    mockClient = FakeGraphQLClient();
    service = AnilistService();
    service.client = mockClient;
  });

  group('AnilistService Mutations', () {
    test('updateProgress sends correct mutation', () async {
      mockClient.mutationHandler = <T>(options) async {
        expect(options.variables['mediaId'], 100);
        expect(options.variables['progress'], 5);
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {
            '__typename': 'Mutation',
            'SaveMediaListEntry': {
              '__typename': 'MediaList',
              'id': 123,
              'mediaId': 100,
              'progress': 5
            }
          },
        );
      };

      final result = await service.updateProgress(100, 5);
      expect(result, true);
    });

    test('updateStatus sends correct mutation', () async {
      mockClient.mutationHandler = <T>(options) async {
        expect(options.variables['mediaId'], 100);
        expect(options.variables['status'], 'CURRENT');
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {
            '__typename': 'Mutation',
            'SaveMediaListEntry': {
              '__typename': 'MediaList',
              'id': 123,
              'mediaId': 100,
              'status': 'CURRENT'
            }
          },
        );
      };

      final result = await service.updateStatus(100, AnilistListApiStatus.CURRENT);
      expect(result, true);
    });

    test('updateScore sends correct mutation (POINT_100 input, scoreRaw passed directly)', () async {
      mockClient.mutationHandler = <T>(options) async {
        expect(options.variables['mediaId'], 100);
        // score is now POINT_100 (0-100) and is passed directly as scoreRaw
        expect(options.variables['scoreRaw'], 80);
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {
            '__typename': 'Mutation',
            'SaveMediaListEntry': {
              '__typename': 'MediaList',
              'id': 123,
              'mediaId': 100,
              'score': 80.0  // API returns POINT_100 (format: POINT_100)
            }
          },
        );
      };

      // Call with POINT_100 value (80 = 8.0 in POINT_10 scale)
      final result = await service.updateScore(100, 80);
      expect(result, true);
    });

    test('updateScore with POINT_10_DECIMAL value preserves decimal precision', () async {
      mockClient.mutationHandler = <T>(options) async {
        // 85 = 8.5 in POINT_10_DECIMAL
        expect(options.variables['scoreRaw'], 85);
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {
            '__typename': 'Mutation',
            'SaveMediaListEntry': {
              '__typename': 'MediaList',
              'id': 100,
              'mediaId': 100,
              'score': 85.0
            }
          },
        );
      };

      final result = await service.updateScore(100, 85);
      expect(result, true);
    });

    test('AnilistMediaListEntry.fromJson parses POINT_100 score correctly', () {
      final json = {
        'id': 1,
        'mediaId': 100,
        'status': 'CURRENT',
        'progress': 5,
        'score': 85.0,  // POINT_100 value from API (= 8.5 in POINT_10_DECIMAL)
        'repeat': 0,
        'notes': null,
        'private': false,
        'customLists': null,
        'hiddenFromStatusLists': false,
        'priority': null,
        'startedAt': null,
        'completedAt': null,
        'createdAt': null,
        'updatedAt': null,
        'media': {
          'id': 100,
          'isFavourite': false,
          'title': {'userPreferred': 'Test Anime'},
        },
      };

      final entry = AnilistMediaListEntry.fromJson(json);
      // score is stored as POINT_100 int
      expect(entry.score, 85);
    });

    test('getUserAnimeLists parses response correctly', () async {
      mockClient.queryHandler = <T>(options) async {
        expect(options.variables['userName'], 'TestUser');
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {
            '__typename': 'Query',
            'MediaListCollection': {
              '__typename': 'MediaListCollection',
              'user': {
                '__typename': 'User',
                'id': 1,
                'name': 'TestUser',
                'mediaListOptions': {
                  '__typename': 'MediaListOptions',
                  'animeList': {
                    '__typename': 'MediaListTypeOptions',
                    'customLists': ['My Custom List']
                  }
                }
              },
              'lists': [
                {
                  '__typename': 'MediaListGroup',
                  'name': 'Completed',
                  'status': 'COMPLETED',
                  'entries': [
                    {
                      '__typename': 'MediaList',
                      'id': 1,
                      'mediaId': 100,
                      'status': 'COMPLETED',
                      'media': {
                        '__typename': 'Media',
                        'id': 100,
                        'isFavourite': false,
                        'title': {
                          '__typename': 'MediaTitle',
                          'userPreferred': 'Test Anime'
                        }
                      }
                    }
                  ]
                }
              ]
            }
          },
        );
      };

      final result = await service.getUserAnimeLists(userName: 'TestUser');
      expect(result, isNotEmpty);
      expect(result.keys, contains('COMPLETED'));
      expect(result['COMPLETED']!.entries.first.media.title.userPreferred, 'Test Anime');
    });
  });
}
