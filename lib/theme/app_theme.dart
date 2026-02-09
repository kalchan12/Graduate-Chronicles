import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized theme configuration for Graduate Chronicles.
/// Provides both light and dark themes while preserving the purple brand identity.
class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS (unchanged from original DesignSystem)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color purpleDark = Color(0xFF0F0410);
  static const Color purpleMid = Color(0xFF32113F);
  static const Color purpleAccent = Color(0xFF9B2CFF);
  static const Color purpleBright = Color(0xFF7A1BBF);
  static const Color warmYellow = Color(0xFFFBDE36);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME (existing design preserved)
  // ═══════════════════════════════════════════════════════════════════════════
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: purpleDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: purpleAccent,
      brightness: Brightness.dark,
      surface: const Color(0xFF241228),
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFBDB1C9),
    ),
    textTheme: _buildTextTheme(isDark: true),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF241228),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A0D1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Color(0xFFBDB1C9)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: purpleAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME (new)
  // ═══════════════════════════════════════════════════════════════════════════
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(
      0xFFF8F6FA,
    ), // off-white with purple tint
    colorScheme: ColorScheme.fromSeed(
      seedColor: purpleAccent,
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: const Color(0xFF1A1A2E),
      onSurfaceVariant: const Color(0xFF6E6E82),
    ),
    textTheme: _buildTextTheme(isDark: false),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: purpleAccent.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0EDF5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Color(0xFF6E6E82)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: purpleAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E0F3A), purpleDark, Color(0xFF150518)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8F6FA), Color(0xFFEDE8F5), Color(0xFFF5F2FA)],
    stops: [0.0, 0.5, 1.0],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme({required bool isDark}) {
    final baseColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtleColor = isDark
        ? const Color(0xFFE0D4F5)
        : const Color(0xFF4A4A5E);
    final mutedColor = isDark
        ? const Color(0xFFBDB1C9)
        : const Color(0xFF6E6E82);

    return GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).copyWith(
      titleLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: subtleColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(fontSize: 14, color: mutedColor),
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.2,
      ),
    );
  }

  /// Common border radius used across the app
  static const double borderRadius = 14.0;

  /// Returns the appropriate gradient based on brightness
  static LinearGradient getGradient(Brightness brightness) {
    return brightness == Brightness.dark ? darkGradient : lightGradient;
  }

  /// Returns card decoration based on current theme
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.45)
              : purpleAccent.withOpacity(0.08),
          blurRadius: isDark ? 18 : 12,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
