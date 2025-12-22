import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  late MockConnectivityStrategy mockConnectivity;
  late FakeGraphQLClient mockClient;
  late TestExecutor executor;

  setUp(() async {
    mockConnectivity = MockConnectivityStrategy();
    ConnectivityService().setStrategy(mockConnectivity);
    // Initialize ConnectivityService (mocking the initial check)
    await ConnectivityService().initialize();

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
                originalException: Exception('Network Error'),
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
}
