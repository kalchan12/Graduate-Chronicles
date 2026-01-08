import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/signup_state.dart';

class SignupStep4 extends ConsumerStatefulWidget {
  const SignupStep4({super.key});

  @override
  ConsumerState<SignupStep4> createState() => _SignupStep4State();
}

class _SignupStep4State extends ConsumerState<SignupStep4> {
  final List<String> _allInterests = [
    'Code',
    'Math',
    'Science',
    'Literature',
    'History',
    'Design',
    'Arts',
    'Music',
    'Photography',
    'Writing',
    'Sports',
    'Gaming',
    'Travel',
    'Fitness',
    'Movies',
  ];

  Future<void> _onFinish() async {
    // Confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Complete signup with selected preferences?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(signupFormProvider.notifier).submitSignup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupFormProvider);
    final notifier = ref.read(signupFormProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DesignSystem.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/signup3'),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48),
                        child: Center(
                          child: Text(
                            'Step 4 of 4',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'What are you into?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Select a few interests to personalize your feed.',
                  style: TextStyle(color: Color(0xFFBEB2DF), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _allInterests.map((k) {
                      final active = state.interests.contains(k);
                      return ChoiceChip(
                        label: Text(
                          k,
                          style: TextStyle(
                            color: active ? Colors.white : Colors.white70,
                          ),
                        ),
                        selected: active,
                        onSelected: (v) => notifier.toggleInterest(k),
                        backgroundColor: Colors.white10,
                        selectedColor: DesignSystem.purpleAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : _onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Finish',
                            style: TextStyle(fontWeight: FontWeight.w700),
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
}
