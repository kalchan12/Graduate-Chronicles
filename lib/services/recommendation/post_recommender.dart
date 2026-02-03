import '../../state/posts_state.dart';

/// Keyword-based post recommendation engine.
/// Uses Jaccard similarity between user interests and post keywords.
class PostRecommender {
  // Keyword extraction patterns
  static final _wordPattern = RegExp(r'\b[a-zA-Z]{3,}\b');

  // Common stop words to filter out
  static const _stopWords = {
    'the',
    'and',
    'for',
    'are',
    'but',
    'not',
    'you',
    'all',
    'can',
    'had',
    'her',
    'was',
    'one',
    'our',
    'out',
    'has',
    'have',
    'been',
    'some',
    'them',
    'than',
    'its',
    'into',
    'only',
    'other',
    'new',
    'these',
    'could',
    'time',
    'very',
    'when',
    'come',
    'made',
    'find',
    'more',
    'way',
    'who',
    'did',
    'get',
    'just',
    'know',
    'take',
    'people',
    'year',
    'your',
    'good',
    'this',
    'that',
    'with',
    'from',
    'they',
    'will',
    'what',
    'about',
    'which',
  };

  PostRecommender();

  /// Extract meaningful keywords from text
  Set<String> extractKeywords(String text) {
    final words = _wordPattern
        .allMatches(text.toLowerCase())
        .map((m) => m.group(0)!)
        .where((w) => !_stopWords.contains(w))
        .toSet();
    return words;
  }

  /// Calculate Jaccard similarity between two keyword sets
  double jaccardSimilarity(Set<String> setA, Set<String> setB) {
    if (setA.isEmpty || setB.isEmpty) return 0.0;
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    return intersection / union;
  }

  /// Get top-K recommended post IDs for a user
  Future<List<PostItem>> getRecommendedPosts({
    required List<String> userInterests,
    required List<PostItem> allPosts,
    int topK = 10,
  }) async {
    if (userInterests.isEmpty || allPosts.isEmpty) {
      return [];
    }

    // Convert user interests to lowercase keyword set
    final userKeywords = userInterests.map((i) => i.toLowerCase()).toSet();

    // Score each post
    final scoredPosts = <_ScoredPost>[];

    for (final post in allPosts) {
      final postKeywords = extractKeywords(post.description);
      final similarity = jaccardSimilarity(userKeywords, postKeywords);

      // Combine similarity with recency (posts from last 7 days get boost)
      final recencyBoost = _calculateRecencyBoost(post.createdAt);
      final finalScore = similarity * 0.7 + recencyBoost * 0.3;

      if (finalScore > 0) {
        scoredPosts.add(_ScoredPost(post: post, score: finalScore));
      }
    }

    // Sort by score descending
    scoredPosts.sort((a, b) => b.score.compareTo(a.score));

    // Return top K
    return scoredPosts.take(topK).map((sp) => sp.post).toList();
  }

  /// Calculate recency boost (0.0 to 1.0)
  double _calculateRecencyBoost(DateTime createdAt) {
    final now = DateTime.now();
    final age = now.difference(createdAt);

    if (age.inHours < 24) return 1.0;
    if (age.inDays < 3) return 0.8;
    if (age.inDays < 7) return 0.6;
    if (age.inDays < 14) return 0.4;
    if (age.inDays < 30) return 0.2;
    return 0.1;
  }

  /// Build personalized feed mixing recommendations with chronological posts
  Future<List<PostItem>> getPersonalizedFeed({
    required List<String> userInterests,
    required List<PostItem> allPosts,
    int recommendedCount = 5,
  }) async {
    if (userInterests.isEmpty) {
      // No interests = return chronological
      return allPosts;
    }

    final recommended = await getRecommendedPosts(
      userInterests: userInterests,
      allPosts: allPosts,
      topK: recommendedCount,
    );

    // Get IDs of recommended posts
    final recommendedIds = recommended.map((p) => p.id).toSet();

    // Filter out recommended from chronological to avoid duplicates
    final chronological = allPosts
        .where((p) => !recommendedIds.contains(p.id))
        .toList();

    // Interleave: 1 recommended, then 2 chronological
    final result = <PostItem>[];
    int recIdx = 0;
    int chronIdx = 0;

    while (recIdx < recommended.length || chronIdx < chronological.length) {
      // Add 1 recommended
      if (recIdx < recommended.length) {
        result.add(recommended[recIdx++]);
      }
      // Add 2 chronological
      for (int i = 0; i < 2 && chronIdx < chronological.length; i++) {
        result.add(chronological[chronIdx++]);
      }
    }

    return result;
  }
}

class _ScoredPost {
  final PostItem post;
  final double score;

  _ScoredPost({required this.post, required this.score});
}
