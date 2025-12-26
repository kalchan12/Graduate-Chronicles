import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';

class SignupStep1 extends StatelessWidget {
  const SignupStep1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      _buildField(label: 'Username', hint: 'Choose a username', icon: Icons.alternate_email),
                      const SizedBox(height: 12),
                      _buildField(label: 'Full Name', hint: 'Enter your full name', icon: Icons.person),
                      const SizedBox(height: 12),
                      _buildField(label: 'Email', hint: 'Enter your email', icon: Icons.email),
                      const SizedBox(height: 12),
                      _buildField(label: 'Password', hint: 'Must be at least 8 characters', icon: Icons.lock, obscure: true),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/signup2'),
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
