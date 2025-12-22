import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';

const List<String> retryableHttpStatusCodes = ['502', '503', '504'];

/// Default retry condition for network operations
bool shouldRetryNetworkError(dynamic error) {
  // Retry on network-related errors
  if (error is SocketException) return true;
  if (error is TimeoutException) return true;
  if (error is HandshakeException) return true;

  // Check for specific error messages that indicate temporary issues
  final errorMessage = error.toString().toLowerCase();
  if (errorMessage.contains('timeout')) return true;
  if (errorMessage.contains('socketexception')) return true;
  if (errorMessage.contains('connection refused')) return true;
  if (errorMessage.contains('network is unreachable')) return true;
  if (errorMessage.contains('temporary failure')) return true;
  if (retryableHttpStatusCodes.any((code) => errorMessage.contains(code))) return true;

  return false;
}

/// Retry condition specifically for AniList API operations
bool shouldRetryAnilistError(dynamic error) {
  // Use the general network error retry logic
  if (shouldRetryNetworkError(error)) return true;

  // Add AniList specific error conditions
  final errorMessage = error.toString().toLowerCase();
  if (errorMessage.contains('too many requests')) return false;

  return false;
}

/// Check if an error is expected when offline (to avoid logging as errors)
bool isExpectedOfflineError(dynamic error) {
  if (error is SocketException) return true;
  if (error is TimeoutException) return true;
  if (error is HandshakeException) return true;
  if (error is ClientException) return true;

  final errorMessage = error.toString().toLowerCase();
  if (errorMessage.contains('network is unreachable')) return true;
  if (errorMessage.contains('connection refused')) return true;
  if (errorMessage.contains('no internet')) return true;
  if (errorMessage.contains('offline')) return true;
  if (errorMessage.contains('failed host lookup')) return true;
  if (errorMessage.contains('timeoutexception')) return true;
  if (errorMessage.contains('operationexception')) return true;
  if (errorMessage.contains('linkexception')) return true;
  if (errorMessage.contains('serverexception')) return true;
  if (errorMessage.contains('no stream event')) return true;
  if (errorMessage.contains('socket is not connected')) return true;
  if (errorMessage.contains('errno = 10057')) return true; // Windows socket not connected

  return false;
}
