/// Gorse AI recommendation server configuration.
///
/// Configure via environment variables:
/// - GORSE_URL: Base URL of Gorse server (default: http://localhost:8088)
/// - GORSE_API_KEY: Optional API key for authentication
class GorseConfig {
  /// Base URL of the Gorse server
  static String get baseUrl => const String.fromEnvironment(
    'GORSE_URL',
    defaultValue: 'http://localhost:8088',
  );

  /// API key for Gorse authentication (optional for playground mode)
  static String? get apiKey {
    const key = String.fromEnvironment('GORSE_API_KEY', defaultValue: '');
    return key.isEmpty ? null : key;
  }

  /// Feedback types for user interactions
  static const String feedbackLike = 'like';
  static const String feedbackRead = 'read';
  static const String feedbackComment = 'comment';

  /// API endpoints
  static String recommendEndpoint(String userId, {int n = 10}) =>
      '/api/recommend/$userId?n=$n';

  static const String feedbackEndpoint = '/api/feedback';
  static const String itemEndpoint = '/api/item';
  static const String userEndpoint = '/api/user';
}
