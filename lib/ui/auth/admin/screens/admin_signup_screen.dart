import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/admin_auth_state.dart';

/*
  Admin Access Request Screen.
  
  Allows authenticated users to request access to the Admin Portal.
  
  Collects:
  - Full Name & University Credentials
  - Admin ID (for verification)
  
  Status:
  - Pending: Show waiting screen
  - Approved: Redirect to dashboard
  - Rejected: Show rejection message
*/
class AdminSignupScreen extends ConsumerStatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  ConsumerState<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends ConsumerState<AdminSignupScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _adminIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Isolated Admin System:
    // No user auth required to see this screen.
    // Also no auto-check of status, as we don't have IDs.
  }

  Future<void> _handleSubmit() async {
    await ref
        .read(adminAuthProvider.notifier)
        .submitRequest(
          fullName: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          adminId: _adminIdCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );

    if (mounted) {
      final state = ref.read(adminAuthProvider);
      if (state.requestStatus == 'pending') {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2E0F3B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B1E54),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF9B2CFF),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Request Submitted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your request for admin access has been submitted for review. You can check back here for updates.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD6C9E6), height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop twice to go back to origin (profile or settings)
                    // Or assume pushReplacement was used, so maybe pushNamed home
                    // Just pop for now.
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B2CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Return',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminAuthProvider);

    // Gradient Background
    final bgGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1A1025), Color(0xFF2E0F3B)],
    );

    // View based on Status
    Widget content;

    if (state.isLoading) {
      content = const Center(
        child: CircularProgressIndicator(color: Color(0xFF9B2CFF)),
      );
    } else if (state.requestStatus == 'pending') {
      content = _buildStatusView(
        icon: Icons.hourglass_empty,
        title: 'Request Pending',
        message:
            'Your request is currently being reviewed by an administrator. Please check back later.',
        color: Colors.orangeAccent,
      );
    } else if (state.requestStatus == 'approved') {
      content = _buildStatusView(
        icon: Icons.check_circle_outline,
        title: 'Access Approved',
        message: 'Congratulations! You have been granted admin access.',
        color: Colors.greenAccent,
        action: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/admin/dashboard');
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text(
            'Go to Dashboard',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else if (state.requestStatus == 'rejected') {
      content = _buildStatusView(
        icon: Icons.highlight_off,
        title: 'Request Rejected',
        message:
            'Your request for admin access was denied. Please contact support if you believe this is an error.',
        color: Colors.redAccent,
      );
    } else {
      // Default: Form
      content = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B1E54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security, color: Color(0xFF9B2CFF), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'REQ ACCESS',
                        style: TextStyle(
                          color: Color(0xFF9B2CFF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Request Admin Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: Color(0xFFD6C9E6),
                    fontSize: 15,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: 'Verify your credentials to manage the '),
                    TextSpan(
                      text: 'Graduate Chronicles',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9B2CFF),
                      ),
                    ),
                    TextSpan(text: ' yearbook.'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            _Label('Full Name'),
            _Input(
              controller: _nameCtrl,
              hint: 'e.g. Dr. Sarah Miller',
              icon: Icons.badge_outlined,
            ),

            const SizedBox(height: 16),
            _Label('Username'),
            _Input(
              controller: _usernameCtrl,
              hint: 'admin_sarah',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 16),
            _Label('University Email'),
            _Input(
              controller: _emailCtrl,
              hint: 'name@university.edu',
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 16),
            _Label('Admin ID'),
            _Input(
              controller: _adminIdCtrl,
              hint: 'XXXX-XXXX',
              icon: Icons.vpn_key_outlined,
            ),

            const SizedBox(height: 16),
            _Label('Password'),
            _PasswordInput(
              controller: _passwordCtrl,
              hint: 'Create a password',
            ),

            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B00FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Submit Request',
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
            const SizedBox(height: 30),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusView({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          if (action != null) ...[const SizedBox(height: 32), action],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _Input({
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
          suffixIcon: Icon(icon, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const _PasswordInput({required this.controller, required this.hint});

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
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
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Colors.white38,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.white38,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
