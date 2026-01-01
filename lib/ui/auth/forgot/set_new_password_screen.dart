import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/forgot_password_state.dart';

class SetNewPasswordScreen extends ConsumerStatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  ConsumerState<SetNewPasswordScreen> createState() =>
      _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends ConsumerState<SetNewPasswordScreen> {
  final TextEditingController _newCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill
    final state = ref.read(forgotProvider);
    _newCtrl.text = state.newPassword;
    _confirmCtrl.text = state.confirmPassword;
  }

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (ref.read(forgotProvider.notifier).validateReset()) {
      Navigator.of(context).pushNamed('/forgot/done');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotProvider);
    final notifier = ref.read(forgotProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1022),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
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
                        // lock icon with subtle glow
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
                                  Icons.lock,
                                  size: 48,
                                  color: DesignSystem.purpleAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Secure Your Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create a strong password to secure your profile. Your new password must be different from previously used passwords.',
                          style: TextStyle(color: Color(0xFFD6C9E6)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'New Password',
                            style: TextStyle(color: Color(0xFFD6C9E6)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newCtrl,
                          obscureText: _obscureNew,
                          onChanged: (v) => notifier.setNewPassword(v),
                          decoration: InputDecoration(
                            hintText: 'Enter new password',
                            filled: true,
                            fillColor: const Color(0xFF241228),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFBDB1C9),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white54,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (state.newPasswordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(
                              state.newPasswordError!,
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 14),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Confirm New Password',
                            style: TextStyle(color: Color(0xFFD6C9E6)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmCtrl,
                          obscureText: _obscureConfirm,
                          onChanged: (v) => notifier.setConfirmPassword(v),
                          decoration: InputDecoration(
                            hintText: 'Re-enter password',
                            filled: true,
                            fillColor: const Color(0xFF241228),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFBDB1C9),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white54,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (state.confirmPasswordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(
                              state.confirmPasswordError!,
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.purpleAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Set New Password',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
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
