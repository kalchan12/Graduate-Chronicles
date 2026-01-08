import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

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
                height: 280,
                decoration: BoxDecoration(
                  color: DesignSystem.purpleMid.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: Center(
                  child: Icon(
                    Icons.groups_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.2),
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
