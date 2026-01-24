import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase/supabase_service.dart';

enum StoryMediaType { image, video }

class Story {
  final String id;
  final String userId;
  final String mediaUrl;
  final StoryMediaType mediaType;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;

  Story({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id'],
      userId: map['users'] != null
          ? map['users']['user_id']
          : map['user_id'], // Handle potential join structure differences
      mediaUrl: map['media_url'],
      mediaType: map['media_type'] == 'video'
          ? StoryMediaType.video
          : StoryMediaType.image,
      caption: map['caption'],
      createdAt: DateTime.parse(map['created_at']),
      // If expires_at is not returned by the query (it is in fetchActiveStories), calculate it or default.
      // But fetchActiveStories returns it.
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'])
          : DateTime.parse(map['created_at']).add(const Duration(hours: 24)),
    );
  }
}

class UserStoryGroup {
  final String userId;
  final String username;
  final String? profilePicUrl;
  final bool isMe;
  final List<Story> stories;
  final bool
  isLiked; // Local UI state for now, backend support pending if not in schema

  UserStoryGroup({
    required this.userId,
    required this.username,
    this.profilePicUrl,
    this.isMe = false,
    required this.stories,
    this.isLiked = false,
  });

  UserStoryGroup copyWith({
    String? userId,
    String? username,
    String? profilePicUrl,
    bool? isMe,
    List<Story>? stories,
    bool? isLiked,
  }) {
    return UserStoryGroup(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isMe: isMe ?? this.isMe,
      stories: stories ?? this.stories,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  bool get hasStories => stories.isNotEmpty;
}

class StoriesNotifier extends Notifier<List<UserStoryGroup>> {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  List<UserStoryGroup> build() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      return [
        UserStoryGroup(
          userId: user.id,
          username: 'Your Story',
          isMe: true,
          stories: [],
        ),
      ];
    }
    return [];
  }

  Future<void> loadStories() async {
    _isLoading = true;
    // Notify listeners if needed, but since we modify state at end, it's fine.
    // Ideally we might want an AsyncValue, but sticking to List<UserStoryGroup> for now as per previous code style.

    try {
      final service = ref.read(supabaseServiceProvider);
      final rawStories = await service.fetchActiveStories();
      final currentUserId = await service.getCurrentUserId();

      // Group stories by user_id
      final Map<String, List<Story>> groupedStories = {};
      final Map<String, Map<String, dynamic>> userInfoMap = {};

      for (final storyData in rawStories) {
        // Parse Story
        final story = Story.fromMap(storyData);

        // Extract User Info from the JOIN (simplified query)
        final userData = storyData['users'] as Map<String, dynamic>;
        final userId = userData['user_id'] as String;

        if (!userInfoMap.containsKey(userId)) {
          userInfoMap[userId] = {
            'username': userData['username'] ?? userData['full_name'] ?? 'User',
            'profile_pic_url': null,
          };
        }

        if (!groupedStories.containsKey(userId)) {
          groupedStories[userId] = [];
        }
        groupedStories[userId]!.add(story);
      }

      final List<UserStoryGroup> groups = [];

      // Add "Your Story" placeholder if not present in fetched stories
      bool myStoryFound = false;

      // Pre-fetch my avatar URL (needed regardless of whether I have stories)
      String? myAvatarUrl;
      if (currentUserId != null) {
        try {
          final myProfile = await service.getFullProfile(currentUserId);
          if (myProfile != null) {
            myAvatarUrl = myProfile['profile_picture'];
          }
        } catch (e) {
          // Ignore error, use placeholder
        }
      }

      // Process grouped stories
      for (final entry in groupedStories.entries) {
        final userId = entry.key;
        final stories = entry.value;
        final info = userInfoMap[userId]!;

        final isMe = userId == currentUserId;
        if (isMe) myStoryFound = true;

        groups.add(
          UserStoryGroup(
            userId: userId,
            username: isMe ? 'Your Story' : info['username'],
            // For "Me", always use the pre-fetched avatar; for others, use placeholder
            profilePicUrl: isMe ? myAvatarUrl : info['profile_pic_url'],
            isMe: isMe,
            stories: stories,
          ),
        );
      }

      // If I don't have stories, strict requirement: Display "Your Story" card
      if (!myStoryFound && currentUserId != null) {
        // Attempt to get my profile pic from cached profile state or user metadata if possible
        // For now, we will try to fetch or leave null (placeholder).
        // The ProfileProvider isn't strictly linked here yet, but we can try to fetch me.

        // Helper: We can't easily async fetch inside this sync block builder seamlessly without blocking
        // but we can add a placeholder and let the UI load the avatar.
        // OR, we can fetch my profile specifically if missing.
        // Let's add the placeholder.

        String? myAvatarUrl;
        try {
          // Quick fetch of my own profile to get the avatar for the empty card
          final service = ref.read(supabaseServiceProvider);
          final myProfile = await service.getFullProfile(currentUserId);
          if (myProfile != null) {
            myAvatarUrl = myProfile['profile_picture'];
          }
        } catch (e) {
          // Ignore error, use placeholder
        }

        groups.insert(
          0,
          UserStoryGroup(
            userId: currentUserId,
            username: 'Your Story',
            isMe: true,
            stories: [],
            profilePicUrl: myAvatarUrl,
          ),
        );
      }

      // Sort: Me first, then by latest story
      groups.sort((a, b) {
        if (a.isMe) return -1;
        if (b.isMe) return 1;
        // Sort by latest story time
        final aLatest = a.stories.isNotEmpty
            ? a.stories.first.createdAt
            : DateTime(0);
        final bLatest = b.stories.isNotEmpty
            ? b.stories.first.createdAt
            : DateTime(0);
        return bLatest.compareTo(aLatest);
      });

      state = groups;
    } catch (e, stack) {
      print('Error loading stories: $e\n$stack');
      // On error, maybe fallback to empty state?
      state = [];
    } finally {
      _isLoading = false;
    }
  }

  Future<void> uploadStory(File file, StoryMediaType type) async {
    try {
      final service = ref.read(supabaseServiceProvider);

      // 1. Upload Media
      // Note: SupabaseService.uploadStoryMedia expects a File.
      final url = await service.uploadStoryMedia(file);

      // 2. Create DB Entry
      await service.createStory(
        mediaUrl: url,
        type: type == StoryMediaType.video ? 'video' : 'image',
      );

      // 3. Refresh
      await loadStories();
    } catch (e) {
      print('Upload story error: $e');
      rethrow; // Let UI handle error toast
    }
  }

  void toggleLike(String userId) {
    state = state.map((group) {
      if (group.userId == userId) {
        return group.copyWith(isLiked: !group.isLiked);
      }
      return group;
    }).toList();
  }
}

final storiesProvider = NotifierProvider<StoriesNotifier, List<UserStoryGroup>>(
  StoriesNotifier.new,
);
