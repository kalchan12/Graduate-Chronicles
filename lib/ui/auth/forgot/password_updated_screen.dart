import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';

/*
  Success Screen for Password Reset.
  
  Displays a confirmation animation and directs the user
  back to the Login screen.
*/
class PasswordUpdatedScreen extends StatefulWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  State<PasswordUpdatedScreen> createState() => _PasswordUpdatedScreenState();
}

class _PasswordUpdatedScreenState extends State<PasswordUpdatedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _ctl, curve: Curves.easeIn);
    _ctl.forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1022),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _opacity,
                          child: ScaleTransition(
                            scale: _scale,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFd45eff),
                                        DesignSystem.purpleAccent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    size: 96,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Password Updated!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32.0,
                                  ),
                                  child: Text(
                                    'Your new password has been set successfully. You can now use it to log in.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFFD6C9E6)),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: 220,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                          '/login',
                                          (r) => false,
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          DesignSystem.purpleAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Back to Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
