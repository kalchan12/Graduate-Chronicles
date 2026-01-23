import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/supabase/supabase_service.dart';

class AdminAuthState {
  final bool isLoggedIn;
  final String? errorMessage;
  final bool isLoading;
  final String? requestStatus; // 'pending', 'approved', 'rejected', or null

  const AdminAuthState({
    this.isLoggedIn = false,
    this.errorMessage,
    this.isLoading = false,
    this.requestStatus,
  });

  AdminAuthState copyWith({
    bool? isLoggedIn,
    String? errorMessage,
    bool? isLoading,
    String? requestStatus,
  }) {
    return AdminAuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: errorMessage, // Nullable to clear error
      isLoading: isLoading ?? this.isLoading,
      requestStatus: requestStatus ?? this.requestStatus,
    );
  }
}

class AdminAuthNotifier extends Notifier<AdminAuthState> {
  @override
  AdminAuthState build() {
    return const AdminAuthState();
  }

  /// Checks if the current user has already submitted a request
  Future<void> checkRequestStatus() async {
    // In isolated mode, we cannot check status by Auth User ID.
    // We would need to ask user for email again or check local storage.
    // For now, we disable auto-check or implement "Check Status" feature later.
    // Leaving empty to avoid errors in UI init.
  }

  Future<void> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (identifier.isEmpty || password.isEmpty) {
        throw Exception('ID/Email and Password are required');
      }

      final service = ref.read(supabaseServiceProvider);

      // Verify against admins table (Isolated)
      await service.verifyAdminLogin(
        identifier: identifier,
        password: password,
      );

      // If successful, we are logged in as Admin.
      // We should store this session token securely. (Skipping SecureStorage specific implementation for brevity, relying on memory state)
      // Ideally: await secureStorage.write(key: 'admin_session', value: jsonEncode(adminData));

      state = state.copyWith(isLoading: false, isLoggedIn: true);
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Exception:')) {
        msg = msg.replaceAll('Exception: ', '');
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }

  Future<void> submitRequest({
    required String fullName,
    required String username,
    required String adminId,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (fullName.isEmpty ||
          username.isEmpty ||
          adminId.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        throw Exception('All fields are required');
      }

      await ref
          .read(supabaseServiceProvider)
          .submitAdminRequest(
            fullName: fullName,
            username: username,
            email: email,
            adminId: adminId,
            password: password,
          );

      state = state.copyWith(isLoading: false, requestStatus: 'pending');
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Uniqueness violation') || msg.contains('23505')) {
        msg = 'Request already exists for this Email or Admin ID.';
      } else if (msg.contains('Exception:')) {
        msg = msg.replaceAll('Exception: ', '');
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }

  void logout() {
    state = const AdminAuthState();
  }
}

final adminAuthProvider = NotifierProvider<AdminAuthNotifier, AdminAuthState>(
  AdminAuthNotifier.new,
);
