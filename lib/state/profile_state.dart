import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';
import '../services/recommendation/gorse_service.dart';
import 'auth_provider.dart';

/*
  Profile Provider & State.
  
  Manages the fetching and updating of the User Profile.
  Combines data from 'users' table and 'profile' table.
*/

class UserProfile {
  final String id;
  final String name;
  final String username;
  final String bio;
  final String? profileImage;
  final String degree; // major
  final String year; // graduation year
  final String role; // 'student', 'graduate'
  final String? authUserId;
  final List<String> interests; // Skills/Interests from DB

  const UserProfile({
    this.id = '',
    this.name = '',
    this.username = '',
    this.bio = '',
    this.profileImage,
    this.degree = '',
    this.year = '',
    this.role = '',
    this.authUserId,
    this.interests = const [],
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Parse interests array
    List<String> interestsList = [];
    if (map['interests'] != null) {
      if (map['interests'] is List) {
        interestsList = (map['interests'] as List).cast<String>();
      }
    }

    return UserProfile(
      id: map['user_id']?.toString() ?? '',
      name: map['full_name'] ?? 'User',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      profileImage: map['profile_picture'], // can be null
      degree: map['major'] ?? '',
      year: map['graduation_year']?.toString() ?? '',
      role: map['role'] ?? '', // Add role mapping
      authUserId: map['auth_user_id']?.toString(),
      interests: interestsList,
    );
  }
}

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    // Listen to Auth changes to reload profile automatically
    final auth = ref.watch(authProvider);

    // Initial load
    if (auth.isAuthenticated) {
      Future(() => _loadProfile());
    }

    return const UserProfile();
  }

  Future<void> refresh() async {
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final service = ref.read(supabaseServiceProvider);

      // Get current internal public ID
      final userId = await service.getCurrentUserId();
      if (userId == null) return; // Not logged in or user record missing

      final data = await service.getFullProfile(userId);
      if (data != null) {
        state = UserProfile.fromMap(data);
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? profileImage,
  }) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      final currentUserId = state.id;

      // Prevent updates if ID is missing
      if (currentUserId.isEmpty) return;

      // Optimistic Update
      state = UserProfile(
        id: state.id,
        name: name ?? state.name,
        username: username ?? state.username,
        bio: bio ?? state.bio,
        profileImage:
            profileImage ??
            state.profileImage, // Optimistically show local path/URL
        degree: state.degree,
        year: state.year,
        role: state.role,
        authUserId: state.authUserId,
        interests: state.interests,
      );

      String? imagePathForDb = profileImage;

      // Check if we need to upload a new image (Local File)
      if (profileImage != null && !profileImage.startsWith('http')) {
        // It's a local path, so upload it.
        imagePathForDb = await service.uploadProfilePicture(
          currentUserId,
          await _fileToBytes(profileImage),
        );
      } else if (profileImage != null && profileImage.startsWith('http')) {
        // Unchanged URL, do not overwrite in DB
        imagePathForDb = null;
      }

      await service.updateProfileSettings(
        userId: currentUserId,
        fullName: name,
        username: username,
        bio: bio,
        profileImage: imagePathForDb,
      );

      // Sync specific fields to Gorse if changed (ignoring image/bio for labels for now)
      // Ideally we sync labels (interests) but they aren't part of updateProfile yet?
      // UserProfile has interests. If we had an updateInterests method, we'd call it there.
      // Current implementation of updateProfile only updates basic info.
      // But we should at least ensure the user exists in Gorse.
      GorseService.insertUser(
        userId: currentUserId,
        comment: '$name ($username)',
        // No labels update here as updateProfile doesn't accept interests
      );

      // Re-fetch to confirm server state and get signed URLs if needed
      await _loadProfile();
    } catch (e) {
      print('Error updating profile: $e');
      // In a real app, we might revert state here
    }
  }

  Future<Uint8List> _fileToBytes(String path) async {
    return await File(path).readAsBytes();
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);

// Placeholder for verification data
final profileAchievementsProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {
      'title': 'Hackathon Winner 2024',
      'subtitle': 'First place in the annual University Hackathon.',
    },
    {
      'title': 'Dean\'s List',
      'subtitle': 'Maintained a 4.0 GPA for the Fall 2024 semester.',
    },
    {
      'title': 'Community Volunteer',
      'subtitle': 'Volunteered 50+ hours for local community service.',
    },
  ];
});

// Provider to fetch any user's profile by ID (for visiting)
final otherUserProfileProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  userId,
) async {
  final service = ref.read(supabaseServiceProvider);
  final data = await service.getFullProfile(userId);
  if (data != null) {
    return UserProfile.fromMap(data);
  }
  return null;
});

// Provider to fetch connection status with a target AUTH ID
final connectionStatusProvider = FutureProvider.family<String, String?>((
  ref,
  targetAuthId,
) async {
  if (targetAuthId == null) return 'none';
  final service = ref.read(supabaseServiceProvider);
  return await service.getConnectionStatus(targetAuthId);
});

// Provider to fetch connection count for a user (by AUTH ID)
final connectionCountProvider = FutureProvider.family<int, String?>((
  ref,
  authUserId,
) async {
  if (authUserId == null) return 0;
  final service = ref.read(supabaseServiceProvider);
  return await service.getConnectionCount(authUserId);
});
