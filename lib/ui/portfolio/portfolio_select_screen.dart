import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add to Portfolio',
          style: DesignSystem.theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOptionCard(
                context,
                'Achievement',
                'Showcase your wins',
                Icons.emoji_events_rounded,
                Colors.amberAccent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddAchievementScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                'CV / Resume',
                'Upload your latest CV',
                Icons.picture_as_pdf_rounded,
                Colors.redAccent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCvScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                'Certificate',
                'Add professional proofs',
                Icons.workspace_premium_rounded,
                Colors.blueAccent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddCertificateScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                'Link',
                'Connect your work',
                Icons.link_rounded,
                Colors.cyanAccent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddLinkScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
