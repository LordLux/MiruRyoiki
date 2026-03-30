import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:miruryoiki/services/anilist/anilist_availability.dart';
import 'package:miruryoiki/services/connectivity/connectivity_service.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_query_executor.dart';

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

// Test class using the mixin
class TestExecutor with AnilistQueryExecutor {
  final GraphQLClient _client;
  TestExecutor(this._client);

  @override
  GraphQLClient? get client => _client;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockConnectivityStrategy mockConnectivity;
  late FakeGraphQLClient mockClient;
  late TestExecutor executor;

  setUp(() async {
    mockConnectivity = MockConnectivityStrategy();
    ConnectivityService().setStrategy(mockConnectivity);
    // Initialize ConnectivityService (mocking the initial check)
    await ConnectivityService().initialize();

    // Reset availability state
    AnilistAvailabilityService().reset();

    mockClient = FakeGraphQLClient();
    executor = TestExecutor(mockClient);
  });

  group('AnilistQueryExecutor', () {
    test('Online + No Cache (Network Success)', () async {
      // Arrange
      mockConnectivity.setOnline(true);
      // Wait for ConnectivityService to process the update
      await Future.delayed(const Duration(milliseconds: 50));

      mockClient.queryHandler = <T>(options) async {
        expect(options.fetchPolicy, FetchPolicy.networkOnly);
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {'test': 'success'},
        );
      };

      // Act
      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      // Assert
      expect(result, 'success');
    });

    test('Offline + Cache Hit', () async {
      // Arrange
      mockConnectivity.setOnline(false);
      await Future.delayed(const Duration(milliseconds: 50));

      mockClient.queryHandler = <T>(options) async {
        expect(options.fetchPolicy, FetchPolicy.cacheOnly);
        return QueryResult(
          options: options,
          source: QueryResultSource.cache,
          data: {'test': 'cached'},
        );
      };

      // Act
      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      // Assert
      expect(result, 'cached');
    });

    test('Offline + Cache Miss', () async {
      // Arrange
      mockConnectivity.setOnline(false);
      await Future.delayed(const Duration(milliseconds: 50));

      mockClient.queryHandler = <T>(options) async {
        expect(options.fetchPolicy, FetchPolicy.cacheOnly);
        // Simulate cache miss (null data, no exception usually, or exception with LinkException)
        return QueryResult(
          options: options,
          source: QueryResultSource.cache,
          data: null,
        );
      };

      // Act
      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      // Assert
      expect(result, null);
    });

    test('Online + Network Error (Retry)', () async {
      // Arrange
      mockConnectivity.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));

      int attempts = 0;
      mockClient.queryHandler = <T>(options) async {
        attempts++;
        if (attempts < 3) {
          // Simulate transient error
          return QueryResult(
            options: options,
            source: QueryResultSource.network,
            exception: OperationException(
              linkException: ServerException(
                originalException: SocketException('Network Error'),
                parsedResponse: null,
              ),
            ),
          );
        }
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {'test': 'success_after_retry'},
        );
      };

