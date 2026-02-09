import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode state provider with persistence.
///
/// Usage:
/// ```dart
/// final themeMode = ref.watch(themeModeProvider);
/// ref.read(themeModeProvider.notifier).toggleTheme();
/// ```
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.dark; // Default to dark
  }

  /// Load saved theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    }
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      newMode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  /// Set a specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  /// Check if current theme is dark
  bool get isDark => state == ThemeMode.dark;
}

/// Global provider for theme mode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
