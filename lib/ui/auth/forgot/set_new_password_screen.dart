import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _newCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? get _errorText {
    if (_confirmCtrl.text.isEmpty) return null;
    if (_newCtrl.text != _confirmCtrl.text) return 'Passwords do not match';
    return null;
  }

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    // Simulate success and navigate to success screen with animation.
    Navigator.of(context).pushNamed('/forgot/done');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1022),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: BackButton(color: Colors.white)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(color: const Color(0xFF2A1830), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.lock, size: 44, color: DesignSystem.purpleAccent),
                ),
                const SizedBox(height: 18),
                const Text('Secure Your Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Create a strong password to secure your profile. Your new password must be different from previously used passwords.', style: TextStyle(color: Color(0xFFD6C9E6)), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                TextField(
                  controller: _newCtrl,
                  obscureText: _obscureNew,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    filled: true,
                    fillColor: const Color(0xFF241228),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFBDB1C9)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Re-enter password',
                    filled: true,
                    fillColor: const Color(0xFF241228),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFBDB1C9)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_errorText!, style: const TextStyle(color: Colors.orangeAccent)),
                  ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_newCtrl.text.isNotEmpty && _confirmCtrl.text.isNotEmpty && _errorText == null) ? _submit : null,
                    style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('Set New Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
