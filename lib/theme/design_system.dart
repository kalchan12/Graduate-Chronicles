import 'package:flutter/material.dart';

class DesignSystem {
  // Core colors
  static const Color purpleDark = Color(0xFF0F0410);
  static const Color purpleMid = Color(0xFF32113F);
  static const Color purpleAccent = Color(0xFF9B2CFF);
  static const Color purpleBright = Color(0xFF7A1BBF);
  static const Color warmYellow = Color(0xFFFBDE36);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleMid, purpleBright],
  );

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: purpleDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: purpleAccent,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFD6C9E6)),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );

  // Common radii
  static const double borderRadius = 14.0;

  // Common scaffold background color accessible by UI widgets.
  static const Color scaffoldBg = purpleDark;

  // Small helpers
  static BoxDecoration cardDecoration() => BoxDecoration(
    color: const Color(0xFF241228),
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.45),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
