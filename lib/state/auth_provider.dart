import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Signup draft to preserve multi-step UI state (kept for compatibility).
class SignupDraft {
  final String username;
  final String fullName;
  final String email;
  final String password;
  final String? role;
  final String? department;
  final String? graduationYear;
  final Uint8List? avatar;
  final List<String> interests;

  const SignupDraft({
    this.username = '',
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.role,
    this.department,
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
    String? department,
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
      department: department ?? this.department,
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
    await Future.delayed(const Duration(milliseconds: 500));
    final stored = state.users[email.trim()];
    if (stored != null && stored == password.trim()) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        email: email.trim(),
        username: state.draft.username,
        errorMessage: null,
      );
      return true;
    }
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Invalid credentials',
    );
    return false;
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
    await Future.delayed(const Duration(milliseconds: 500));
    final newUsers = Map<String, String>.from(state.users);
    newUsers[email.trim()] = password.trim();
    state = state.copyWith(
      isLoading: false,
      users: newUsers,
      isAuthenticated: true,
      email: email.trim(),
      username: username ?? state.username,
      errorMessage: null,
    );
  }

  void logout() {
    state = AuthState.initial().copyWith(users: state.users);
  }

  // Keep draft helpers for existing signup UI
  void updateDraft({
    String? username,
    String? fullName,
    String? email,
    String? password,
    String? role,
    String? department,
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
      department: department,
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
