import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/signup_state.dart';
import '../../../services/supabase/supabase_service.dart';

/*
  Signup Step 1: Basic Account Information.
  
  Captures:
  - Username
  - Full Name
  - Email
  - Password
  
  Refined UI: Matches Login Screen aesthetics.
*/
class SignupStep1 extends ConsumerStatefulWidget {
  const SignupStep1({super.key});

  @override
  ConsumerState<SignupStep1> createState() => _SignupStep1State();
}

class _SignupStep1State extends ConsumerState<SignupStep1> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill from state
    final state = ref.read(signupFormProvider);
    _username.text = state.username;
    _fullName.text = state.fullName;
    _email.text = state.email;
    _password.text = state.password;
    _confirmPassword.text = state.confirmPassword;
  }

  @override
  void dispose() {
    _username.dispose();
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      hintStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: Colors.white24),
      filled: true,
      fillColor: const Color(0xFF2D1B36), // Matches Login
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: DesignSystem.purpleAccent,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(
        color: Colors.orangeAccent,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupFormProvider);
    final notifier = ref.read(signupFormProvider.notifier);

    // Matches Login Screen Gradient
    final bgGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [DesignSystem.purpleDark, Color(0xFF240A28)],
    );

    return Scaffold(
      backgroundColor: DesignSystem.purpleDark,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white70,
                        ),
                        onPressed: () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/login'),
                      ),
                      const Expanded(
                        child: Text(
                          'Step 1 of 4',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Create Account',
                  style: DesignSystem.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: DesignSystem.cardDecoration().copyWith(
                    borderRadius: BorderRadius.circular(28),
                    color: const Color(0xFF1A0A1F).withValues(alpha: 0.85),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Username'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _username,
                        decoration: _fieldDecoration(
                          'Choose a username',
                          Icons.alternate_email,
                        ).copyWith(errorText: state.usernameError),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        onChanged: (v) => notifier.setField('username', v),
                      ),
                      const SizedBox(height: 10),
                      _buildLabel('Full Name'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _fullName,
                        decoration: _fieldDecoration(
                          'Enter your full name',
                          Icons.person_outline,
                        ).copyWith(errorText: state.fullNameError),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        textCapitalization: TextCapitalization.words,
                        onChanged: (v) => notifier.setField('fullName', v),
                      ),
                      const SizedBox(height: 10),
                      _buildLabel('Email'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _email,
                        decoration: _fieldDecoration(
                          'Enter your email',
                          Icons.email_outlined,
                        ).copyWith(errorText: state.emailError),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (v) => notifier.setField('email', v),
                      ),
                      const SizedBox(height: 10),
                      _buildLabel('Password'),
                      const SizedBox(height: 4),
                      _PasswordField(
                        controller: _password,
                        decoration: _fieldDecoration(
                          'Min 8 characters',
                          Icons.lock_outline,
                        ),
                        onChanged: (v) {
                          notifier.setField('password', v);
                          setState(() {});
                        },
                        errorText: state.passwordError,
                      ),
                      if (state.password.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 2),
                          child: _buildPasswordStrengthIndicator(
                            state.password,
                          ),
                        ),
                      const SizedBox(height: 10),
                      _buildLabel('Confirm Password'),
                      const SizedBox(height: 4),
                      _PasswordField(
                        controller: _confirmPassword,
                        decoration: _fieldDecoration(
                          'Re-enter password',
                          Icons.lock_outline,
                        ).copyWith(errorText: state.confirmPasswordError),
                        onChanged: (v) =>
                            notifier.setField('confirmPassword', v),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (notifier.validateStep1()) {
                                    setState(() => _isLoading = true);
                                    try {
                                      final service = ref.read(
                                        supabaseServiceProvider,
                                      );
                                      final error = await service
                                          .checkUserUniqueness(
                                            username: state.username,
                                            email: state.email,
                                          );
                                      if (!mounted) return;
                                      if (error != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(error),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.of(
                                        context,
                                      ).pushReplacementNamed('/signup2');
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Verification failed: $e',
                                          ),
                                        ),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            elevation: 4,
                            shadowColor: DesignSystem.purpleAccent.withValues(
                              alpha: 0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Next Step',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.white54),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            color: DesignSystem.purpleAccent.withValues(
                              alpha: 0.9,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(String password) {
    if (password.isEmpty) return const SizedBox.shrink();

    int strength = 0;
    bool hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool isLongEnough = password.length >= 8;
    bool isVeryLong = password.length >= 12;

    if (hasLetters && hasDigits && hasSpecial && isVeryLong) {
      strength = 3;
    } else if (hasLetters && hasDigits && hasSpecial && isLongEnough) {
      strength = 2;
    } else if (hasLetters && hasDigits && isLongEnough) {
      strength = 1;
    } else {
      strength = 0;
    }

    final color = switch (strength) {
      3 => const Color(0xFF00FF9D),
      2 => Colors.greenAccent,
      1 => Colors.orangeAccent,
      _ => Colors.redAccent,
    };

    final text = switch (strength) {
      3 => 'Very Strong',
      2 => 'Strong',
      1 => 'Medium',
      _ => 'Weak',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            bool active = index <= strength;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                height: 4,
                decoration: BoxDecoration(
                  color: active ? color : Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatefulWidget {
  final InputDecoration decoration;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const _PasswordField({
    required this.decoration,
    required this.controller,
    this.onChanged,
    this.errorText,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      onChanged: widget.onChanged,
      decoration: widget.decoration.copyWith(
        errorText: widget.errorText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white38,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
