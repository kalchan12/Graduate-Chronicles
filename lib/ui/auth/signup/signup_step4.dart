import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/auth_provider.dart';

class SignupStep4 extends ConsumerStatefulWidget {
  const SignupStep4({super.key});

  @override
  ConsumerState<SignupStep4> createState() => _SignupStep4State();
}

class _SignupStep4State extends ConsumerState<SignupStep4> {
  late Map<String, bool> _choices;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(authProvider).draft;
    // initialize choices from draft.interests
    final defaultKeys = ['Code', 'Math', 'Science', 'Literature', 'History', 'Design', 'Arts', 'Music', 'Photography', 'Writing', 'Sports', 'Gaming', 'Travel', 'Fitness', 'Movies'];
    _choices = {for (var k in defaultKeys) k: draft.interests.contains(k)};
  }

  Future<void> _finish() async {
    final selected = _choices.entries.where((e) => e.value).map((e) => e.key).toList();
    // persist selections
    ref.read(authProvider.notifier).updateDraft(interests: selected);

    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Confirm'), content: const Text('Complete signup with selected preferences?'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Confirm'))]));
    if (confirmed != true) return;

    // finalize signup (in-memory)
    await ref.read(authProvider.notifier).finalizeSignup();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signup complete')));
    Navigator.of(context).pushReplacementNamed('/login');
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
              Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), child: SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: _finish, style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Finish')))),
            ],
          ),
        ),
      ),
    );
  }
}
