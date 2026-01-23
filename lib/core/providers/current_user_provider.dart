import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduate_chronicles/core/providers.dart';
import 'package:graduate_chronicles/services/supabase/supabase_service.dart';

class CurrentUserNotifier extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    return _fetchUser();
  }

  Future<Profile?> _fetchUser() async {
    try {
      final service = ref.read(supabaseServiceProvider);
      final userId = await service.getCurrentUserId();

      if (userId == null) return null;

      final data = await service.getFullProfile(userId);
      if (data == null) return null;

      // Extract role, defaulting to 'user' if missing
      final role = data['role'] as String? ?? 'user';

      return Profile(
        id: data['user_id'],
        name: data['full_name'] ?? 'Unknown',
        degree: data['major'] ?? 'Undeclared',
        year: (data['graduation_year'] ?? '').toString(),
        username: data['username'] ?? '',
        bio: data['bio'] ?? '',
        profileImage: data['profile_picture'],
        authUserId: data['auth_user_id'],
        role: role,
      );
    } catch (e, stack) {
      print('Error fetching current user: $e\n$stack');
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUser());
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, Profile?>(
      CurrentUserNotifier.new,
    );
