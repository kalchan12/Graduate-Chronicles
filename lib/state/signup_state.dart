import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class SignupState {
  final int currentStep;

  // Step 1 Data
  final String username;
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  // Step 1 Errors
  final String? usernameError;
  final String? fullNameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  // Step 2 Data
  final String? role;
  final String? department;
  final String? graduationYear;

  // Step 2 Errors
  final String? roleError;
  final String? departmentError;
  final String? yearError;

  // Step 3 Data
  final Uint8List? avatar;

  // Step 4 Data
  final List<String> interests;

  // Loading
  final bool isSubmitting;

  const SignupState({
    this.currentStep = 0,
    this.username = '',
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.usernameError,
    this.fullNameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.role,
    this.department,
    this.graduationYear,
    this.roleError,
    this.departmentError,
    this.yearError,
    this.avatar,
    this.interests = const [],
    this.isSubmitting = false,
  });

  SignupState copyWith({
    int? currentStep,
    String? username,
    String? fullName,
    String? email,
    String? password,
    String? confirmPassword,
    String? Function()? usernameError,
    String? Function()? fullNameError,
    String? Function()? emailError,
    String? Function()? passwordError,
    String? Function()? confirmPasswordError,
    String? role,
    String? department,
    String? graduationYear,
    String? Function()? roleError,
    String? Function()? departmentError,
    String? Function()? yearError,
    Uint8List? avatar,
    List<String>? interests,
    bool? isSubmitting,
  }) {
    return SignupState(
      currentStep: currentStep ?? this.currentStep,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      usernameError: usernameError != null
          ? usernameError()
          : this.usernameError,
      fullNameError: fullNameError != null
          ? fullNameError()
          : this.fullNameError,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null
          ? passwordError()
          : this.passwordError,
      confirmPasswordError: confirmPasswordError != null
          ? confirmPasswordError()
          : this.confirmPasswordError,
      role: role ?? this.role,
      department: department ?? this.department,
      graduationYear: graduationYear ?? this.graduationYear,
      roleError: roleError != null ? roleError() : this.roleError,
      departmentError: departmentError != null
          ? departmentError()
          : this.departmentError,
      yearError: yearError != null ? yearError() : this.yearError,
      avatar: avatar ?? this.avatar,
      interests: interests ?? this.interests,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class SignupNotifier extends Notifier<SignupState> {
  @override
  SignupState build() {
    return const SignupState();
  }

  void setField(String key, String value) {
    if (key == 'username') {
      state = state.copyWith(username: value, usernameError: () => null);
    }
    if (key == 'fullName') {
      state = state.copyWith(fullName: value, fullNameError: () => null);
    }
    if (key == 'email') {
      state = state.copyWith(email: value, emailError: () => null);
    }
    if (key == 'password') {
      state = state.copyWith(password: value, passwordError: () => null);
    }
    if (key == 'confirmPassword') {
      state = state.copyWith(
        confirmPassword: value,
        confirmPasswordError: () => null,
      );
    }
    if (key == 'department') {
      state = state.copyWith(department: value, departmentError: () => null);
    }
    if (key == 'graduationYear') {
      state = state.copyWith(graduationYear: value, yearError: () => null);
    }
  }

  void setRole(String? val) {
    state = state.copyWith(role: val, roleError: () => null);
  }

  void setAvatar(Uint8List? data) {
    state = state.copyWith(avatar: data);
  }

  void toggleInterest(String interest) {
    final current = List<String>.from(state.interests);
    if (current.contains(interest)) {
      current.remove(interest);
    } else {
      current.add(interest);
    }
    state = state.copyWith(interests: current);
  }

  bool validateStep1() {
    String? uErr, fErr, eErr, pErr, cpErr;

    if (state.username.trim().isEmpty) {
      uErr = "Username is required";
    }
    if (state.fullName.trim().isEmpty) {
      fErr = "Full name is required";
    }

    // Email
    final e = state.email.trim();
    if (e.isEmpty) {
      eErr = "Email is required";
    } else if (!e.contains('@')) {
      eErr = "Invalid email format";
    }

    // Password
    final p = state.password;
    if (p.isEmpty) {
      pErr = "Password is required";
    } else if (p.length < 8) {
      pErr = "Must be at least 8 chars";
    }
    // (Add stronger regex if needed per prompt, but prompt said weak/medium/strong usage)
    // The prompt requires: "Password must be at least 8 characters" + match check

    if (state.confirmPassword != p) {
      cpErr = "Passwords do not match";
    }

    state = state.copyWith(
      usernameError: () => uErr,
      fullNameError: () => fErr,
      emailError: () => eErr,
      passwordError: () => pErr,
      confirmPasswordError: () => cpErr,
    );

    return uErr == null &&
        fErr == null &&
        eErr == null &&
        pErr == null &&
        cpErr == null;
  }

  bool validateStep2() {
    String? rErr, dErr, yErr;
    if (state.role == null) {
      rErr = "Role is required";
    }
    if (state.department?.trim().isEmpty ?? true) {
      dErr = "Department is required";
    }
    if (state.graduationYear?.trim().isEmpty ?? true) {
      yErr = "Year is required";
    }

    state = state.copyWith(
      roleError: () => rErr,
      departmentError: () => dErr,
      yearError: () => yErr,
    );

    return rErr == null && dErr == null && yErr == null;
  }

  Future<void> submitSignup(BuildContext context) async {
    state = state.copyWith(isSubmitting: true);

    // Finalize via main auth provider
    final authFn = ref.read(authProvider.notifier);
    await authFn.signup(
      email: state.email,
      password: state.password,
      username: state.username,
    );
    // Ideally we also store other fields, but authProvider.signup() is simple in this demo.
    // In real app we'd send all data.

    state = state.copyWith(isSubmitting: false);

    // reset draft
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/app', (r) => false);
    }
  }
}

final signupFormProvider = NotifierProvider<SignupNotifier, SignupState>(
  SignupNotifier.new,
);
