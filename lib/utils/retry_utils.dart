import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart';

import 'logging.dart';

/// Utility class for implementing retry logic with exponential backoff
class RetryUtils {
  static final Random _random = Random();

  /// Maximum multiplier for exponential backoff.
  /// The default value of 20 limits the exponential growth of delay to avoid excessively long waits.
  /// This value was chosen as a practical upper bound for most retry scenarios.
  static const int defaultMaxBackoffMultiplier = 20;

  /// Retry a function with exponential backoff
  ///
  /// [operation] - The async function to retry
  /// [maxRetries] - Maximum number of retry attempts (default: 3)
  /// [baseDelay] - Base delay in milliseconds (default: 1000)
  /// [maxDelay] - Maximum delay in milliseconds (default: 10000)
  /// [retryIf] - Optional function to determine if an error should trigger a retry
  static Future<T?> retry<T>(
    Future<T?> Function() operation, {
    int maxRetries = 3,
    int baseDelay = 1000,
    int maxDelay = 10000,
    bool Function(dynamic error)? retryIf,
    String? operationName,
    int maxBackoffMultiplier = defaultMaxBackoffMultiplier,
  }) async {
    int attempt = 1;
    dynamic lastError;

    while (attempt <= maxRetries) {
      try {
        final result = await operation();

        // If this is not the first attempt, log successful recovery
        if (attempt > 1) logInfo('${operationName ?? 'Operation'} succeeded after $attempt retries');

        return result;
      } catch (error, stackTrace) {
        lastError = error;

        // Check if we should retry this error
        if (retryIf != null && !retryIf(error) && (error is! HandshakeException && error is! TimeoutException && error is! ClientException)) {
          logWarn('${operationName ?? 'Operation'} failed with non-retryable error: $error');
          rethrow;
        }

        // If we've exceeded max retries, don't retry
        if (attempt > maxRetries && (error is! HandshakeException && error is! TimeoutException && error is! ClientException)) {
          logErr('${operationName ?? 'Operation'} failed after $maxRetries retries.', error, stackTrace);
          break;
        }

        // Calculate delay with exponential backoff (base 1.5) and jitter, clamp multiplier to avoid excessive waits
        final jitter = (_random.nextDouble() * baseDelay).toInt();
        final multiplier = pow(1.5, attempt - 1).clamp(1, maxBackoffMultiplier);
        final delay = min(
          (baseDelay * multiplier).toInt() + jitter,
          maxDelay,
        );

        logWarn('${operationName ?? 'Operation'} failed (attempt $attempt/$maxRetries): $error. Retrying in ${delay}ms...');

        attempt++;
        await Future.delayed(Duration(milliseconds: delay));
      }
    }

    // If we get here, all retries failed
    // rethrow Exception('${operationName ?? 'Operation'} failed after $maxRetries retries. Last error: $lastError');
    throw lastError;
  }

  /// List of HTTP status codes that should trigger a retry.
  static const List<String> retryableHttpStatusCodes = ['502', '503', '504'];

  /// Default retry condition for network operations
  static bool shouldRetryNetworkError(dynamic error) {
    // Retry on network-related errors
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is HandshakeException) return true;

    // Check for specific error messages that indicate temporary issues
    final errorMessage = error.toString().toLowerCase();
    if (errorMessage.contains('timeout')) return true;
    if (errorMessage.contains('connection refused')) return true;
    if (errorMessage.contains('network is unreachable')) return true;
    if (errorMessage.contains('temporary failure')) return true;
    if (retryableHttpStatusCodes.any((code) => errorMessage.contains(code))) return true;

    return false;
  }

  /// Retry condition specifically for AniList API operations
  static bool shouldRetryAnilistError(dynamic error) {
    // Use the general network error retry logic
    if (shouldRetryNetworkError(error)) return true;

    // Add AniList specific error conditions
    final errorMessage = error.toString().toLowerCase();
    if (errorMessage.contains('rate limit')) return true;
    if (errorMessage.contains('too many requests')) return true;

    return false;
  }
}
