import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase/supabase_service.dart';
import '../services/recommendation/supabase_recommender.dart';
import '../services/recommendation/gorse_service.dart';

// ========== MODAL/DATA CLASSES ============

class PostItem {
  final String id;
  final String userId;
  final String description;
  final List<String> mediaUrls;
  final String mediaType;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;
  final bool isLikedByMe; // Computed field
  final String contentKind; // 'post' | 'announcement'
  final String interactionMode; // 'interactive' | 'broadcast'

  PostItem({
    required this.id,
    required this.userId,
    required this.description,
    required this.mediaUrls,
    required this.mediaType,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.isLikedByMe = false,
    this.contentKind = 'post',
    this.interactionMode = 'interactive',
  });

  factory PostItem.fromMap(Map<String, dynamic> map, {bool isLiked = false}) {
    final userMap = map['users'] as Map<String, dynamic>?;
    final profileMap = userMap?['profile'] as Map<String, dynamic>?;

    // Construct avatar URL if path exists
    // Note: We need the full URL. SupabaseService has helper but here we are in a pure model.
    // Ideally the view/query returns the full URL or we construct it.
    // The query returns the raw path from DB (e.g. "path/to/img.jpg").
    // We can assume standard bucket URL pattern if we don't have the client here.
    // OR: SupabaseService usually handles getPublicUrl.
    // BUT: PostItem is a data class.
    // Workaround: We will use a helper or assume the path needs 'getPublicUrl' equivalent.
    // Actually, `getFullProfile` in service converts it. `fetchPosts` returns raw data.
    // Let's assume we need to prepend the Supabase URL if it's just a path.
    // However, existing code in `PostCard` (line 295) uses `NetworkImage`.
    // If the DB stores raw paths, `NetworkImage` will fail on "user_id/..."
    // We should probably convert it in the Service before returning, OR construct it here.
    // Since I can't easily inject the Supabase client here without refactoring,
    // I will try to construct the URL string if it looks like a path.

    String? avatarUrl;
    if (profileMap != null && profileMap['profile_picture'] != null) {
      final path = profileMap['profile_picture'] as String;
      if (path.startsWith('http')) {
        avatarUrl = path;
      } else {
        // Construct standard Supabase Storage URL
        // https://<project>.supabase.co/storage/v1/object/public/avatar/<path>
        // Since I don't have the project URL handy in this file, this is risky.
        // BETTER FIX: Parse it here but rely on SupabaseService to have enriched it?
        // No, fetchPosts returns raw map.

        // Looking at `SupabaseService.dart` line 302: `_client.storage.from('avatar').getPublicUrl(path)`
        // I should probably move the transformation to `SupabaseService.fetchPosts`.

        // RE-PLAN: I will modify `SupabaseService.fetchPosts` to transform the data BEFORE returning it.
        // This is cleaner than hacking the URl here.
        // But I already edited SupabaseService and user is waiting.

        // Let's check `PostCard`. It expects a URL.
        // If I leave `fromMap` as is, I can't transform.

        // Hack: The user probably has the Project URL in constants or env.
        // But I see `Supabase.instance.client` is available in `posts_state.dart` because it imports `supabase_service.dart`.
        // Wait, `posts_state.dart` imports `riverpod`.
        // Is `Supabase` global available? Yes `supabase_flutter`.
        // So I can use `Supabase.instance.client.storage...`.
      }
    }

    // Parse avatar
    if (profileMap != null && profileMap['profile_picture'] != null) {
      final path = profileMap['profile_picture'] as String;
      if (path.startsWith('http')) {
        avatarUrl = path;
      } else {
        // Using the global instance which is initialized in main
        try {
          avatarUrl = Supabase.instance.client.storage
              .from('avatar')
              .getPublicUrl(path);
        } catch (_) {
          // Fallback if instance not ready (unlikely in run)
          avatarUrl = null;
        }
      }
    }

    return PostItem(
      id: map['id'],
      userId: map['user_id'],
      description: map['description'] ?? '',
      mediaUrls: List<String>.from(map['media_urls'] ?? []),
      mediaType: map['media_type'] ?? 'image',
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      userName: userMap?['full_name'] ?? userMap?['username'] ?? 'Unknown',
      userAvatar: avatarUrl,
      isLikedByMe: isLiked,
      contentKind: map['content_kind'] ?? 'post',
      interactionMode: map['interaction_mode'] ?? 'interactive',
    );
  }

  PostItem copyWith({bool? isLikedByMe, int? likesCount, int? commentsCount}) {
    return PostItem(
      id: id,
      userId: userId,
      description: description,
      mediaUrls: mediaUrls,
      mediaType: mediaType,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      userName: userName,
      userAvatar: userAvatar,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      contentKind: contentKind,
      interactionMode: interactionMode,
    );
  }
}

// ========== NOTIFIERS ============

