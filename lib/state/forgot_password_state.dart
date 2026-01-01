import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotState {
  final String email;
  final String? emailError;

  final String otp;
  final String? otpError;

  final String newPassword;
  final String? newPasswordError;
  final String confirmPassword;
  final String? confirmPasswordError;

  final int timerSeconds;
  final bool isSubmitting;

  const ForgotState({
    this.email = '',
    this.emailError,
    this.otp = '',
    this.otpError,
    this.newPassword = '',
    this.newPasswordError,
    this.confirmPassword = '',
    this.confirmPasswordError,
    this.timerSeconds = 60,
    this.isSubmitting = false,
  });

  ForgotState copyWith({
    String? email,
    String? Function()? emailError,
    String? otp,
    String? Function()? otpError,
    String? newPassword,
    String? Function()? newPasswordError,
    String? confirmPassword,
    String? Function()? confirmPasswordError,
    int? timerSeconds,
    bool? isSubmitting,
  }) {
    return ForgotState(
      email: email ?? this.email,
      emailError: emailError != null ? emailError() : this.emailError,
      otp: otp ?? this.otp,
      otpError: otpError != null ? otpError() : this.otpError,
      newPassword: newPassword ?? this.newPassword,
      newPasswordError: newPasswordError != null
          ? newPasswordError()
          : this.newPasswordError,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      confirmPasswordError: confirmPasswordError != null
          ? confirmPasswordError()
          : this.confirmPasswordError,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ForgotNotifier extends Notifier<ForgotState> {
  Timer? _timer;

  @override
  ForgotState build() {
    return const ForgotState();
  }

  void setEmail(String val) {
    state = state.copyWith(email: val, emailError: () => null);
  }

  void setOtp(String val) {
    state = state.copyWith(otp: val, otpError: () => null);
  }

  bool validateEmail() {
    if (state.email.trim().isEmpty) {
      state = state.copyWith(emailError: () => "Email is required");
      return false;
    }
    if (!state.email.contains('@')) {
      state = state.copyWith(emailError: () => "Invalid email format");
      return false;
    }
    return true;
  }

  void startTimer() {
    _timer?.cancel();
    state = state.copyWith(timerSeconds: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.timerSeconds <= 0) {
        t.cancel();
      } else {
        state = state.copyWith(timerSeconds: state.timerSeconds - 1);
      }
    });
  }

  void resendCode() {
    // Logic to resend API
    startTimer();
  }

  bool validateOtp() {
    if (state.otp.length < 4) {
      state = state.copyWith(otpError: () => "Complete the 4-digit code");
      return false;
    }
    return true;
  }

  void setNewPassword(String val) =>
      state = state.copyWith(newPassword: val, newPasswordError: () => null);
  void setConfirmPassword(String val) => state = state.copyWith(
    confirmPassword: val,
    confirmPasswordError: () => null,
  );

  bool validateReset() {
    String? npErr, cpErr;
    if (state.newPassword.length < 8) npErr = "At least 8 characters";
    if (state.newPassword != state.confirmPassword) {
      cpErr = "Passwords do not match";
    }

    state = state.copyWith(
      newPasswordError: () => npErr,
      confirmPasswordError: () => cpErr,
    );
    return npErr == null && cpErr == null;
  }
}

final forgotProvider = NotifierProvider<ForgotNotifier, ForgotState>(
  ForgotNotifier.new,
);
