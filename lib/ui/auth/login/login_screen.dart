import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
    final bgGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      // slightly lighter, modern purple middle tone
      colors: [Color(0xFF2E0F3B), Color(0xFF5C2B7A)],
    );

    final auth = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);

    bool isFormValid() => _idCtrl.text.trim().isNotEmpty && _pwCtrl.text.trim().isNotEmpty;

    InputDecoration fieldDecoration(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBDB1C9)),
          filled: true,
          fillColor: const Color(0x14FFFFFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Logo placeholder - uses asset at asset/image/GC_logo.png
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/images/GC_logo.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Graduate Chronicles', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('Your University Story, Reimagined.', style: TextStyle(color: Color(0xFFD6C9E6), fontSize: 13)),

                  const SizedBox(height: 18),

                  // Compact Card container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: DesignSystem.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab row (smaller)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(color: DesignSystem.purpleAccent, borderRadius: BorderRadius.circular(6)),
                                  child: const Center(child: Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () => Navigator.of(context).pushReplacementNamed('/signup1'),
                                  child: Container(padding: const EdgeInsets.symmetric(vertical: 8), child: const Center(child: Text('Sign Up', style: TextStyle(color: Color(0xFFBDB1C9))))),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        const Text('Email', style: TextStyle(color: Color(0xFFD6C9E6))),
                        const SizedBox(height: 6),
                        SizedBox(height: 46, child: TextField(controller: _idCtrl, decoration: fieldDecoration('Enter your email'))),
                        const SizedBox(height: 10),
                        const Text('Password', style: TextStyle(color: Color(0xFFD6C9E6))),
                        const SizedBox(height: 6),
                        _PasswordField(decoration: fieldDecoration('Enter your password'), controller: _pwCtrl),

                        const SizedBox(height: 8),
                        if (auth.error != null) Padding(padding: const EdgeInsets.only(top: 6.0), child: Text(auth.error!, style: const TextStyle(color: Colors.orangeAccent))),

                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(context).pushNamed('/forgot'), child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF9B2CFF))))),

                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (auth.loading || !isFormValid())
                                ? null
                                : () async {
                                    final success = await notifier.signIn(email: _idCtrl.text, password: _pwCtrl.text);
                                    if (success && mounted) Navigator.of(context).pushReplacementNamed('/app');
                                  },
                            style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: auth.loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: TextStyle(color: Color(0xFFBDB1C9)),
                        children: [
                          TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFF9B2CFF))),
                          TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFF9B2CFF))),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final InputDecoration decoration;
  final TextEditingController controller;
  const _PasswordField({Key? key, required this.decoration, required this.controller}) : super(key: key);

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        decoration: widget.decoration.copyWith(
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
    );
  }
}
