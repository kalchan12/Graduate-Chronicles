import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_system.dart';
import 'portfolio_select_screen.dart';

class PortfolioHubScreen extends ConsumerWidget {
  const PortfolioHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: Stack(
        children: [
          // Background subtle gradient/glow (optional, keeping clean for now)
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Achievements'),
                        const SizedBox(height: 12),
                        _buildCard(
                          icon: Icons.emoji_events_rounded,
                          iconColor: Colors.amberAccent,
                          title: "Dean's List 2023",
                          subtitle: 'Academic Excellence',
                        ),
                        _buildCard(
                          icon: Icons.verified_rounded,
                          iconColor: Colors.blueAccent,
                          title: 'Google UX Design Certificate',
                          subtitle: 'Professional Certification',
                        ),
                        _buildCard(
                          icon: Icons.lightbulb_rounded,
                          iconColor: Colors.orangeAccent,
                          title: 'Agile Methodology Intro',
                          subtitle: 'Workshop',
                        ),

                        const SizedBox(height: 32),

                        _buildSectionHeader('CVs / Resumes'),
                        const SizedBox(height: 12),
                        _buildCard(
                          icon: Icons.picture_as_pdf_rounded,
                          iconColor: Colors.redAccent,
                          title: 'Design_Portfolio_CV.pdf',
                          subtitle: 'Last updated 2 days ago',
                          isFile: true,
                        ),
                        _buildCard(
                          icon: Icons.description_rounded,
                          iconColor: Colors.white70,
                          title: 'General_Resume_2024.pdf',
                          subtitle: 'Uploaded Oct 2023',
                          isFile: true,
                        ),

                        const SizedBox(height: 32),

                        _buildSectionHeader('Certificates'),
                        const SizedBox(height: 12),
                        _buildCard(
                          icon: Icons.workspace_premium_rounded,
                          iconColor: DesignSystem.purpleAccent,
                          title: 'Google UX Design',
                          subtitle: 'Coursera',
                        ),
                        _buildCard(
                          icon: Icons.school_rounded,
                          iconColor: Colors.cyanAccent,
                          title: 'Agile Methodology',
                          subtitle: 'Udemy',
                        ),

                        const SizedBox(height: 32),

                        _buildSectionHeader('Links'),
                        const SizedBox(height: 12),
                        _buildCard(
                          icon: Icons.link_rounded,
                          iconColor: Colors.blue,
                          title: 'GitHub Profile',
                          subtitle: 'github.com/username',
                          showExternalIcon: true,
                        ),
                        _buildCard(
                          icon: Icons.business_center_rounded,
                          iconColor: Colors.blue[800],
                          title: 'LinkedIn Profile',
                          subtitle: 'linkedin.com/in/username',
                          showExternalIcon: true,
                        ),

                        // Bottom Spacer for FAB
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Add Button
          Positioned(
            bottom: 24,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PortfolioSelectScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: DesignSystem.mainGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: DesignSystem.purpleAccent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add New',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Portfolio',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color? iconColor,
    required String title,
    required String subtitle,
    bool isFile = false,
    bool showExternalIcon = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          splashColor: DesignSystem.purpleAccent.withValues(alpha: 0.1),
          highlightColor: DesignSystem.purpleAccent.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.white).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (showExternalIcon)
                  const Icon(
                    Icons.arrow_outward_rounded,
                    color: Colors.white24,
                    size: 18,
                  )
                else if (isFile)
                  const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white24,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
