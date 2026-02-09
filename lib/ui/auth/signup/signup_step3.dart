import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/signup_state.dart';

/*
  Signup Step 3: Interests.
  
  Features:
  - Multi-select interest chips
  - Triggers Account Creation on Finish
  
  Refined UI: Matches Login Screen aesthetics.
*/
class SignupStep3 extends ConsumerStatefulWidget {
  const SignupStep3({super.key});

  @override
  ConsumerState<SignupStep3> createState() => _SignupStep3State();
}

class _SignupStep3State extends ConsumerState<SignupStep3> {
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

  final TextEditingController _customInterestController =
      TextEditingController();
  bool _isAddingCustom = false;

  @override
  void initState() {
    super.initState();
    final selected = ref.read(signupFormProvider).interests;
    for (final interest in selected) {
      if (!_allInterests.contains(interest)) {
        _allInterests.add(interest);
      }
    }
  }

  @override
  void dispose() {
    _customInterestController.dispose();
    super.dispose();
  }

  Future<void> _onFinish() async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Confirm',
      barrierColor: Colors.black.withValues(alpha: 0.8),
      pageBuilder: (context, a1, a2) => Container(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim,
            child: AlertDialog(
              backgroundColor: const Color(
                0xFF1A0A1F,
              ), // Matches new card color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              titlePadding: const EdgeInsets.only(top: 32, left: 24, right: 24),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DesignSystem.purpleAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: DesignSystem.purpleAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ready to Join?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your academic journey starts now. We will create your account and set up your profile.',
                    style: TextStyle(
                      color: Color(0xFFBDB1C9),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      ref.read(signupFormProvider.notifier).submitSignup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupFormProvider);
    final notifier = ref.read(signupFormProvider.notifier);

    final bgGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [DesignSystem.purpleDark, Color(0xFF240A28)],
    );

    return Scaffold(
      backgroundColor: DesignSystem.purpleDark,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white70,
                        ),
                        onPressed: () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/signup2'),
                      ),
                      const Expanded(
                        child: Text(
                          'Step 3 of 4',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'What are you into?',
                  style: DesignSystem.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select a few interests to personalize\nyour experience.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: DesignSystem.cardDecoration().copyWith(
                    borderRadius: BorderRadius.circular(28),
                    color: const Color(0xFF1A0A1F).withValues(alpha: 0.85),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildInterestsList(state, notifier)],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? () {} : _onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.purpleAccent,
                      elevation: 8,
                      shadowColor: DesignSystem.purpleAccent.withValues(
                        alpha: 0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Finish Signup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsList(SignupState state, SignupNotifier notifier) {
    final List<Widget> children = _allInterests.map((k) {
      final active = state.interests.contains(k);
      return GestureDetector(
        onTap: () => notifier.toggleInterest(k),
        child: _buildChip(k, active),
      );
    }).toList();

    children.add(
      GestureDetector(
        onTap: () {
          setState(() {
            _isAddingCustom = true;
          });
        },
        child: _isAddingCustom
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical:
                      6, // Added vertical padding to match chip height better
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DesignSystem.purpleAccent),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min, // Replaces IntrinsicWidth effect
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _customInterestController,
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add...',
                          hintStyle: TextStyle(color: Colors.white38),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            final interest = val.trim();
                            setState(() {
                              if (!_allInterests.contains(interest)) {
                                _allInterests.add(interest);
                              }
                              _isAddingCustom = false;
                              _customInterestController.clear();
                            });
                            if (!state.interests.contains(interest)) {
                              notifier.toggleInterest(interest);
                            }
                          } else {
                            setState(() => _isAddingCustom = false);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.check,
                        size: 16,
                        color: DesignSystem.purpleAccent,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        final val = _customInterestController.text.trim();
                        if (val.isNotEmpty) {
                          setState(() {
                            if (!_allInterests.contains(val)) {
                              _allInterests.add(val);
                            }
                            _isAddingCustom = false;
                            _customInterestController.clear();
                          });
                          if (!state.interests.contains(val)) {
                            notifier.toggleInterest(val);
                          }
                        } else {
                          setState(() => _isAddingCustom = false);
                        }
                      },
                    ),
                  ],
                ),
              )
            : _buildChip('Custom +', false, isCustom: true),
      ),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: children,
    );
  }

  Widget _buildChip(String label, bool active, {bool isCustom = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: active
            ? DesignSystem.purpleAccent
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? DesignSystem.purpleAccent
              : (isCustom
                    ? Colors.white38
                    : Colors.white.withValues(alpha: 0.1)),
          width: 1.5,
          style: isCustom && !active ? BorderStyle.solid : BorderStyle.solid,
          // Custom was dashed/solid in previous? Standardizing to solid for consistency.
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(Icons.check_circle, color: Colors.white, size: 16),
            ),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
