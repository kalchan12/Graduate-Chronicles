import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/signup_state.dart';

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
                        onChanged: (v) => notifier.setField('password', v),
                      ),
                      const SizedBox(height: 12),
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
                          onPressed: () {
                            // On Next, we don't need to manually set fields again because onChanged does it.
                            // But for safety or if onChanged didn't fire (e.g. initial empty), validation checks state.
                            // Actually, removing fields from initState doesn't sync if text field changes without onChanged.
                            // onChanged is present.

                            if (notifier.validateStep1()) {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/signup2');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
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
}
