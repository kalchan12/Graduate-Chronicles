import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import 'widgets/settings_tile.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Appearance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              color: Color(0xFFBDB1C9),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Dark Mode (Selected)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF231B26),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DesignSystem.purpleAccent, width: 1.5),
            ),
            child: SettingsTile(
              icon: Icons.dark_mode,
              iconColor: Colors.white,
              title: 'Dark Mode',
              trailing: const Icon(
                Icons.check_circle,
                color: DesignSystem.purpleAccent,
              ),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          // Light Mode (Disabled)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF231B26),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SettingsTile(
              icon: Icons.light_mode,
              iconColor: Colors.white38,
              title: 'Light Mode',
              textColor: Colors.white38,
              subtitle: 'Coming Soon',
              trailing: const SizedBox.shrink(),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
