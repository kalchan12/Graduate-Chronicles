import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'add_achievement_screen.dart';
import 'add_cv_screen.dart';
import 'add_certificate_screen.dart';
import 'add_link_screen.dart';
import '../../theme/design_system.dart';

class PortfolioSelectScreen extends StatelessWidget {
  const PortfolioSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Add to Portfolio',
              showLeading: true,
              onLeading: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _card(
                    context,
                    'Achievement',
                    'Showcase your wins',
                    Icons.emoji_events_outlined,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddAchievementScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    context,
                    'CV / Resume',
                    'Upload your latest CV',
                    Icons.description_outlined,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddCvScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    context,
                    'Certificate',
                    'Add professional proofs',
                    Icons.workspace_premium_outlined,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCertificateScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    context,
                    'Link',
                    'Connect your work',
                    Icons.link,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddLinkScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B141E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF2D1B36),
              ),
              child: Icon(icon, color: const Color(0xFFE94CFF), size: 28),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFBDB1C9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 28),
          ],
        ),
      ),
    );
  }
}
