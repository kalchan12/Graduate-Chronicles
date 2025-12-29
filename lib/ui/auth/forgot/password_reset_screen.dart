import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focus = List.generate(4, (_) => FocusNode());
  int _seconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        final text = _controllers[i].text;
        if (text.isNotEmpty && i < _controllers.length - 1) {
          _focus[i + 1].requestFocus();
        }
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 0) {
        t.cancel();
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
      width: 64,
      height: 64,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focus[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(counterText: '', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits((_seconds ~/ 60));
    final seconds = twoDigits((_seconds % 60));

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
                  child: const Icon(Icons.mark_email_read, size: 44, color: DesignSystem.purpleAccent),
                ),
                const SizedBox(height: 18),
                const Text('Verification Code', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Please enter the 4-digit code sent to your email address.', style: TextStyle(color: Color(0xFFD6C9E6)), textAlign: TextAlign.center),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(4, (i) => _pinField(i))),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/forgot/set'),
                    style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                if (_seconds > 0)
                  Text('Resend code in $minutes:$seconds', style: const TextStyle(color: Color(0xFFD6C9E6)))
                else
                  TextButton(onPressed: () => _startTimer(), child: const Text('Resend code', style: TextStyle(color: DesignSystem.purpleAccent))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
