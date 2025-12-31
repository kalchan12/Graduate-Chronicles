import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/auth_provider.dart';

class SignupStep1 extends ConsumerStatefulWidget {
  const SignupStep1({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupStep1> createState() => _SignupStep1State();
}

class _SignupStep1State extends ConsumerState<SignupStep1> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(authProvider).draft;
    _username.text = draft.username;
    _fullName.text = draft.fullName;
    _email.text = draft.email;
    _password.text = draft.password;
  }

  @override
  void dispose() {
    _username.dispose();
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _isEmailValid(String e) {
    final t = e.trim();
    return t.contains('@') && t.split('@').last.contains('.');
  }

  bool _isPasswordStrong(String p) {
    if (p.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(p)) return false;
    if (!RegExp(r'[a-z]').hasMatch(p)) return false;
    if (!RegExp(r'\d').hasMatch(p)) return false;
    if (!RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]').hasMatch(p)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(authProvider).draft;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DesignSystem.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('Step 1 of 4', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text('Create Your Account', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
              ),

              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      _buildField(label: 'Username', hint: 'Choose a username', icon: Icons.alternate_email, controller: _username),
                      const SizedBox(height: 12),
                      _buildField(label: 'Full Name', hint: 'Enter your full name', icon: Icons.person, controller: _fullName),
                      const SizedBox(height: 12),
                      _buildField(label: 'Email', hint: 'Enter your email', icon: Icons.email, controller: _email),
                      const SizedBox(height: 12),
                      _buildField(label: 'Password', hint: 'Must be at least 8 characters', icon: Icons.lock, obscure: true, controller: _password),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_username.text.trim().isEmpty || !_isEmailValid(_email.text) || !_isPasswordStrong(_password.text))
                              ? null
                              : () {
                                  ref.read(authProvider.notifier).updateDraft(username: _username.text.trim(), fullName: _fullName.text.trim(), email: _email.text.trim(), password: _password.text);
                                  Navigator.of(context).pushReplacementNamed('/signup2');
                                },
                          style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Next', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/login'), child: const Text('Already have an account? Log In', style: TextStyle(color: Colors.white70))),
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

  Widget _buildField({required String label, required String hint, required IconData icon, bool obscure = false, TextEditingController? controller}) {
    controller ??= TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFD6C9E6))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, color: Colors.white54),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: controller, obscureText: obscure, decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: Colors.white38)))),
            ],
          ),
        ),
      ],
    );
  }
}
  static Widget _buildField({required String label, required String hint, required IconData icon, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFD6C9E6))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, color: Colors.white54),
              const SizedBox(width: 8),
              Expanded(child: TextField(obscureText: obscure, decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: Colors.white38)))),
            ],
          ),
        ),
      ],
    );
  }
}
