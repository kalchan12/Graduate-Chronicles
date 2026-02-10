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
  final bool isLiked; // Frontend-only state

  Story({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.isLiked = false,
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
      isLiked: false,
    );
  }

  Story copyWith({
    String? id,
    String? userId,
    String? mediaUrl,
    StoryMediaType? mediaType,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isLiked,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isLiked: isLiked ?? this.isLiked,
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
            'profile_pic_url': null, // Will be filled by batch fetch
          };
        }

        if (!groupedStories.containsKey(userId)) {
          groupedStories[userId] = [];
        }
        groupedStories[userId]!.add(story);
      }

      // Batch fetch profile pictures for ALL users with stories
      final allUserIds = userInfoMap.keys.toList();
      final profilePictures = await service.fetchProfilePicturesForUsers(
        allUserIds,
      );

      // Update userInfoMap with fetched profile pictures
      for (final userId in allUserIds) {
        userInfoMap[userId]!['profile_pic_url'] = profilePictures[userId];
      }

      final List<UserStoryGroup> groups = [];

      // Add "Your Story" placeholder if not present in fetched stories
      bool myStoryFound = false;

      // Get my avatar from already fetched data (if I have stories)
      String? myAvatarUrl;
      if (currentUserId != null) {
        myAvatarUrl = profilePictures[currentUserId];
        // If I don't have stories, my profile pic won't be in the batch fetch
        // So fetch it separately
        if (myAvatarUrl == null && !groupedStories.containsKey(currentUserId)) {
          try {
            final myProfile = await service.getFullProfile(currentUserId);
            if (myProfile != null) {
              myAvatarUrl = myProfile['profile_picture'];
            }
          } catch (e) {
            // Ignore error, use placeholder
          }
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
            // Use batch-fetched profile picture for all users
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

  Future<void> uploadStories(List<File> files) async {
    if (files.isEmpty) return;
    _isLoading =
        true; // Optional: Show global loading if needed, but toast handles it usually.

    try {
      final service = ref.read(supabaseServiceProvider);

      // 1. Authenticate & Initialize
      final currentUserId = await service.getCurrentUserId();
      if (currentUserId == null) throw Exception('Not authenticated');

      bool foundMyGroup = false;
      // Check if we have my group
      final hasProperState = state.any(
        (g) => g.isMe && g.userId == currentUserId,
      );

      // If state is empty or missing me, load first (once)
      if (!hasProperState) {
        await loadStories();
        // Re-check after load
        if (!state.any((g) => g.isMe && g.userId == currentUserId)) {
          // If still missing even after load (fresh user?), we will insert placeholders later
        }
      }

      final List<Story> newStories = [];

      // 2. Iterate and Upload
      for (final file in files) {
        final extension = file.path.split('.').last.toLowerCase();
        final isVideo = [
          'mp4',
          'mov',
          'avi',
          'mkv',
          'webm',
          'wmv',
          'flv',
          '3gp',
        ].contains(extension);
        final type = isVideo ? StoryMediaType.video : StoryMediaType.image;

        try {
          // Upload Media
          final url = await service.uploadStoryMedia(file);

          // Create DB Entry
          final storyData = await service.createStory(
            mediaUrl: url,
            type: type == StoryMediaType.video ? 'video' : 'image',
          );

          // Create Story Object
          final newStory = Story(
            id: storyData['id'] as String,
            userId: storyData['user_id'] as String,
            mediaUrl: storyData['media_url'] as String,
            mediaType: type,
            caption: storyData['caption'] as String?,
            // Parse logic for created_at
            createdAt: DateTime.parse(storyData['created_at'] as String),
            // Parse logic for expires_at with fallback
            expiresAt: storyData['expires_at'] != null
                ? DateTime.parse(storyData['expires_at'] as String)
                : DateTime.now().add(const Duration(hours: 24)),
          );
          newStories.add(newStory);
        } catch (e) {
          print('Error uploading single story file ${file.path}: $e');
        }
      }

      if (newStories.isEmpty) {
        // If all failed
        if (files.isNotEmpty) throw Exception('All uploads failed');
        return;
      }

      // 3. Single Batch State Update
      final newState = state.map((group) {
        if (group.isMe) {
          foundMyGroup = true;
          return group.copyWith(stories: [...group.stories, ...newStories]);
        }
        return group;
      }).toList();

      // If my group was missing, create it now
      if (!foundMyGroup) {
        // Try fetch profile pic
        String? myPic;
        try {
          final myProfile = await service.getFullProfile(currentUserId);
          myPic = myProfile?['profile_picture'];
        } catch (_) {}

        newState.insert(
          0,
          UserStoryGroup(
            userId: currentUserId,
            username: 'Your Story',
            isMe: true,
            stories: newStories,
            profilePicUrl: myPic,
          ),
        );
      }

      state = newState;
    } catch (e) {
      print('Batch upload stories error: $e');
      // Do not rethrow to avoid crashing UI if not caught
      // Instead, we can expose error state or just log it.
      // Rethrowing is okay if UI catches it.
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.deleteStory(storyId);
      await loadStories(); // Refresh list to remove deleted story
    } catch (e) {
      print('Delete story error: $e');
      rethrow;
    }
  }

  void toggleStoryLike(String userId, String storyId) {
    state = state.map((group) {
      if (group.userId == userId) {
        final updatedStories = group.stories.map((story) {
          if (story.id == storyId) {
            return story.copyWith(isLiked: !story.isLiked);
          }
          return story;
        }).toList();
        return group.copyWith(stories: updatedStories);
      }
      return group;
    }).toList();
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
