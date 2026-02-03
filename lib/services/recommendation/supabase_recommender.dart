import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRecommender {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get personalized recommendations using Supabase Edge Function
  static Future<List<Map<String, dynamic>>> getRecommendations({
    required List<String> interests,
    String? userId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'recommend-posts',
        body: {'interests': interests, 'userId': userId},
      );

      if (response.status != 200) {
        return [];
      }

      final data = response.data;
      if (data is Map && data.containsKey('posts')) {
        return List<Map<String, dynamic>>.from(data['posts']);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Trigger embedding generation for a new post
  static Future<void> generateEmbedding(
    String postId,
    String description,
  ) async {
    try {
      await _supabase.functions.invoke(
        'generate-embedding',
        body: {'id': postId, 'description': description},
      );
    } catch (_) {
      // Background task, ignore errors
    }
  }
}
