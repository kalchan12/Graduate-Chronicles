import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../widgets/global_background.dart';

/*
  Community Hub Screen.
  
  The central landing page for the Community module.
  Features:
  - Navigation cards for Reunions and Mentorship
  - Modern card design
*/
class CommunityHomeScreen extends StatelessWidget {
  const CommunityHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: DesignSystem.textSubtle(context),
                              ),
                        ),
                        Text(
                          'Community Hub',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Text(
                      'Your Community',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stay connected with alumni & mentors.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DesignSystem.textSubtle(context),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Reunion Card
                    _ModernNavCard(
                      title: 'Reunions',
                      subtitle: 'Reconnect with your batch of 2023.',
                      buttonText: 'Find Events',
                      gradientColors: [
                        const Color(0xFF9B2CFF),
                        const Color(0xFF7A1BBF),
                      ],
                      icon: Icons.calendar_month_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, '/community/reunion'),
                    ),

                    const SizedBox(height: 24),

                    // Mentorship Card
                    _ModernNavCard(
                      title: 'Mentorship',
                      subtitle: 'Guidance from experienced alumni.',
                      buttonText: 'Find a Mentor',
                      gradientColors: [
                        const Color(0xFF536DFE),
                        const Color(0xFF3D5AFE),
                      ],
                      icon: Icons.school_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, '/community/mentorship'),
                    ),

                    const SizedBox(height: 24),

                    // Events Card
                    _ModernNavCard(
                      title: 'Events',
                      subtitle: 'Celebrate milestones with your peers.',
                      buttonText: 'View Gallery',
                      gradientColors: [
                        const Color(0xFFFF4081),
                        const Color(0xFFC51162),
                      ],
                      icon: Icons.celebration_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, '/community/events'),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernNavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final List<Color> gradientColors;
  final IconData icon;
  final VoidCallback onTap;

  const _ModernNavCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradientColors,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withValues(alpha: 0.2),
            gradientColors[1].withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: gradientColors[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Icon Decoration
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 140,
                  color: gradientColors[0].withValues(alpha: 0.1),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: gradientColors[0].withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: gradientColors[0].withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: DesignSystem.theme.textTheme.titleMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: DesignSystem.theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          buttonText,
                          style: DesignSystem.theme.textTheme.labelLarge
                              ?.copyWith(
                                color: DesignSystem.warmYellow,
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: DesignSystem.warmYellow,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
