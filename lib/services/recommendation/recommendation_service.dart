import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_service.dart';
import '../../messaging/providers/messaging_provider.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService(ref);
});

class RecommendationService {
  final Ref _ref;

  RecommendationService(this._ref);

  // No-op for compatibility
  Future<void> init() async {}
  bool get isReady => true;

  // Keyword extraction patterns
  static final _wordPattern = RegExp(r'\b[a-zA-Z]{3,}\b');
  static const _stopWords = {
    'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had',
    'her', 'was', 'one', 'our', 'out', 'has', 'have', 'been', 'some', 'them',
    'than', 'its', 'into', 'only', 'other', 'new', 'these', 'could', 'time',
    'very', 'when', 'come', 'made', 'find', 'more', 'way', 'who', 'did',
    'get', 'just', 'know', 'take', 'people', 'year', 'your', 'good', 'this',
    'that', 'with', 'from', 'they', 'will', 'what', 'about', 'which',
    'marketing',
    'business',
    'engineer',
    'developer',
    'designer', // specialized stop words? maybe not
  };

  /// Get recommendations based on keyword similarity of profiles
  Future<List<Map<String, dynamic>>> getRecommendations(String myId) async {
    final supabase = _ref.read(supabaseServiceProvider);

    try {
      // 1. Fetch my profile
      final myProfile = await supabase.fetchUserProfile(myId);
      if (myProfile == null) return [];

      String myText = _buildProfileText(myProfile);
      final myKeywords = _extractKeywords(myText);

      if (myKeywords.isEmpty) return [];

      // 2. Fetch candidates
      final candidates = await _ref
          .read(messagingServiceProvider)
          .fetchDiscoverableUsers();

      // 3. Score candidates
      List<Map<String, dynamic>> scoredCandidates = [];

      for (var user in candidates) {
        if (user['auth_user_id'] == myId) continue;

        String userText = _buildProfileText(user);
        final userKeywords = _extractKeywords(userText);

        if (userKeywords.isEmpty) continue;

        double score = _jaccardSimilarity(myKeywords, userKeywords);

        if (score > 0) {
          final userWithScore = Map<String, dynamic>.from(user);
          userWithScore['match_score'] = score;
          scoredCandidates.add(userWithScore);
        }
      }

      // 4. Sort by score descending
      scoredCandidates.sort(
        (a, b) =>
            (b['match_score'] as double).compareTo(a['match_score'] as double),
      );

      // Return top 5
      return scoredCandidates.take(5).toList();
    } catch (e) {
      // Silently fail
      return [];
    }
  }

  String _buildProfileText(Map<String, dynamic> profile) {
    List<String> parts = [];

    // Bio
    if (profile['bio'] != null && (profile['bio'] as String).isNotEmpty) {
      parts.add(profile['bio']);
    }

    // Interests
    if (profile['interests'] != null) {
      if (profile['interests'] is List) {
        parts.add((profile['interests'] as List).join(' '));
      } else if (profile['interests'] is String) {
        parts.add(profile['interests']);
      }
    }

    // Major
    if (profile['major_id'] != null) parts.add(profile['major_id'].toString());

    // Skills or specialized fields could be added here

    return parts.join(' ');
  }

  Set<String> _extractKeywords(String text) {
    return _wordPattern
        .allMatches(text.toLowerCase())
        .map((m) => m.group(0)!)
        .where((w) => !_stopWords.contains(w))
        .toSet();
  }

  double _jaccardSimilarity(Set<String> setA, Set<String> setB) {
    if (setA.isEmpty || setB.isEmpty) return 0.0;
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    return intersection / union;
  }
}
