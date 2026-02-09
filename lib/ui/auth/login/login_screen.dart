import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/auth_provider.dart';
import '../../../state/login_state.dart';

/*
  The main Login Screen.
  
  Features:
  - User ID and Password authentication
  - Navigation to Signup, Forgot Password, and Admin Portal
  - Form validation and error handling via Riverpod state
*/
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _pwCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch independent form state
    final loginState = ref.watch(loginFormProvider);
    final auth = ref.watch(authProvider);

    final bgGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        DesignSystem.purpleDark,
        Color(0xFF240A28), // Deep purple variant
      ],
    );

    InputDecoration fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: Colors.white24),
      filled: true,
      fillColor: const Color(0xFF2D1B36), // Slightly lighter than bg
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
    );

    return Scaffold(
      backgroundColor: DesignSystem.purpleDark,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24), // Top padding
                      // Logo
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          height: 120,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/login icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Welcome to ASTU GC',
                        style: DesignSystem.theme.textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                      ),

                      const SizedBox(height: 24),

                      // Login Form Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: DesignSystem.cardDecoration().copyWith(
                          borderRadius: BorderRadius.circular(32),
                          color: const Color(
                            0xFF1A0A1F,
                          ).withValues(alpha: 0.85),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User ID Field
                            Text(
                              'User ID',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _idCtrl,
                              decoration: fieldDecoration('Enter your user ID'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              keyboardType: TextInputType.text,
                            ),
                            if (loginState.emailError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 6.0,
                                  left: 4,
                                ),
                                child: Text(
                                  loginState.emailError!,
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Password Field
                            Text(
                              'Password',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            _PasswordField(
                              decoration: fieldDecoration(
                                'Enter your password',
                              ),
                              controller: _pwCtrl,
                            ),
                            if (loginState.passwordError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 6.0,
                                  left: 4,
                                ),
                                child: Text(
                                  loginState.passwordError!,
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                            // Global error
                            if (auth.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          auth.errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 10),

                            // Action Links Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pushNamed('/admin/login'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Admin Portal',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pushNamed('/forgot'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: DesignSystem.purpleAccent
                                          .withValues(alpha: 0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: loginState.isSubmitting
                                    ? null
                                    : () {
                                        ref
                                            .read(loginFormProvider.notifier)
                                            .validateAndSubmit(
                                              identifier: _idCtrl.text,
                                              password: _pwCtrl.text,
                                              context: context,
                                            );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DesignSystem.purpleAccent,
                                  elevation: 4,
                                  shadowColor: DesignSystem.purpleAccent
                                      .withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: loginState.isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sign Up CTA
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/signup1'),
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(
                                        color: DesignSystem.purpleAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Footer
                      Text.rich(
                        TextSpan(
                          text: 'By continuing, you agree to our ',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: DesignSystem.purpleAccent.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: DesignSystem.purpleAccent.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
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
}

class _PasswordField extends StatefulWidget {
  final InputDecoration decoration;
  final TextEditingController controller;
  const _PasswordField({required this.decoration, required this.controller});

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
      decoration: widget.decoration.copyWith(
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
