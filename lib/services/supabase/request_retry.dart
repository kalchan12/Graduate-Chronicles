import 'dart:async';
import 'dart:io';

/// A utility for retrying Supabase/HTTP requests that fail with transient
/// network errors like "Connection reset by peer" (SocketException errno 104).
///
/// Usage:
/// ```dart
/// final data = await retryOnTransientFailure(() async {
///   return await supabase.from('users').select();
/// });
/// ```
class RequestRetry {
  /// Retries [action] up to [maxAttempts] times if it throws a transient
  /// network error. Uses exponential backoff between retries.
  ///
  /// Returns the result of [action] on success, or rethrows the last
  /// exception if all attempts fail.
  static Future<T> retry<T>(
    Future<T> Function() action, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        attempt++;
        return await action();
      } catch (e) {
        if (attempt >= maxAttempts || !_isTransientError(e)) {
          rethrow;
        }
        print('⚡ Retry $attempt/$maxAttempts after transient error. '
            'Waiting ${delay.inMilliseconds}ms...');
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  /// Checks if an error is a transient network issue worth retrying.
  static bool _isTransientError(Object error) {
    final message = error.toString().toLowerCase();
    
    // SocketException: Connection reset by peer (errno 104)
    if (error is SocketException) return true;
    
    // ClientException wrapping a SocketException
    if (message.contains('connection reset by peer')) return true;
    if (message.contains('connection refused')) return true;
    if (message.contains('connection timed out')) return true;
    if (message.contains('network is unreachable')) return true;
    if (message.contains('service_not_available')) return true;
    
    return false;
  }
}
