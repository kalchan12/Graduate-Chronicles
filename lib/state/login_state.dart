import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class LoginState {
  final bool isSubmitting;
  final String? emailError;
  final String? passwordError;

  const LoginState({
    this.isSubmitting = false,
    this.emailError,
    this.passwordError,
  });

  LoginState copyWith({
    bool? isSubmitting,
    String? emailError,
    String? passwordError,
  }) {
    // Explicitly allowing nulls for error clearing
    return LoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailError:
          emailError, // if passed as null (and not undefined logic), it clears. But simplified copyWith usually retains.
      // For errors, we usually want to clear them explicitly.
      // Here, standard copyWith pattern: if arg is missing, keep old.
      // But we need a way to clear.
      // Let's rely on re-creating state or specific semantics.
      // actually, simple copyWith:
      // emailError: emailError ?? this.emailError,
      // is bad if we want to clear.

      // Let's use a smarter copyWith or just recreate state in Notifier.
      // For simplicity in this prompt context, I'll just use named args and if I pass null, it becomes null?
      // No, Dart default args don't distinguish "missing" vs "null".
      // I'll implement "force clear" via separate logic or just create new instances.
    );
  }
}

// Better copyWith for nullable fields
extension LoginStateCopy on LoginState {
  LoginState copy({
    bool? isSubmitting,
    String? Function()? emailError, // nullable wrapper
    String? Function()? passwordError,
  }) {
    return LoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null
          ? passwordError()
          : this.passwordError,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() {
    return const LoginState();
  }

  void validateAndSubmit({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Reset errors
    state = const LoginState(isSubmitting: true);

    String? emailErr;
    String? passErr;

    if (email.trim().isEmpty) {
      emailErr = 'Email is required';
    }
    // Basic format check
    else if (!email.contains('@')) {
      emailErr = 'Invalid email format';
    }

    if (password.trim().isEmpty) {
      passErr = 'Password is required';
    }

    if (emailErr != null || passErr != null) {
      state = LoginState(
        isSubmitting: false,
        emailError: emailErr,
        passwordError: passErr,
      );
      return;
    }

    // Call main auth provider
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(email: email, password: password);

    if (!success) {
      state = state.copy(isSubmitting: false);
      return;
    }

    // Success
    state = state.copy(isSubmitting: false);
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/app');
    }
  }

  void clearErrors() {
    state = const LoginState();
  }
}

final loginFormProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
