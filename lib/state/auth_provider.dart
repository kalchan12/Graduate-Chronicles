import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';
import '../services/notifications/notification_service.dart';

/// Signup draft to preserve multi-step UI state (kept for compatibility).
class SignupDraft {
  final String username;
  final String fullName;
  final String email;
  final String password;
  final String? role;
  final String? majorId;
  final String? graduationYear;
  final Uint8List? avatar;
  final List<String> interests;

  const SignupDraft({
    this.username = '',
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.role,
    this.majorId,
    this.graduationYear,
    this.avatar,
    this.interests = const [],
  });

  SignupDraft copyWith({
    String? username,
    String? fullName,
    String? email,
    String? password,
    String? role,
    String? majorId,
    String? graduationYear,
    Uint8List? avatar,
    List<String>? interests,
  }) {
    return SignupDraft(
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      majorId: majorId ?? this.majorId,
      graduationYear: graduationYear ?? this.graduationYear,
      avatar: avatar ?? this.avatar,
      interests: interests ?? this.interests,
    );
  }
}

/// The simplified AuthState required by the master prompt, plus `draft` kept for UI compatibility.
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String? email;
  final String? username;
  final Map<String, String> users; // in-memory store
  final SignupDraft draft;

  const AuthState._({
    required this.isAuthenticated,
    required this.isLoading,
    this.errorMessage,
    this.email,
    this.username,
    required this.users,
    required this.draft,
  });

  factory AuthState.initial() => const AuthState._(
    isAuthenticated: false,
    isLoading: false,
    errorMessage: null,
    email: null,
    username: null,
    users: {},
    draft: SignupDraft(),
  );

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? email,
    String? username,
    Map<String, String>? users,
    SignupDraft? draft,
  }) {
    return AuthState._(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      email: email ?? this.email,
      username: username ?? this.username,
      users: users ?? this.users,
      draft: draft ?? this.draft,
    );
  }
}

/// Auth notifier using Riverpod's Notifier API.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // seed with a sample user for quick testing
    return AuthState.initial().copyWith(
      users: {
        'test@uni.edu': 'Test@1234',
        'UGE/24170/13': '12345678', // Default dev user
      },
    );
  }

  bool _validateCredentials(String email, String password) {
    return email.trim().isNotEmpty && password.trim().isNotEmpty;
  }

  Future<bool> login({required String email, required String password}) async {
    if (!_validateCredentials(email, password)) {
      state = state.copyWith(errorMessage: 'Please provide email and password');
      return false;
    }
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(supabaseServiceProvider);
      await service.signInWithInstitutionalId(email, password);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        email: email.trim(),
        errorMessage: null,
      );
      
      // Sync push token in the background — do NOT await.
      // Awaiting this blocks login() return if getToken() hangs on the device,
      // which prevents navigation to the home screen.
      ref.read(notificationServiceProvider).saveDeviceToken().catchError((e) {
        print('⚠️ Post-login FCM sync failed: $e');
      });
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().contains('Exception:')
            ? e.toString().split('Exception:').last
            : 'Invalid credentials',
      );
      return false;
    }
  }

  Future<void> restoreSession() async {
    final service = ref.read(supabaseServiceProvider);
    final user = service.currentUser;
    if (user != null) {
      // Skip redundant state write if already authenticated with same user.
      // This prevents a cascade rebuild of all providers watching authProvider
      // (profile, portfolio, yearbook, reunion, notifications) on every app resume.
      if (state.isAuthenticated && state.email == user.email) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        email: user.email,
        username: user.userMetadata?['username'] ?? user.email,
        errorMessage: null,
      );
      
      // Sync push token in the background — do NOT await.
      ref.read(notificationServiceProvider).saveDeviceToken().catchError((e) {
        print('⚠️ Post-restore FCM sync failed: $e');
      });
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    String? username,
  }) async {
    if (!_validateCredentials(email, password)) {
      state = state.copyWith(errorMessage: 'Please provide email and password');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(supabaseServiceProvider);
      final draft = state.draft;

      await service.signUp(
        email: email,
        password: password,
        username: username ?? draft.username,
        fullName: draft.fullName,
        role: draft.role ?? 'Student',
        institutionalId:
            draft.email, // using email as ID if not provided differently
        major: draft.majorId,
        graduationYear: int.tryParse(draft.graduationYear ?? ''),
        school: null, // Not used in legacy auth flow
        program: null, // Not used in legacy auth flow
        interests: draft.interests,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        email: email.trim(),
        username: username ?? state.username,
        errorMessage: null,
      );
      
      // Sync push token immediately after successful signup
      ref.read(notificationServiceProvider).saveDeviceToken();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    // 1. Revoke FCM device token directly from the multi-device database
    // Must occur before signing out of Supabase so RLS lets us delete it
    try {
      await ref.read(notificationServiceProvider).deleteCurrentDeviceToken();
    } catch (_) {
      // Best effort deletion, ignore offline errors during logout
    }

    // 2. Sign out from Supabase
    await ref.read(supabaseServiceProvider).signOut();

    // 3. Clear Auth State
    state = AuthState.initial();

    // Note: Other providers (Profile, Portfolio) should ideally listen to this
    // or be manually invalidated/reset by their respective UI or logic.
  }

  // Keep draft helpers for existing signup UI
  void updateDraft({
    String? username,
    String? fullName,
    String? email,
    String? password,
    String? role,
    String? majorId,
    String? graduationYear,
    Uint8List? avatar,
    List<String>? interests,
  }) {
    final newDraft = state.draft.copyWith(
      username: username,
      fullName: fullName,
      email: email,
      password: password,
      role: role,
      majorId: majorId,
      graduationYear: graduationYear,
      avatar: avatar,
      interests: interests,
    );
    state = state.copyWith(draft: newDraft);
  }

  void setDraftAvatar(Uint8List data) => updateDraft(avatar: data);

  Future<void> finalizeSignup() async {
    final d = state.draft;
    await signup(email: d.email, password: d.password, username: d.username);
    state = state.copyWith(draft: const SignupDraft());
  }

  void clearError() => state = state.copyWith(errorMessage: null);

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
