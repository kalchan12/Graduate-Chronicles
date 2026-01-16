import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

/*
  Global Background Widget.

  Applies the application's standard gradient background to the child widget.
  - Uses specific brand colors defined in existing designs.
  - Ensures visual consistency across the app.
*/
class GlobalBackground extends StatelessWidget {
  final Widget child;

  const GlobalBackground({super.key, required this.child});

  static const LinearGradient globalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E0F3A), DesignSystem.purpleDark, Color(0xFF150518)],
    stops: [0.0, 0.5, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: globalGradient),
      child: child,
    );
  }
}
