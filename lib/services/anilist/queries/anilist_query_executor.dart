import 'dart:async';
import 'dart:math';

import 'package:graphql/client.dart';

import '../../connectivity/connectivity_service.dart';
import '../../../utils/logging.dart';
import '../../../utils/retry.dart';

mixin AnilistQueryExecutor {
  /// The GraphQL client to use for requests
  GraphQLClient? get client;

  /// Execute a GraphQL query
  Future<T?> executeQuery<T>({
    required QueryOptions options,
    required String operationName,
    required T Function(Map<String, dynamic>) parser,
    bool isOfflineAware = true,
  }) async {
    return _execute(
      execution: (FetchPolicy policy) => client!.query(
        QueryOptions(
          document: options.document,
          variables: options.variables,
          fetchPolicy: policy,
          errorPolicy: options.errorPolicy,
          cacheRereadPolicy: options.cacheRereadPolicy,
          context: options.context,
        ),
      ),
      operationName: operationName,
      parser: parser,
      isOfflineAware: isOfflineAware,
    );
  }

  /// Execute a GraphQL mutation
  Future<T?> executeMutation<T>({
    required MutationOptions options,
    required String operationName,
    required T Function(Map<String, dynamic>) parser,
    bool isOfflineAware = true,
  }) async {
    return _execute(
      execution: (FetchPolicy policy) => client!.mutate(
        MutationOptions(
          document: options.document,
          variables: options.variables,
          fetchPolicy: policy,
          errorPolicy: options.errorPolicy,
          cacheRereadPolicy: options.cacheRereadPolicy,
          context: options.context,
        ),
      ),
      operationName: operationName,
      parser: parser,
      isOfflineAware: isOfflineAware,
    );
  }

  /// Watch a GraphQL query
  Stream<T?> watchQuery<T>({
    required QueryOptions options,
    required String operationName,
    required T Function(Map<String, dynamic>) parser,
    bool isOfflineAware = true,
  }) async* {
    // Connectivity Check
    bool isOffline = false;
    if (isOfflineAware) {
      final connectivity = ConnectivityService();

      if (connectivity.isInitialized) {
        isOffline = connectivity.isOffline;
      } else {
        try {
          isOffline = !(await connectivity.getConnectivityStatus());
        } catch (e) {
          isOffline = false;
        }
      }
    }

    // Policy Selection
    // [ Offline -> CacheOnly ] [ Online -> CacheAndNetwork ]
    final policy = isOffline ? FetchPolicy.cacheOnly : FetchPolicy.cacheAndNetwork;

    if (isOffline) logTrace('$operationName: Device is offline, using cache');

    if (client == null) {
      logWarn('$operationName: Client is null');
      yield null;
      return;
    }

    final observable = client!.watchQuery(
      WatchQueryOptions(
        document: options.document,
        variables: options.variables,
        fetchPolicy: policy,
        errorPolicy: options.errorPolicy,
        cacheRereadPolicy: options.cacheRereadPolicy,
        context: options.context,
      ),
    );

    // Yield results from the stream
    await for (final result in observable.stream) {
      if (result.hasException) {
        final exception = result.exception!;

        // Handle Rate Limits (Basic logging for stream, as we can't easily "pause" the stream)
        if (exception.toString().contains('Too Many Requests.') || exception.toString().contains('429')) {
          logWarn('$operationName: Rate limited in stream!');
          // In a stream, we might just yield null or the previous data if available
          // For now, we'll just log it.
          // TODO : Implement better rate limit handling in streams if needed
        }

        if (isOffline && RetryUtils.isExpectedOfflineError(exception)) {
          // Expected offline error, ignore
        } else if (RetryUtils.shouldRetryAnilistError(exception)) {
          logWarn('$operationName: Stream error: $exception');
        } else {
          logErr('$operationName: Stream error', exception);
        }

        // If we have data despite the error, yield it
        if (result.data != null) yield parser(result.data!);
        continue;
      }

      // Successful result, yield parsed data
      if (result.data != null) yield parser(result.data!);

      if (result.source == QueryResultSource.network) {
        // Stream stays open for cache updates or subsequent network fetches
      }
    }
  }

  Future<T?> _execute<T>({
    required Future<QueryResult> Function(FetchPolicy policy) execution,
    required String operationName,
    required T Function(Map<String, dynamic>) parser,
    required bool isOfflineAware,
  }) async {
    int attempt = 1;
    const int maxRetries = 3;
    const int baseDelay = 1000;

    while (attempt <= maxRetries) {
      // Connectivity check
      bool isOffline = false;
      if (isOfflineAware) {
        final connectivity = ConnectivityService();

        if (connectivity.isInitialized) {
          isOffline = connectivity.isOffline;
        } else {
          try {
            isOffline = !(await connectivity.getConnectivityStatus());
          } catch (e) {
            isOffline = false;
          }
        }
      }

      // Policy Selection
      // [Offline -> CacheOnly] [Online -> NetworkOnly]
      final policy = isOffline ? FetchPolicy.cacheOnly : FetchPolicy.networkOnly;

      if (isOffline) logTrace('$operationName: Device is offline, using cache.');

      try {
        if (client == null) {
          logWarn('$operationName: Client is null');
          return null;
        }

        final result = await execution(policy);

        // Handle Success
        if (!result.hasException) {
          if (result.data == null) return null;
          return parser(result.data!);
        }

        // An exception occurred
        final exception = result.exception!;

        // Extract headers for Rate Limiting
        final headers = result.context.entry<HttpLinkResponseContext>()?.headers ?? {};

        final retryAfter = headers['retry-after'] ?? headers['Retry-After'];
        final reset = headers['x-ratelimit-reset'] ?? headers['X-RateLimit-Reset'];

        bool isRateLimited = false;
        int waitSeconds = 0;

        // Parse Rate Limit Headers
        if (retryAfter != null) {
          isRateLimited = true;
          waitSeconds = int.tryParse(retryAfter) ?? 60;
        } else if (reset != null) {
          isRateLimited = true;
          final resetTime = int.tryParse(reset);
          if (resetTime != null) {
            final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            waitSeconds = max(0, resetTime - now);
          } else {
            waitSeconds = 60;
          }
        } else
        // Can't extract headers but this is a rate limit responde, wait 60s
        if (exception.toString().contains('Too Many Requests') || exception.toString().contains('429')) {
          isRateLimited = true;
          waitSeconds = 60;
        }

        if (isRateLimited) {
          logWarn('$operationName: Rate limited! Waiting ${waitSeconds}s before retry.');
          await Future.delayed(Duration(seconds: waitSeconds + 1)); // Add 1s buffer
          // Retry immediately after waiting
          continue;
        }

        // Check if we are offline
        if (isOffline && RetryUtils.isExpectedOfflineError(exception)) {
          logTrace('$operationName: Offline error, returning null.');
          return null;
        }

        // Check if retryable
        if (RetryUtils.shouldRetryAnilistError(exception)) {
          if (attempt >= maxRetries) {
            logErr('$operationName: Failed after $maxRetries retries.', exception);
            return null;
          }

          final delay = (baseDelay * pow(1.5, attempt - 1)).toInt();
          logWarn('$operationName: Failed (attempt $attempt). Retrying in ${delay}ms... Error: $exception');
          await Future.delayed(Duration(milliseconds: delay));
          attempt++;
          continue;
        }

        // Not retryable
        logErr('$operationName: Non-retryable error.', exception);
        return null;
      } catch (e) {
        // Catch non-GraphQL exceptions
        if (isOffline && RetryUtils.isExpectedOfflineError(e)) return null;

        if (attempt >= maxRetries) return null;

        final delay = (baseDelay * pow(1.5, attempt - 1)).toInt();
        logWarn('$operationName: Unexpected error (attempt $attempt). Retrying... $e');
        await Future.delayed(Duration(milliseconds: delay));
        attempt++;
      }
    }

    return null;
  }
}
