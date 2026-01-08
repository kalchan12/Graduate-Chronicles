import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    textTheme: GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme.copyWith(
        titleLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        bodyMedium: const TextStyle(
          fontSize: 16,
          color: Color(0xFFE0D4F5),
          height: 1.5,
        ),
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
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
