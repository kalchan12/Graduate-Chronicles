import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recommendation/post_recommender.dart';
import '../services/recommendation/supabase_recommender.dart';
import '../services/supabase/supabase_service.dart';
import 'posts_state.dart';

/// Provider for the PostRecommender service
final postRecommenderProvider = Provider<PostRecommender>((ref) {
  return PostRecommender();
});

/// State for personalized feed
class PersonalizedFeedState {
  final List<PostItem> posts;
  final bool isLoading;
  final String? error;

  const PersonalizedFeedState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  PersonalizedFeedState copyWith({
    List<PostItem>? posts,
    bool? isLoading,
    String? error,
  }) {
    return PersonalizedFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for personalized post recommendations
class PersonalizedFeedNotifier extends AsyncNotifier<List<PostItem>> {
  @override
  Future<List<PostItem>> build() async {
    return _fetchPersonalizedFeed();
  }

  Future<List<PostItem>> _fetchPersonalizedFeed() async {
    final service = ref.read(supabaseServiceProvider);

    // 1. Fetch all posts (needed for fallback and chronological mixing)
    final data = await service.fetchPosts(limit: 50);
    final List<PostItem> allPosts = [];
    for (var p in data) {
      final isLiked = await service.hasLikedPost(p['id']);
      allPosts.add(PostItem.fromMap(p, isLiked: isLiked));
    }

    // 2. Get user info
    final userId = await service.getCurrentUserId();
    if (userId == null) return allPosts;

    final profile = await service.fetchUserProfile(userId);
    final interests = profile?['interests'] as List<dynamic>? ?? [];
    final interestStrings = interests.map((e) => e.toString()).toList();

    if (interestStrings.isEmpty) return allPosts;

    List<PostItem> recommendedPosts = [];

    // 3. Try AI Recommendations (Supabase Edge Function)
    try {
      final rawRecs = await SupabaseRecommender.getRecommendations(
        interests: interestStrings,
        userId: userId,
      );

      if (rawRecs.isNotEmpty) {
        for (var rec in rawRecs) {
          final isLiked = await service.hasLikedPost(rec['id']);
          recommendedPosts.add(PostItem.fromMap(rec, isLiked: isLiked));
        }
      }
    } catch (e) {
      // Silently fail to fallback
    }

    // 4. Fallback to Keyword-Based if AI failed or returned nothing
    if (recommendedPosts.isEmpty) {
      final recommender = ref.read(postRecommenderProvider);
      recommendedPosts = await recommender.getRecommendedPosts(
        userInterests: interestStrings,
        allPosts: allPosts,
        topK: 5,
      );
    }

    // 5. Mix feed (1 recommended + 2 chronological)
    return _mixFeed(recommendedPosts, allPosts);
  }

  List<PostItem> _mixFeed(
    List<PostItem> recommended,
    List<PostItem> chronological,
  ) {
    // Dedup: remove recommended from chronological
    final recommendedIds = recommended.map((p) => p.id).toSet();
    final remainingChronological = chronological
        .where((p) => !recommendedIds.contains(p.id))
        .toList();

    final result = <PostItem>[];
    int recIdx = 0;
    int chronIdx = 0;

    while (recIdx < recommended.length ||
        chronIdx < remainingChronological.length) {
      if (recIdx < recommended.length) {
        result.add(recommended[recIdx++]);
      }
      for (int i = 0; i < 2 && chronIdx < remainingChronological.length; i++) {
        result.add(remainingChronological[chronIdx++]);
      }
    }
    return result;
  }

  /// Refresh the feed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPersonalizedFeed());
  }

  /// Update after like/unlike
  void toggleLike(String postId) async {
    final currentPosts = state.value;
    if (currentPosts == null) return;

    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = currentPosts[index];
    final wasLiked = post.isLikedByMe;
    final newCount = wasLiked ? post.likesCount - 1 : post.likesCount + 1;

    // Optimistic update
    var updatedList = List<PostItem>.from(currentPosts);
    updatedList[index] = post.copyWith(
      isLikedByMe: !wasLiked,
      likesCount: newCount,
    );
    state = AsyncValue.data(updatedList);

    try {
      final service = ref.read(supabaseServiceProvider);
      await service.toggleLike(postId);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  void incrementCommentCount(String postId) {
    final currentPosts = state.value;
    if (currentPosts == null) return;

    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = currentPosts[index];
    var updatedList = List<PostItem>.from(currentPosts);
    updatedList[index] = post.copyWith(commentsCount: post.commentsCount + 1);
    state = AsyncValue.data(updatedList);
  }

  void removePost(String postId) {
    final currentPosts = state.value;
    if (currentPosts == null) return;
    final updatedList = currentPosts.where((p) => p.id != postId).toList();
    state = AsyncValue.data(updatedList);
  }
}

/// Main provider for personalized feed
final personalizedFeedProvider =
    AsyncNotifierProvider<PersonalizedFeedNotifier, List<PostItem>>(
      PersonalizedFeedNotifier.new,
    );
