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
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      titleLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: const Color(0xFFE0D4F5),
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        color: const Color(0xFFBDB1C9),
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // THEME-AWARE HELPERS (call with BuildContext)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Returns theme-aware card surface color
  static Color cardSurface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Returns theme-aware scaffold background
  static Color scaffoldBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  /// Returns theme-aware background gradient
  static LinearGradient backgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E0F3A), purpleDark, Color(0xFF150518)],
            stops: [0.0, 0.5, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F6FA), Color(0xFFEDE8F5), Color(0xFFF5F2FA)],
            stops: [0.0, 0.5, 1.0],
          );
  }

  /// Returns theme-aware shadow color
  static Color shadowColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.08);
  }

  /// Returns theme-aware text color (primary)
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Returns theme-aware subtle text color
  static Color textSubtle(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  /// Returns theme-aware modal/dialog surface color
  static Color modalSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1224) : Colors.white;
  }

  /// Returns theme-aware card decoration with proper shadows
  static BoxDecoration themedCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : purpleAccent.withValues(alpha: 0.08),
          blurRadius: isDark ? 18 : 12,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
