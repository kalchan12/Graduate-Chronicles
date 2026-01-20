import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase/supabase_service.dart';

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
  final String? userId;
  final String? major;
  final String? graduationYear;

  // Step 2 Errors
  final String? roleError;
  final String? userIdError;
  final String? majorError;
  final String? yearError;

  // Step 3 Data
  final Uint8List? profileImage;

  // Step 4 Data
  final String? bio; // New Bio field
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
    this.userId,
    this.major,
    this.graduationYear,
    this.roleError,
    this.userIdError,
    this.majorError,
    this.yearError,
    this.bio,
    this.profileImage,
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
    String? userId,
    String? major,
    String? graduationYear,
    String? Function()? roleError,
    String? Function()? userIdError,
    String? Function()? majorError,
    String? Function()? yearError,
    String? bio,
    Uint8List? profileImage,
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
      userId: userId ?? this.userId,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
      roleError: roleError != null ? roleError() : this.roleError,
      userIdError: userIdError != null ? userIdError() : this.userIdError,
      majorError: majorError != null ? majorError() : this.majorError,
      yearError: yearError != null ? yearError() : this.yearError,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
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
    if (key == 'major') {
      state = state.copyWith(major: value, majorError: () => null);
    }
    if (key == 'userId') {
      state = state.copyWith(userId: value, userIdError: () => null);
    }
    // majorNameOther removed
    if (key == 'graduationYear') {
      state = state.copyWith(graduationYear: value, yearError: () => null);
    }
  }

  void setRole(String? val) {
    state = state.copyWith(role: val, roleError: () => null);
  }

  void setProfileImage(Uint8List? data) {
    state = state.copyWith(profileImage: data);
  }

  void setBio(String val) {
    state = state.copyWith(bio: val);
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
    String? rErr, uErr, mErr, yErr;
    if (state.role == null) {
      rErr = "Role is required";
    }

    // User ID validation - required for all roles
    if (state.userId?.trim().isEmpty ?? true) {
      uErr = "ID is required";
    }

    if (state.major?.trim().isEmpty ?? true) {
      mErr = "Major is required";
    }

    // Graduation Year Validation
    final yStr = state.graduationYear?.trim();
    if (yStr == null || yStr.isEmpty) {
      yErr = "Year is required";
    } else {
      final yInt = int.tryParse(yStr);
      if (yInt == null || yStr.length != 4) {
        yErr = "Enter a valid 4-digit year";
      } else if (yInt < 2026) {
        yErr = "Year must be 2026 or later";
      }
    }

    state = state.copyWith(
      roleError: () => rErr,
      userIdError: () => uErr,
      majorError: () => mErr,
      yearError: () => yErr,
    );

    return rErr == null && uErr == null && mErr == null && yErr == null;
  }

  Future<void> submitSignup(BuildContext context) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.signUp(
        email: state.email,
        password: state.password,
        username: state.username,
        fullName: state.fullName,
        role: state.role!, // Validated by step 2
        institutionalId: state.userId,
        major: state.major,
        graduationYear: int.tryParse(
          state.graduationYear ?? '',
        ), // Fixed duplicate
        interests: state.interests,
      );

      // DO NOT Reset draft yet - we need it for Step 4
      // state = const SignupState();

      // 3. Navigate to Profile Upload (Step 4)
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/signup4');
      }
    } catch (e) {
      if (context.mounted) {
        String msg =
            'Signup Failed: ${e.toString().replaceAll('Exception: ', '')}';

        // Attempt to parse known Supabase/Postgres errors (e.g. via string message if not typed)
        // Ideally we catch AuthException or PostgrestException, but 'e' is dynamic here.
        final s = e.toString().toLowerCase();
        if (s.contains('23505') || s.contains('duplicate key')) {
          if (s.contains('institutional_id') || s.contains('user_id')) {
            // Assuming constraint name or field
            msg = 'This User ID is already registered.';
          } else if (s.contains('email')) {
            msg = 'This Email is already in use.';
          } else if (s.contains('username')) {
            msg = 'This Username is already taken.';
          } else {
            msg = 'Account already exists (Duplicate info).';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> uploadProfilePicture(BuildContext context) async {
    // Only proceed if we have an image
    if (state.profileImage == null) return;

    state = state.copyWith(isSubmitting: true);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      // We need the current user ID.
      // Since we just logged in (in submitSignup), fetching currentUser should work.
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception("No authenticated user found.");
      }

      // map auth ID to internal user ID if needed, or if uploadProfilePicture uses auth ID.
      // setup.sql uses auth.uid() checks, so internal ID usage is safer.
      final internalUserId = await supabase.getCurrentUserId();
      if (internalUserId == null) throw Exception("User record not found.");

      final imagePath = await supabase.uploadProfilePicture(
        internalUserId,
        state.profileImage!,
      );

      // Create/Update Profile Entry with Path and Bio
      await supabase.upsertProfile(
        userId: internalUserId,
        profilePictureUrl: imagePath,
        bio: state.bio,
      );

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/app', (r) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      state = state.copyWith(isSubmitting: false);
      // Reset state after success
      state = const SignupState();
    }
  }

  Future<void> skipProfile(BuildContext context) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final internalUserId = await supabase.getCurrentUserId();
      if (internalUserId != null && state.bio != null) {
        // Save bio even if skipping image
        await supabase.upsertProfile(userId: internalUserId, bio: state.bio);
      }

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/app', (r) => false);
      }
    } catch (e) {
      print("Skip error: $e");
    } finally {
      // Reset final
      state = const SignupState();
    }
  }
}

final signupFormProvider = NotifierProvider<SignupNotifier, SignupState>(
  SignupNotifier.new,
);
