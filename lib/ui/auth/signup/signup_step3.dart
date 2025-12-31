import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/auth_provider.dart';

class SignupStep3 extends ConsumerStatefulWidget {
  const SignupStep3({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupStep3> createState() => _SignupStep3State();
}

class _SignupStep3State extends ConsumerState<SignupStep3> {
  Uint8List? _avatarBytes;

  Future<void> _simulatePickFromAssets() async {
    // Simulate picking an image by loading an app asset into memory.
    try {
      final data = await rootBundle.load('assets/images/GC_logo.png');
      setState(() => _avatarBytes = data.buffer.asUint8List());
      ref.read(authProvider.notifier).setDraftAvatar(_avatarBytes!);
    } catch (_) {
      // ignore if asset missing
    }
  }

  @override
  void initState() {
    super.initState();
    final draft = ref.read(authProvider).draft;
    _avatarBytes = draft.avatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DesignSystem.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 18),
              const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Step 3 of 4', style: TextStyle(color: Colors.white70))),
              const SizedBox(height: 8),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 28), child: Text('Set up your profile', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800), textAlign: TextAlign.center)),
              const SizedBox(height: 12),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 36), child: Text('Add a photo so your friends can find you.', style: TextStyle(color: Color(0xFFBEB2DF), fontSize: 14), textAlign: TextAlign.center)),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(80), border: Border.all(color: Colors.white24, width: 2)),
                      child: _avatarBytes == null
                          ? const Center(child: Icon(Icons.camera_alt, color: Colors.white30, size: 36))
                          : ClipRRect(borderRadius: BorderRadius.circular(80), child: Image.memory(_avatarBytes!, fit: BoxFit.cover)),
                    ),
                    ElevatedButton(onPressed: _simulatePickFromAssets, style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Upload Photo')),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/signup4'), child: const Text('Skip for now', style: TextStyle(color: Colors.white70))),
                    const SizedBox(height: 12),
                    const SizedBox(height: 18),
                    SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/signup4'), style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Next'))),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildField({required String label, required String hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFFD6C9E6))),
      const SizedBox(height: 6),
      Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 12), child: TextField(decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: Colors.white38))))
    ]);
  }
}
