import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding completion state.
///
/// Uses SharedPreferences to persist onboarding completion status.
/// This ensures onboarding only shows once per device installation.
class OnboardingStorage {
  static const _key = 'onboarding_completed';

  /// Check if onboarding has been completed
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
