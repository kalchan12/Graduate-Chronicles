import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import 'widgets/settings_tile.dart';

class HelpSettingsScreen extends StatelessWidget {
  const HelpSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Help Center',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse our FAQ or contact our support team.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          SettingsTile(icon: Icons.question_answer, title: 'FAQ', onTap: () {}),
          SettingsTile(
            icon: Icons.support_agent,
            title: 'Contact Support',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'App Info',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
