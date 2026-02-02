import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

/*
  Onboarding Screen 2.

  The second step in the onboarding flow.
  Features:
  - Focuses on networking ("Connect, Share, Thrive").
  - Navigation controls (Back, Next).
*/
class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.purpleDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E0F3A), DesignSystem.purpleDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Artwork
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                height: 320, // Slightly taller for image
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.purpleAccent.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/onboarding_2.png',
                        fit: BoxFit.cover,
                      ),
                      // Gradient Overlay for blending
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              DesignSystem.purpleDark.withOpacity(0.3),
                              DesignSystem.purpleDark.withOpacity(0.8),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Connect, Share, Thrive.',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Build your professional network, share your academic journey, and find opportunities within your university community.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Dot(active: false),
                  SizedBox(width: 8),
                  _Dot(active: true),
                  SizedBox(width: 8),
                  _Dot(active: false),
                ],
              ),
              const Spacer(),

              // Navigation Area
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Arrow
                    IconButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/onboarding1'),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      iconSize: 24,
                      splashRadius: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    // Forward Arrow
                    IconButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/onboarding3'),
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      iconSize: 24,
                      splashRadius: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? DesignSystem.purpleAccent : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
