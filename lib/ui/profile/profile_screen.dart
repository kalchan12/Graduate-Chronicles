import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/design_system.dart';
import '../../state/profile_state.dart'; // New Provider Import
import '../widgets/custom_app_bar.dart';
import '../../settings/settings_main_screen.dart';
import '../messages/message_detail_screen.dart';

import '../widgets/global_background.dart';

// Profile screen implemented to match the static HTML profile design.
/*
  User Profile Screen.
  
  Displays the user's personal information and portfolio.
  Features:
  - Header with Profile Picture, Name, Degree
  - Action buttons: Connect (toggle) and Message
  - Tabbed content: Achievements, Projects, Memories
  - Custom toast notification for actions
*/
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTab = 0;
  bool _isConnectionSent = false;

  // PART 2: State variables
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // PART 2: initState MUST call _loadProfile
    _loadProfile();
  }

  // PART 2: _loadProfile MUST do proper fetching
  Future<void> _loadProfile() async {
    final supabase = Supabase.instance.client;
    final authUser = supabase.auth.currentUser;

    if (authUser == null) return;

    try {
      // Fetch User Data (Identity)
      final userData = await supabase
          .from('users')
          .select('user_id, full_name, username, major')
          .eq('auth_user_id', authUser.id)
          .single();

      // Fetch Profile Data (Content)
      final profileData = await supabase
          .from('profile')
          .select('profile_picture, bio')
          .eq('user_id', userData['user_id'])
          .maybeSingle();

      String? newImageUrl;
      if (profileData != null && profileData['profile_picture'] != null) {
        final path = profileData['profile_picture'];
        // Check if it's already a full URL (legacy safety) or a path
        if (path.startsWith('http')) {
          newImageUrl = path;
        } else {
          final rawUrl = supabase.storage.from('avatar').getPublicUrl(path);

          // cache-bust to force refresh
          newImageUrl = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        }
      }

      if (mounted) {
        setState(() {
          _profileImageUrl = newImageUrl;
          _isLoading = false;
        });

        // Also refresh provider for other components if they rely on it
        // ref.read(profileProvider.notifier).refresh();
      }
    } catch (e) {
      print('Error loading profile in screen: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCustomToast(String message) {
    // ... existing toast code ...
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 30,
        left: 40,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E1A36).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: DesignSystem.purpleAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _showProfileImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
          ),
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Hero(
                tag: 'profile_image',
                child: _profileImageUrl != null
                    ? Image.network(_profileImageUrl!)
                    : const Icon(Icons.person, size: 150, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We still watch the provider for other fields (name, degree, bio)
    // BUT we use local state for the image to guarantee freshness.
    final profile = ref.watch(profileProvider);
    final achievements = ref.watch(profileAchievementsProvider);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(color: DesignSystem.purpleAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              // App Bar matching design
              CustomAppBar(
                title: 'Profile',
                showLeading: true,
                onLeading: () => Navigator.of(context).pop(),
                trailing: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsMainScreen(),
                      ),
                    );
                  },
                ),
              ),

              // Profile header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // PART 3: UI Rendering (Local State)
                    GestureDetector(
                      onTap: _showProfileImage,
                      child: Hero(
                        tag: 'profile_image',
                        child: Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(
                                0xFFE94CFF,
                              ).withValues(alpha: 0.6),
                              width: 2,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2B1F2E),
                              border: Border.all(
                                color: const Color(0xFFE94CFF),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: _profileImageUrl != null
                                  ? Image.network(
                                      _profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (profile.username.isNotEmpty) ...[
                      Text(
                        profile.username,
                        style: const TextStyle(
                          color: DesignSystem.purpleAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      '${profile.degree} | ${profile.year}',
                      style: const TextStyle(
                        color: Color(0xFFBDB1C9),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isConnectionSent = !_isConnectionSent;
                                });
                                if (_isConnectionSent) {
                                  _showCustomToast('Connection Request Sent');
                                } else {
                                  _showCustomToast(
                                    'Connection Request Cancelled',
                                  );
                                }
                              },
                              child: Container(
                                height: 42, // Reduced height
                                decoration: BoxDecoration(
                                  color: _isConnectionSent
                                      ? const Color(0xFF2D2433)
                                      : DesignSystem.purpleAccent,
                                  borderRadius: BorderRadius.circular(21),
                                  border: _isConnectionSent
                                      ? Border.all(color: Colors.white24)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    _isConnectionSent ? 'Sent' : 'Connect',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                final conversations = ref.read(
                                  conversationsProvider,
                                );
                                // Simple match by name for this mock data environment
                                final existingConv = conversations.firstWhere(
                                  (c) => c.participantName == profile.name,
                                  orElse: () => Conversation(
                                    id: 'new_${profile.id}',
                                    participantName: profile.name,
                                    participantAvatar:
                                        profile.profileImage ?? '',
                                    messages: [],
                                  ),
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MessageDetailScreen(
                                      conversationId: existingConv.id,
                                      participantName: profile.name,
                                      participantAvatar: profile.profileImage,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 42, // Reduced height
                                decoration: BoxDecoration(
                                  color: const Color(0xFF231B26),
                                  borderRadius: BorderRadius.circular(21),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Message',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bio Section
              if (profile.bio.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B141E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      profile.bio,
                      style: const TextStyle(
                        color: Color(0xFFD6C9E6),
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              // Interests Chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _interestChip('SwiftUI'),
                    const SizedBox(width: 8),
                    _interestChip('React Native'),
                    const SizedBox(width: 8),
                    _interestChip('UX/UI Design'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Tabs
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF2D2433), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    _tabItem(0, 'Achievements'),
                    _tabItem(1, 'Projects'),
                    _tabItem(2, 'Memories'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Content based on tab
              if (_selectedTab == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: achievements
                        .map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _AchievementCard(
                              title: a['title']!,
                              subtitle: a['subtitle']!,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _interestChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B1F2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFFE94CFF), fontSize: 13),
        ),
      ),
    );
  }

  Widget _tabItem(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFFE94CFF)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFBDB1C9),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _AchievementCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B141E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B36),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Color(0xFFE94CFF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFBDB1C9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
