import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/gorse_config.dart';

/// Service for interacting with Gorse AI recommendation system.
///
/// Gorse provides collaborative filtering and personalized recommendations.
/// This service handles:
/// - Fetching personalized recommendations
/// - Syncing user feedback (likes, views, comments)
/// - Registering items (posts) with Gorse
class GorseService {
  static final http.Client _client = http.Client();

  /// Get HTTP headers with optional API key authentication
  static Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final apiKey = GorseConfig.apiKey;
    if (apiKey != null) {
      headers['X-API-Key'] = apiKey;
    }
    return headers;
  }

  /// Get personalized recommendations for a user.
  ///
  /// Returns a list of item IDs (post IDs) recommended for the user.
  /// Returns empty list if Gorse is unavailable or has no recommendations.
  static Future<List<String>> getRecommendations(
    String userId, {
    int count = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${GorseConfig.baseUrl}${GorseConfig.recommendEndpoint(userId, n: count)}',
      );

      // print('Fetching recommendations from Gorse: $url'); // Debug log

      final response = await _client
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item.toString()).toList();
      }

      print('Gorse API Error (getRecommendations): ${response.statusCode}');
      return [];
    } catch (e) {
      print('Gorse Service Error: $e');
      // Gorse unavailable - will fallback to other recommenders
      return [];
    }
  }

  /// Insert user feedback into Gorse.
  ///
  /// Feedback types: 'like', 'read', 'comment'
  /// This trains the recommendation model.
  static Future<bool> insertFeedback({
    required String feedbackType,
    required String userId,
    required String itemId,
    DateTime? timestamp,
  }) async {
    try {
      final url = Uri.parse(
        '${GorseConfig.baseUrl}${GorseConfig.feedbackEndpoint}',
      );

      final body = jsonEncode([
        {
          'FeedbackType': feedbackType,
          'UserId': userId,
          'ItemId': itemId,
          'Timestamp': (timestamp ?? DateTime.now()).toUtc().toIso8601String(),
        },
      ]);

      final response = await _client
          .post(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        print('Gorse API Error (insertFeedback): ${response.statusCode}');
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Gorse Service Feedback Error: $e');
      return false;
    }
  }

  /// Register an item (post) with Gorse.
  ///
  /// Labels help Gorse understand item content for content-based filtering.
  static Future<bool> insertItem({
    required String itemId,
    List<String> labels = const [],
    List<String> categories = const [],
    String? comment,
    DateTime? timestamp,
    bool isHidden = false,
  }) async {
    try {
      final url = Uri.parse(
        '${GorseConfig.baseUrl}${GorseConfig.itemEndpoint}',
      );

      final body = jsonEncode({
        'ItemId': itemId,
        'Labels': labels,
        'Categories': categories,
        'Comment': comment ?? '',
        'Timestamp': (timestamp ?? DateTime.now()).toUtc().toIso8601String(),
        'IsHidden': isHidden,
      });

      final response = await _client
          .post(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        print('Gorse API Error (insertItem): ${response.statusCode}');
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Gorse Service Item Error: $e');
      return false;
    }
  }

  /// Register a user with Gorse.
  ///
  /// Labels describe user interests for content matching.
  static Future<bool> insertUser({
    required String userId,
    List<String> labels = const [],
    String? comment,
  }) async {
    try {
      final url = Uri.parse(
        '${GorseConfig.baseUrl}${GorseConfig.userEndpoint}',
      );

      final body = jsonEncode({
        'UserId': userId,
        'Labels': labels,
        'Comment': comment ?? '',
      });

      final response = await _client
          .post(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        print('Gorse API Error (insertUser): ${response.statusCode}');
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Gorse Service User Error: $e');
      return false;
    }
  }

  /// Check if Gorse server is available.
  static Future<bool> isAvailable() async {
    try {
      final url = Uri.parse('${GorseConfig.baseUrl}/api/health/ready');
      final response = await _client
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Delete feedback (e.g., when user unlikes a post)
  static Future<bool> deleteFeedback({
    required String feedbackType,
    required String userId,
    required String itemId,
  }) async {
    try {
      final url = Uri.parse(
        '${GorseConfig.baseUrl}${GorseConfig.feedbackEndpoint}/$feedbackType/$userId/$itemId',
      );

      final response = await _client
          .delete(url, headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        print('Gorse API Error (deleteFeedback): ${response.statusCode}');
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Gorse Service Delete Error: $e');
      return false;
    }
  }
}
