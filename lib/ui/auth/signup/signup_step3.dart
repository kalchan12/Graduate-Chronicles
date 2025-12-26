import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';

class SignupStep3 extends StatelessWidget {
  const SignupStep3({Key? key}) : super(key: key);

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
                      child: const Center(child: Icon(Icons.camera_alt, color: Colors.white30, size: 36)),
                    ),
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Upload Photo')),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/signup4'), child: const Text('Skip for now', style: TextStyle(color: Colors.white70))),
                    const SizedBox(height: 12),
                    const SizedBox(height: 18),
                    SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/signup4'), style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Finish'))),
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
