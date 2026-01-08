import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/admin_auth_state.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    await ref
        .read(adminAuthProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text.trim());

    // Check success
    if (mounted) {
      final state = ref.read(adminAuthProvider);
      if (state.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/admin/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminAuthProvider);
    final bgGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1A1025), Color(0xFF2E0F3B)],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Admin Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B1E54),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Color(0xFF9B2CFF),
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Restricted Access',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Please enter your administrative credentials to access the dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFD6C9E6),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Form
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Admin ID or Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AdminTextField(
                        controller: _emailCtrl,
                        hint: 'admin@university.edu',
                        icon: Icons.badge_outlined,
                      ),

                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AdminPasswordField(
                        controller: _passCtrl,
                        hint: 'Enter your password',
                      ),

                      if (state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {}, // Simulated
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFF9B2CFF)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF8B00FF,
                            ), // Bright purple
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Login to Dashboard',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Request Access Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Need administrative privileges? ',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/admin/signup');
                            },
                            child: const Text(
                              'Request Access',
                              style: TextStyle(
                                color: Color(0xFF9B2CFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white12)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR LOGIN WITH',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white12)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Mock Social Login
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.face,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFBDB1C9),
                          size: 18,
                        ),
                        label: const Text(
                          'Return to Student Login',
                          style: TextStyle(color: Color(0xFFBDB1C9)),
                        ),
                      ),
                      const SizedBox(height: 20),
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

class _AdminTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _AdminTextField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _AdminPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const _AdminPasswordField({required this.controller, required this.hint});

  @override
  State<_AdminPasswordField> createState() => _AdminPasswordFieldState();
}

class _AdminPasswordFieldState extends State<_AdminPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
          suffixIcon: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.white38,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