      // Act
      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      // Assert
      expect(result, 'success_after_retry');
      expect(attempts, 3);
    });

    test('Online + Rate Limit (Wait and Retry)', () async {
      // Arrange
      mockConnectivity.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));

      int attempts = 0;
      mockClient.queryHandler = <T>(options) async {
        attempts++;
        if (attempts == 1) {
          // Simulate 429 with Retry-After header
          return QueryResult(
            options: options,
            source: QueryResultSource.network,
            exception: OperationException(
              graphqlErrors: [GraphQLError(message: 'Too Many Requests')],
            ),
            context: Context().withEntry(
              HttpLinkResponseContext(
                statusCode: 429,
                headers: {'retry-after': '1'}, // 1 second wait
              ),
            ),
          );
        }
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {'test': 'success_after_ratelimit'},
        );
      };

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );
      stopwatch.stop();

      // Assert
      expect(result, 'success_after_ratelimit');
      expect(attempts, 2);
      // Should have waited at least 1 second
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
    });
  });

  group('AniList service outage detection', () {
    test('detects "temporarily disabled" and marks unavailable', () async {
      mockConnectivity.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));

      mockClient.queryHandler = <T>(options) async {
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          exception: OperationException(
            linkException: ServerException(
              originalException: null,
              parsedResponse: Response(
                data: null,
                errors: [
                  GraphQLError(
                    message: 'The AniList API has been temporarily disabled due to severe stability issues.',
                  ),
                ],
                response: {},
                context: const Context(),
              ),
            ),
          ),
        );
      };

      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      expect(result, isNull);
      expect(AnilistAvailabilityService().isUnavailable, true);
    });

    test('still attempts request when unavailable (no retries)', () async {
      mockConnectivity.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));

      AnilistAvailabilityService().markUnavailable();

      int attempts = 0;
      mockClient.queryHandler = <T>(options) async {
        attempts++;
        // Simulate the outage response again
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          exception: OperationException(
            linkException: ServerException(
              originalException: null,
              parsedResponse: Response(
                data: null,
                errors: [GraphQLError(message: 'The AniList API has been temporarily disabled.')],
                response: {},
                context: const Context(),
              ),
            ),
          ),
        );
      };

      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      expect(result, isNull);
      expect(attempts, 1, reason: 'Should attempt once but not retry');
    });

    test('clears unavailable flag when request succeeds', () async {
      mockConnectivity.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));

      AnilistAvailabilityService().markUnavailable();
      expect(AnilistAvailabilityService().isUnavailable, true);

      mockClient.queryHandler = <T>(options) async {
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {'test': 'recovered'},
        );
      };

      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      expect(result, 'recovered');
      expect(AnilistAvailabilityService().isUnavailable, false,
          reason: 'Successful request should clear the unavailable flag');
    });

    test('resumes requests after reset', () async {
      mockConnectivity.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // Mark unavailable then reset
      AnilistAvailabilityService().markUnavailable();
      AnilistAvailabilityService().reset();

      mockClient.queryHandler = <T>(options) async {
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {'test': 'back_online'},
        );
      };

      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      expect(result, 'back_online');
    });

    test('detects "temporarily unavailable" variant', () async {
      mockConnectivity.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));

      mockClient.queryHandler = <T>(options) async {
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          exception: OperationException(
            linkException: ServerException(
              originalException: null,
              parsedResponse: Response(
                data: null,
                errors: [
                  GraphQLError(message: 'Service temporarily unavailable'),
                ],
                response: {},
                context: const Context(),
              ),
            ),
          ),
        );
      };

      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      expect(result, isNull);
      expect(AnilistAvailabilityService().isUnavailable, true);
    });

    test('normal errors do NOT mark unavailable', () async {
      mockConnectivity.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));

      mockClient.queryHandler = <T>(options) async {
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          exception: OperationException(
            graphqlErrors: [GraphQLError(message: 'Some other error')],
          ),
        );
      };

      final result = await executor.executeQuery(
        options: QueryOptions(document: gql('query { test }')),
        operationName: 'testQuery',
        parser: (data) => data['test'] as String,
      );

      expect(result, isNull);
      expect(AnilistAvailabilityService().isUnavailable, false,
          reason: 'Regular errors should not trigger the outage flag');
    });

    test('mutation also detects outage', () async {
      mockConnectivity.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));

      mockClient.mutationHandler = <T>(options) async {
        return QueryResult(
          options: QueryOptions(document: options.document),
          source: QueryResultSource.network,
          exception: OperationException(
            linkException: ServerException(
              originalException: null,
              parsedResponse: Response(
                data: null,
                errors: [
                  GraphQLError(
                    message: 'The AniList API has been temporarily disabled due to severe stability issues.',
                  ),
                ],
                response: {},
                context: const Context(),
              ),
            ),
          ),
        );
      };

      final result = await executor.executeMutation(
        options: MutationOptions(document: gql('mutation { test }')),
        operationName: 'testMutation',
        parser: (data) => data['test'] as String,
      );

      expect(result, isNull);
      expect(AnilistAvailabilityService().isUnavailable, true);
    });
  });
}
