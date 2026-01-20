import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';

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

  const UserProfile({
    this.id = '',
    this.name = '',
    this.username = '',
    this.bio = '',
    this.profileImage,
    this.degree = '',
    this.year = '',
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['user_id']?.toString() ?? '',
      name: map['full_name'] ?? 'User',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      profileImage: map['profile_picture'], // can be null
      degree: map['major'] ?? '',
      year: map['graduation_year']?.toString() ?? '',
    );
  }
}

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    // Initial fetch
    _loadProfile();
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
      if (userId == null) return; // Not logged in

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

      // Optimistic Update
      // We assume success for UI responsiveness, then revert on failure if needed.
      // final oldState = state; // Unused for now
      state = UserProfile(
        id: state.id,
        name: name ?? state.name,
        username: username ?? state.username,
        bio: bio ?? state.bio,
        profileImage: profileImage ?? state.profileImage,
        degree: state.degree,
        year: state.year,
      );

      String? imagePathForDb = profileImage;

      // Check if we need to upload a new image (Local File)
      if (profileImage != null && !profileImage.startsWith('http')) {
        // It's a local path, so upload it.
        // Since we are in the ProfileNotifier, we need the internal ID.
        // state.id should be the internal user_id.
        imagePathForDb = await service.uploadProfilePicture(
          state.id,
          await _fileToBytes(profileImage),
        );
      } else if (profileImage != null && profileImage.startsWith('http')) {
        // If it's a URL, it means we didn't change it.
        // We should ideally NOT update the field or pass the existing path if known.
        // However, updateProfileSettings maps 'profileImage' -> 'profile_picture' column.
        // If we pass a full URL to the DB, it breaks our "Store Path Only" rule.
        // But we don't know the original path here easily without parsing the URL or storing it in state.
        // TRICK: If it's a URL, we assume it's unchanged, so we pass NULL to updateProfileSettings
        // to avoid overwriting the valid path in DB with a URL.
        imagePathForDb = null;
      }

      await service.updateProfileSettings(
        userId: state.id,
        fullName: name,
        username: username,
        bio: bio,
        profileImage: imagePathForDb,
      );

      // Re-fetch to ensure consistency (optional but safer)
      // await _loadProfile();
    } catch (e) {
      print('Error updating profile: $e');
      // Revert? For now, we just log. UI toast handles user feedback.
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
