import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';

class SignupStep4 extends StatefulWidget {
  const SignupStep4({Key? key}) : super(key: key);

  @override
  State<SignupStep4> createState() => _SignupStep4State();
}

class _SignupStep4State extends State<SignupStep4> {
  final Map<String, bool> _choices = {
    'Code': true,
    'Math': false,
    'Science': false,
    'Literature': false,
    'History': false,
    'Design': false,
    'Arts': false,
    'Music': true,
    'Photography': false,
    'Writing': false,
    'Sports': false,
    'Gaming': true,
    'Travel': false,
    'Fitness': false,
    'Movies': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DesignSystem.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 18),
              const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Step 4 of 4', style: TextStyle(color: Colors.white70))),
              const SizedBox(height: 8),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 28), child: Text('What are you into?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800), textAlign: TextAlign.center)),
              const SizedBox(height: 8),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 28), child: Text('Select a few interests to personalize your feed.', style: TextStyle(color: Color(0xFFBEB2DF), fontSize: 14), textAlign: TextAlign.center)),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _choices.keys.map((k) {
                      final active = _choices[k]!;
                      return ChoiceChip(
                        label: Text(k, style: TextStyle(color: active ? Colors.white : Colors.white70)),
                        selected: active,
                        onSelected: (v) => setState(() => _choices[k] = !_choices[k]!),
                        backgroundColor: Colors.white10,
                        selectedColor: DesignSystem.purpleAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), child: SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/login'), style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Finish')))),
            ],
          ),
        ),
      ),
    );
  }
}
