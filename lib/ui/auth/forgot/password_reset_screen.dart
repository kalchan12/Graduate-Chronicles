import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/forgot_password_state.dart';

/*
  Forgot Password Step 2: Verification Code.
  
  User enters the 4-digit OTP sent to their email.
  - 4-digit PIN input with auto-focus
  - Countdown timer for resending code
  - Validates OTP before proceeding
*/
class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Initialize potential existing OTP
    // (If user comes back, or if we want to restore)
    // For now simple empty or pre-fill from state
    final otp = ref.read(forgotProvider).otp;
    if (otp.length == 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = otp[i];
      }
    }

    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        final text = _controllers[i].text;
        if (text.isNotEmpty && i < _controllers.length - 1) {
          _focus[i + 1].requestFocus();
        }
        _updateState();
      });
    }
  }

  void _updateState() {
    final code = _controllers.map((c) => c.text).join();
    ref.read(forgotProvider.notifier).setOtp(code);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _pinField(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focus[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 26,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < _controllers.length - 1) {
            _focus[index + 1].requestFocus();
          }
          if (v.isEmpty && index > 0) {
            _focus[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotProvider);
    final notifier = ref.read(forgotProvider.notifier);

    // Timer is managed by notifier
    final seconds = state.timerSeconds;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits((seconds ~/ 60));
    final secs = twoDigits((seconds % 60));

    return Scaffold(
      backgroundColor: const Color(0xFF1C1022),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon with glow
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const SizedBox(width: 140, height: 140),
                            Positioned(
                              child: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A1830),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DesignSystem.purpleAccent
                                          .withValues(alpha: 0.14),
                                      blurRadius: 40,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.mark_email_read,
                                  size: 48,
                                  color: DesignSystem.purpleAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Verification Code',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please enter the 6-digit code sent to ${state.email}.',
                          style: const TextStyle(color: Color(0xFFD6C9E6)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (i) => _pinField(i)),
                        ),
                        if (state.otpError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              state.otpError!,
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await notifier.verifyOtp();
                              if (success && context.mounted) {
                                Navigator.of(context).pushNamed('/forgot/set');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.purpleAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: state.isSubmitting
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Verify',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (seconds > 0)
                          Text(
                            'Resend code in $minutes:$secs',
                            style: const TextStyle(color: Color(0xFFD6C9E6)),
                          )
                        else
                          TextButton(
                            onPressed: notifier.resendCode,
                            child: const Text(
                              'Resend code',
                              style: TextStyle(
                                color: DesignSystem.purpleAccent,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
