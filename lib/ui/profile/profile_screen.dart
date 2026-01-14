import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/providers.dart';
import '../../theme/design_system.dart';
import '../widgets/custom_app_bar.dart';
import '../../settings/settings_main_screen.dart';

// Profile screen implemented to match the static HTML profile design.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTab = 0;
  bool _isConnectionSent = false;

  void _showCustomToast(String message) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 60,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E1A36).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DesignSystem.purpleAccent.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
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

  void _showProfileImage(String? imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: imagePath != null
                  ? Image.file(File(imagePath))
                  : const Icon(Icons.person, size: 150, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final achievements = ref.watch(profileAchievementsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
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
                  // Profile Image with handling for local file
                  GestureDetector(
                    onTap: () => _showProfileImage(profile.profileImage),
                    child: Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE94CFF).withValues(alpha: 0.6),
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
                          child: profile.profileImage != null
                              ? Image.file(
                                  File(profile.profileImage!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
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
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
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
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isConnectionSent = !_isConnectionSent;
                            });
                            if (_isConnectionSent) {
                              _showCustomToast('Connection Request Sent');
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
                            Navigator.pushNamed(context, '/messages');
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
