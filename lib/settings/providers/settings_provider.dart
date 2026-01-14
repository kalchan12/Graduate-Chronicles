import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool pauseAllNotifications;
  final bool yearbookSignatures;
  final bool eventReminders;
  final bool comments;
  final bool tagsMentions;
  final bool newLikes;
  final bool weeklyRecap;
  final bool productUpdates;
  final bool twoFactorAuth;
  final bool
  darkMode; // Already exists in theme, kept here for completeness if needed locally

  const SettingsState({
    this.pauseAllNotifications = false,
    this.yearbookSignatures = true,
    this.eventReminders = true,
    this.comments = true,
    this.tagsMentions = true,
    this.newLikes = false,
    this.weeklyRecap = true,
    this.productUpdates = false,
    this.twoFactorAuth = false,
    this.darkMode = true,
  });

  SettingsState copyWith({
    bool? pauseAllNotifications,
    bool? yearbookSignatures,
    bool? eventReminders,
    bool? comments,
    bool? tagsMentions,
    bool? newLikes,
    bool? weeklyRecap,
    bool? productUpdates,
    bool? twoFactorAuth,
    bool? darkMode,
  }) {
    return SettingsState(
      pauseAllNotifications:
          pauseAllNotifications ?? this.pauseAllNotifications,
      yearbookSignatures: yearbookSignatures ?? this.yearbookSignatures,
      eventReminders: eventReminders ?? this.eventReminders,
      comments: comments ?? this.comments,
      tagsMentions: tagsMentions ?? this.tagsMentions,
      newLikes: newLikes ?? this.newLikes,
      weeklyRecap: weeklyRecap ?? this.weeklyRecap,
      productUpdates: productUpdates ?? this.productUpdates,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  void togglePauseAll(bool value) {
    state = state.copyWith(pauseAllNotifications: value);
  }

  void toggleYearbookSignatures(bool value) {
    state = state.copyWith(yearbookSignatures: value);
  }

  void toggleEventReminders(bool value) {
    state = state.copyWith(eventReminders: value);
  }

  void toggleComments(bool value) {
    state = state.copyWith(comments: value);
  }

  void toggleTagsMentions(bool value) {
    state = state.copyWith(tagsMentions: value);
  }

  void toggleNewLikes(bool value) {
    state = state.copyWith(newLikes: value);
  }

  void toggleWeeklyRecap(bool value) {
    state = state.copyWith(weeklyRecap: value);
  }

  void toggleProductUpdates(bool value) {
    state = state.copyWith(productUpdates: value);
  }

  void toggleTwoFactorAuth(bool value) {
    state = state.copyWith(twoFactorAuth: value);
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
