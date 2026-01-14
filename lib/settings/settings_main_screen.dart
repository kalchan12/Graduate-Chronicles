import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_system.dart';
import 'widgets/settings_tile.dart';
import 'edit_profile_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'help_settings_screen.dart';
import 'appearance_settings_screen.dart';
import '../../state/auth_provider.dart';

class SettingsMainScreen extends ConsumerWidget {
  const SettingsMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionHeader(title: 'GENERAL'),
          SettingsTile(
            icon: Icons.person,
            iconColor: Color(0xFFE94CFF),
            title: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileSettingsScreen(),
                ),
              );
            },
          ),
          SettingsTile(
            icon: Icons.notifications,
            iconColor: Color(0xFFE94CFF),
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          SettingsTile(
            icon: Icons.security,
            iconColor: Color(0xFFE94CFF),
            title: 'Privacy & Security',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacySettingsScreen(),
                ),
              );
            },
          ),
          SettingsTile(
            icon: Icons.palette,
            iconColor: Color(0xFFE94CFF),
            title: 'Appearance',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppearanceSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'SUPPORT'),
          SettingsTile(
            icon: Icons.help_outline,
            iconColor: Color(0xFF9D8FB0),
            title: 'Help Center',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          SettingsTile(
            icon: Icons.logout,
            iconColor: Colors.redAccent,
            title: 'Log Out',
            textColor: Colors.redAccent,
            trailing: const SizedBox.shrink(), // No arrow for logout
            onTap: () => _showLogoutDialog(context, ref),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Graduate Chronicles v1.0.0',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF231B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out of Graduate Chronicles?',
          style: TextStyle(color: Color(0xFFBDB1C9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context); // Close dialog
              Navigator.of(
                context,
              ).popUntil((route) => route.isFirst); // Go to splash/login
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFBDB1C9),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