// 1. FEED NOTIFIER
// Handles fetching posts and global feed actions (like/unlike updates list)
class FeedNotifier extends AsyncNotifier<List<PostItem>> {
  @override
  Future<List<PostItem>> build() async {
    return _fetchFeed();
  }

  Future<List<PostItem>> _fetchFeed() async {
    final service = ref.read(supabaseServiceProvider);
    final data = await service.fetchPosts(limit: 20);

    final List<PostItem> posts = [];
    for (var p in data) {
      final isLiked = await service.hasLikedPost(p['id']);
      posts.add(PostItem.fromMap(p, isLiked: isLiked));
    }
    return posts;
  }

  Future<void> toggleLike(String postId) async {
    // Optimistic Update
    final currentState = state.value;
    if (currentState == null) return;

    final index = currentState.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = currentState[index];
    final wasLiked = post.isLikedByMe;
    final newCount = wasLiked ? post.likesCount - 1 : post.likesCount + 1;

    // Apply optimistic
    var updatedList = List<PostItem>.from(currentState);
    updatedList[index] = post.copyWith(
      isLikedByMe: !wasLiked,
      likesCount: newCount,
    );
    state = AsyncValue.data(updatedList);

    try {
      // Real API call
      final service = ref.read(supabaseServiceProvider);
      await service.toggleLike(postId, wantLike: !wasLiked);
      print('✅ Like toggle success: ${!wasLiked} for $postId');
    } catch (e) {
      // Revert if error
      print('❌ Error toggling like: $e');
      // Revert to original state
      state = AsyncValue.data(currentState);
      // We could use a global toast service if available, effectively communicating failure
    }
  }

  void incrementCommentCount(String postId) {
    final currentState = state.value;
    if (currentState == null) return;

    final index = currentState.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = currentState[index];

    var updatedList = List<PostItem>.from(currentState);
    updatedList[index] = post.copyWith(commentsCount: post.commentsCount + 1);
    state = AsyncValue.data(updatedList);

    // Sync comment feedback to Gorse
    _syncCommentFeedback(postId);
  }

  Future<void> _syncCommentFeedback(String postId) async {
    final userId = await ref.read(supabaseServiceProvider).getCurrentUserId();
    if (userId != null) {
      GorseService.insertFeedback(
        feedbackType: 'comment',
        userId: userId,
        itemId: postId,
      );
    }
  }

  void removePost(String postId) {
    final currentState = state.value;
    if (currentState == null) return;
    final updatedList = currentState.where((p) => p.id != postId).toList();
    state = AsyncValue.data(updatedList);
  }
}

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<PostItem>>(
  FeedNotifier.new,
);

// 2. CREATE POST NOTIFIER
class CreatePostState {
  final bool isLoading;
  final List<String> selectedMedia; // Local paths
  final String? error;

  CreatePostState({
    this.isLoading = false,
    this.selectedMedia = const [],
    this.error,
  });
}

class CreatePostNotifier extends Notifier<CreatePostState> {
  @override
  CreatePostState build() {
    return CreatePostState();
  }

  void addMedia(String path) {
    state = CreatePostState(
      selectedMedia: [...state.selectedMedia, path],
      isLoading: state.isLoading,
    );
  }

  void removeMedia(String path) {
    state = CreatePostState(
      selectedMedia: state.selectedMedia.where((p) => p != path).toList(),
      isLoading: state.isLoading,
    );
  }

  Future<bool> publishPost(String description) async {
    if (description.isEmpty && state.selectedMedia.isEmpty) {
      state = CreatePostState(
        selectedMedia: state.selectedMedia,
        error: "Content cannot be empty",
      );
      return false;
    }

    try {
      state = CreatePostState(
        selectedMedia: state.selectedMedia,
        isLoading: true,
      );

      // Real Upload
      List<String> uploadedUrls = [];
      final service = ref.read(supabaseServiceProvider);

      for (var path in state.selectedMedia) {
        final url = await service.uploadPostMedia(path);
        uploadedUrls.add(url);
      }

      final postId = await service.createPost(
        description: description,
        mediaUrls: uploadedUrls,
        mediaType: 'image', // simplified, could detect video
      );

      // Trigger embedding generation (fire-and-forget)
      SupabaseRecommender.generateEmbedding(postId, description);

      // Register with Gorse
      GorseService.insertItem(
        itemId: postId,
        timestamp: DateTime.now(),
        comment: description,
        // Could extract hashtags as labels here if needed
      );

      state = CreatePostState(); // Reset
      return true;
    } catch (e) {
      state = CreatePostState(
        selectedMedia: state.selectedMedia,
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

final createPostProvider =
    NotifierProvider<CreatePostNotifier, CreatePostState>(
      CreatePostNotifier.new,
    );

// 3. COMMENTS NOTIFIER (Per Post)
final commentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      postId,
    ) async {
      final service = ref.read(supabaseServiceProvider);
      return await service.fetchComments(postId);
    });
