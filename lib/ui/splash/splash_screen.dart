import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduate_chronicles/theme/design_system.dart';
import '../../state/auth_provider.dart';
import '../onboarding/onboarding1_screen.dart';

/*
  Splash Screen.

  The initial screen displayed on app launch.
  Features:
  - Animated Logo (Scale & Fade).
  - Sliding Text Animation.
  - Navigates to Onboarding after a set duration.
  - Checks for existing session to auto-login.
*/
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Keeping original duration as requested, though it is quite long.
  static const _splashDuration = Duration(milliseconds: 6500);

  late final AnimationController _mainCtrl;

  late final Animation<double> _logoScaleAnim;
  late final Animation<double> _logoFadeAnim;
  late final Animation<Offset> _textSlideAnim;
  late final Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Background fade-in (Not using explicit invalidation, keeping controller active)

    // Logo scale and fade
    _logoScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );
    _logoFadeAnim = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
    );

    // Text slide up and fade
    _textSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainCtrl,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _textFadeAnim = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
    );

    _mainCtrl.forward();

    Future.delayed(_splashDuration, () async {
      if (!mounted) return;

      // Restore Session Logic
      await ref.read(authProvider.notifier).restoreSession();

      if (!mounted) return;

      final auth = ref.read(authProvider);

      if (auth.isAuthenticated) {
        // Navigate directly to App if logged in
        Navigator.of(context).pushReplacementNamed('/app');
      } else {
        // Navigate to Onboarding if not logged in
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => const Onboarding1Screen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    super.dispose();
  }

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
            stops: [0.0, 0.8],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centered Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                FadeTransition(
                  opacity: _logoFadeAnim,
                  child: ScaleTransition(
                    scale: _logoScaleAnim,
                    child: Container(
                      width: 160,
                      height: 160,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: DesignSystem.purpleAccent.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/GC_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Animated Text
                SlideTransition(
                  position: _textSlideAnim,
                  child: FadeTransition(
                    opacity: _textFadeAnim,
                    child: Column(
                      children: [
                        Text(
                          'GRADUATE',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4.0,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'CHRONICLES',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: DesignSystem.purpleAccent,
                            letterSpacing: 8.0,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
