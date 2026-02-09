import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/signup_state.dart';

/*
  Signup Step 2: Academic Details.
  
  Captures:
  - Role
  - Student/User ID
  - Major/Department
  - Graduation Year
  
  Refined UI: Matches Login Screen aesthetics.
*/
class SignupStep2 extends ConsumerStatefulWidget {
  const SignupStep2({super.key});

  @override
  ConsumerState<SignupStep2> createState() => _SignupStep2State();
}

class _SignupStep2State extends ConsumerState<SignupStep2> {
  final TextEditingController _userIdController = TextEditingController();
  final List<String> _roles = ['Student', 'Graduate', 'Alumni', 'Staff'];

  static const List<String> _schools = ['SoEE', 'SoMCME', 'SoCEA', 'SoANS'];

  static const Map<String, List<String>> _majors = {
    'SoEE': [
      'Computer Science and Engineering',
      'Software Engineering',
      'Electrical and Computer Engineering',
      'Electrical Power and Control Engineering',
    ],
    'SoMCME': [
      'Mechanical Engineering',
      'Chemical Engineering',
      'Materials Science and Engineering',
    ],
    'SoCEA': [
      'Architecture',
      'Water Resources Engineering',
      'Civil Engineering',
    ],
    'SoANS': ['Physics', 'Chemistry', 'Biology', 'Geology'],
  };

  @override
  void initState() {
    super.initState();
    final state = ref.read(signupFormProvider);
    _userIdController.text = state.userId ?? '';
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  // Matches Login Screen Input Style
  InputDecoration _fieldDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.white38, size: 20)
          : null,
      hintStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: Colors.white24),
      filled: true,
      fillColor: const Color(0xFF2D1B36),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: DesignSystem.purpleAccent,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(
        color: Colors.orangeAccent,
        fontWeight: FontWeight.w500,
      ),
    );
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
                        ).pushReplacementNamed('/signup1'),
                      ),
                      const Expanded(
                        child: Text(
                          'Step 2 of 4',
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
                  'Academic Details',
                  style: DesignSystem.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: -0.5,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Role'),
                      const SizedBox(height: 4),
                      _buildOverlayDropdown(
                        context,
                        hint: state.role ?? 'Select Role',
                        value: state.role,
                        items: _roles,
                        onChanged: (val) => notifier.setRole(val),
                        errorText: state.roleError,
                      ),
                      const SizedBox(height: 10),
                      _buildLabel(switch (state.role) {
                        'Graduate' => 'Graduate ID',
                        'Staff' => 'Staff ID',
                        'Alumni' => 'Alumni ID',
                        _ => 'Student ID',
                      }),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _userIdController,
                        decoration: _fieldDecoration(
                          'Insert ID number',
                          Icons.badge_outlined,
                        ).copyWith(errorText: state.userIdError),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        onChanged: (val) => notifier.setField('userId', val),
                      ),
                      const SizedBox(height: 4), // Tiny gap for helper text
                      const Text(
                        'Accepted: UGR, UGE, UGW, PGE, ASTU/Ac-',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      _buildLabel('School'),
                      const SizedBox(height: 4),
                      _buildOverlayDropdown(
                        context,
                        hint: state.school ?? 'Select School',
                        value: state.school,
                        items: _schools,
                        onChanged: (val) {
                          notifier.setField('school', val);
                          notifier.setField('major', '');
                        },
                        errorText: state.schoolError,
                      ),
                      const SizedBox(height: 10),
                      _buildMajorsAutocomplete(context, state, notifier),
                      const SizedBox(height: 10),
                      _buildLabel('Graduation Year'),
                      const SizedBox(height: 4),
                      TextFormField(
                        initialValue: state.graduationYear,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _fieldDecoration(
                          'YYYY (e.g. 2026)',
                          Icons.calendar_today_outlined,
                        ).copyWith(errorText: state.yearError, counterText: ""),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        onChanged: (val) =>
                            notifier.setField('graduationYear', val),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (notifier.validateStep2()) {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/signup3');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            elevation: 4,
                            shadowColor: DesignSystem.purpleAccent.withValues(
                              alpha: 0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Next Step',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildMajorsAutocomplete(
    BuildContext context,
    SignupState state,
    SignupNotifier notifier,
  ) {
    final List<String> majorSuggestions = state.school != null
        ? (_majors[state.school] ?? [])
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Department / Major'),
        const SizedBox(height: 8),
        if (state.school == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Please select a school first',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: state.major ?? ''),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return majorSuggestions.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (String selection) {
            notifier.setField('major', selection);
          },
          fieldViewBuilder:
              (
                BuildContext context,
                TextEditingController fieldTextEditingController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: _fieldDecoration(
                    'Search Major',
                    Icons.school_outlined,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            final double width = MediaQuery.of(context).size.width - 48;
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E1A3C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, i) => Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverlayDropdown(
    BuildContext context, {
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF2E1A3C),
          elevation: 12,
          textStyle: const TextStyle(color: Colors.white),
        ),
      ),
      child: PopupMenuButton<String>(
        onSelected: onChanged,
        offset: const Offset(0, 60),
        constraints: const BoxConstraints(minWidth: 200),
        itemBuilder: (context) {
          return items.map((String item) {
            final isSelected = item == value;
            return PopupMenuItem<String>(
              value: item,
              height: 48,
              child: Container(
                decoration: isSelected
                    ? BoxDecoration(
                        color: DesignSystem.purpleAccent.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: DesignSystem.purpleAccent,
                      ),
                  ],
                ),
              ),
            );
          }).toList();
        },
        child: InputDecorator(
          decoration: _fieldDecoration('', null).copyWith(
            hintText: hint,
            errorText: errorText,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white38,
            ),
          ),
          child: Text(
            value ?? hint,
            style: TextStyle(
              color: value != null ? Colors.white : Colors.white24,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
