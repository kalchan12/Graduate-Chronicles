import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAuthState {
  final bool isLoggedIn;
  final String? errorMessage;
  final bool isLoading;

  const AdminAuthState({
    this.isLoggedIn = false,
    this.errorMessage,
    this.isLoading = false,
  });

  AdminAuthState copyWith({
    bool? isLoggedIn,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AdminAuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: errorMessage, // Nullable to clear error
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AdminAuthNotifier extends Notifier<AdminAuthState> {
  @override
  AdminAuthState build() {
    return const AdminAuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Email and Password are required',
      );
      return;
    }

    // Mock validation
    state = state.copyWith(isLoading: false, isLoggedIn: true);
  }

  Future<void> signup({
    required String fullName,
    required String username,
    required String adminId,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (fullName.isEmpty ||
        username.isEmpty ||
        adminId.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'All fields are required',
      );
      return;
    }

    // Success
    state = state.copyWith(isLoading: false, isLoggedIn: true);
  }

  void logout() {
    state = const AdminAuthState();
  }
}

final adminAuthProvider = NotifierProvider<AdminAuthNotifier, AdminAuthState>(
  AdminAuthNotifier.new,
);
