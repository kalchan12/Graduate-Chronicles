import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

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
          _buildExpansionTile(
            title: 'FAQ',
            icon: Icons.question_answer,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Q: How do I reset my password?\nA: Go to Settings > Privacy & Security > Change Password.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Q: Can I change my username?\nA: Yes, go to Settings > Edit Profile to update your username.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildExpansionTile(
            title: 'Contact Support',
            icon: Icons.support_agent,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Email: support@graduatechronicles.com\nPhone: +1 (555) 123-4567\nHours: Mon-Fri, 9am - 5pm EST',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildExpansionTile(
            title: 'App Info',
            icon: Icons.info_outline,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Graduate Chronicles v1.0.0\nBuild Number: 100\n\n© 2026 Graduate Chronicles Inc.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF231B26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2433),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFE94CFF), size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          iconColor: Colors.white54,
          collapsedIconColor: const Color(0xFFBDB1C9),
          children: children,
        ),
      ),
    );
  }
}
