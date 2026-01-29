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
  
  Validates input before allowing navigation to Step 2.
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupFormProvider);
    final notifier = ref.read(signupFormProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E0F3B), DesignSystem.purpleDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48), // Balance icon
                        child: Center(
                          child: Text(
                            'Step 1 of 4',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Create Your Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      _buildField(
                        label: 'Username',
                        hint: 'Choose a username',
                        icon: Icons.alternate_email,
                        controller: _username,
                        errorText: state.usernameError,
                        onChanged: (v) => notifier.setField('username', v),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person,
                        controller: _fullName,
                        errorText: state.fullNameError,
                        onChanged: (v) => notifier.setField('fullName', v),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.email,
                        controller: _email,
                        errorText: state.emailError,
                        onChanged: (v) => notifier.setField('email', v),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Password',
                        hint: 'Must be at least 8 characters',
                        icon: Icons.lock,
                        obscure: true,
                        controller: _password,
                        errorText: state.passwordError,

                        onChanged: (v) {
                          notifier.setField('password', v);
                          setState(() {}); // Rebuild for strength indicator
                        },
                      ),
                      const SizedBox(height: 8),
                      // Password Strength Indicator
                      if (state.password.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: _buildPasswordStrengthIndicator(
                            state.password,
                          ),
                        ),
                      const SizedBox(height: 4),
                      _buildField(
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        icon: Icons.lock_outline,
                        obscure: true,
                        controller: _confirmPassword,
                        errorText: state.confirmPasswordError,
                        onChanged: (v) =>
                            notifier.setField('confirmPassword', v),
                      ),
                      const SizedBox(height: 18),
                      // Button always visible/enabled
                      SizedBox(
                        width: double.infinity,
                        height: 52,
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
                                      // Note: Institutional ID is collected in Step 2.
                                      // Step 1 collects Username, Email.
                                      final error = await service
                                          .checkUserUniqueness(
                                            username: state.username,
                                            email: state.email,
                                          );

                                      if (error != null) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(error),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      if (mounted) {
                                        Navigator.of(
                                          context,
                                        ).pushReplacementNamed('/signup2');
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Verification failed: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted)
                                        setState(() => _isLoading = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Next',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/login'),
                        child: const Text(
                          'Already have an account? Log In',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    controller ??= TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFD6C9E6))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, color: Colors.white54),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  onChanged: onChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(String password) {
    if (password.isEmpty) return const SizedBox.shrink();

    // Password Strength Rules:
    // 0: Weak - < 8 chars OR just letters/numbers
    // 1: Medium - 8+ chars AND (letters + numbers)
    // 2: Strong - 8+ chars AND (letters + numbers + special)
    // 3: Secure - 12+ chars AND (letters + numbers + special)

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
      3 => const Color(0xFF00FF9D), // Secure Green
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
                height: 6, // Thicker bar
                decoration: BoxDecoration(
                  color: active ? color : Colors.white10,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Optional: Helper text
            if (strength < 2)
              const Text(
                'Use letters, numbers & symbols',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ],
        ),
      ],
    );
  }
}
