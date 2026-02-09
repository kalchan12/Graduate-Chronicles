import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/*
  Global Background Widget.

  Applies the application's standard gradient background to the child widget.
  - Automatically adapts to light/dark theme.
  - Uses specific brand colors defined in AppTheme.
  - Ensures visual consistency across the app.
*/
class GlobalBackground extends StatelessWidget {
  final Widget child;

  const GlobalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppTheme.darkGradient : AppTheme.lightGradient;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
