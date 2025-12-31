import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'add_achievement_screen.dart';
import 'add_cv_screen.dart';
import 'add_certificate_screen.dart';
import 'add_link_screen.dart';

class PortfolioSelectScreen extends StatelessWidget {
  const PortfolioSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Add to Portfolio', showLeading: true),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _card(context, 'Achievement', Icons.emoji_events, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAchievementScreen()))),
                  const SizedBox(height: 12),
                  _card(context, 'CV / Resume', Icons.description, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCvScreen()))),
                  const SizedBox(height: 12),
                  _card(context, 'Certificate', Icons.workspace_premium, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCertificateScreen()))),
                  const SizedBox(height: 12),
                  _card(context, 'Link', Icons.link, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLinkScreen()))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(color: const Color(0xFF121019), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white12), child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ]),
      ),
    );
  }
}
