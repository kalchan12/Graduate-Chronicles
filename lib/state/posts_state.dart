import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';

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
  });

  factory PostItem.fromMap(Map<String, dynamic> map, {bool isLiked = false}) {
    final userMap = map['users'] as Map<String, dynamic>?;

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
      userAvatar: null, // Avatar not in users table, stored in profile table
      isLikedByMe: isLiked,
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
      await service.toggleLike(postId);
    } catch (e) {
      // Revert if error
      // Re-fetch or strict revert not always easy without keeping strict history.
      // For now, simpler to just reload or re-toggle in memory if we really wanted perfection.
      // But simply forcing a reload is safer.
      // state = AsyncValue.data(currentState); // If we kept a strict copy
      ref.invalidateSelf(); // Simplest revert: re-fetch
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

      await service.createPost(
        description: description,
        mediaUrls: uploadedUrls,
        mediaType: 'image', // simplified, could detect video
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
