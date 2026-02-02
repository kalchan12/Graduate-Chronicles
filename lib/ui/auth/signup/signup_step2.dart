import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/signup_state.dart';

/*
  Signup Step 2: Academic Details.
  
  Captures:
  - Role (Student, Graduate, etc.)
  - Student/User ID
  - Major/Department (with Autocomplete)
  - Graduation Year
  
  Adapts UI based on selected Role.
*/
class SignupStep2 extends ConsumerStatefulWidget {
  const SignupStep2({super.key});

  @override
  ConsumerState<SignupStep2> createState() => _SignupStep2State();
}

class _SignupStep2State extends ConsumerState<SignupStep2> {
  final TextEditingController _userIdController = TextEditingController();
  // Roles updated as per requirements: Student, Graduate, Alumni, Staff
  final List<String> _roles = ['Student', 'Graduate', 'Alumni', 'Staff'];

  // Schools - Display as abbreviations only, save abbreviation to DB
  static const List<String> _schools = ['SoEE', 'SoMCME', 'SoCEA', 'SoANS'];

  // Majors - FULL NAMES, filtered by selected school, save full name to DB
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

  // Placeholder list removed. We use dynamic data from majorsProvider.

  @override
  void initState() {
    super.initState();
    final state = ref.read(signupFormProvider);
    _userIdController.text = state.userId ?? '';
    // We handle the 'Other' logic in the build or as part of the dynamic fetch
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupFormProvider);
    final notifier = ref.read(signupFormProvider.notifier);

    return Scaffold(
      backgroundColor: DesignSystem.purpleDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E0F3B), DesignSystem.purpleDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/signup1'),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Step 2 of 4',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Academic Details',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  "Let's find your campus community.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildOverlayDropdown(
                              context,
                              label: 'Role',
                              hint: state.role ?? 'Select',
                              value: state.role,
                              items: _roles,
                              onChanged: (val) {
                                notifier.setRole(val);
                                // Clear user ID if role doesn't require it, optional UX choice
                                // but for now we keep it simple.
                              },
                              errorText: state.roleError,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ID Field (Strict Validation visual feedback handled by state error)
                      _buildField(
                        label: switch (state.role) {
                          'Graduate' => 'Graduate ID', // Explicit requirement
                          'Staff' => 'Staff ID',
                          'Alumni' => 'Alumni ID',
                          _ => 'Student ID',
                        },
                        hint: 'Insert ID number',
                        icon: Icons.badge_outlined,
                        controller: _userIdController,
                        errorText: state.userIdError,
                        onChanged: (val) => notifier.setField('userId', val),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Accepted: UGR (Regular), UGE (Extension), UGW (Weekend), PGE (Masters), ASTU/Ac- (Staff)',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // School Dropdown - Abbreviations only
                      _buildOverlayDropdown(
                        context,
                        label: 'School',
                        hint: state.school ?? 'Select School',
                        value: state.school,
                        items: _schools,
                        onChanged: (val) {
                          notifier.setField('school', val);
                          notifier.setField(
                            'major',
                            '',
                          ); // Reset major when school changes
                        },
                        errorText: state.schoolError,
                      ),
                      const SizedBox(height: 16),

                      _buildMajorsAutocomplete(context, state, notifier),
                      const SizedBox(height: 16),

                      const SizedBox(height: 16),

                      _buildField(
                        label: 'Graduation / Graduated Year',
                        hint: 'YYYY (e.g. 2024)',
                        icon: Icons.calendar_today_outlined,
                        errorText: state.yearError,
                        inputType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        // Updated logic to allow past years for Alumni support
                        onChanged: (val) =>
                            notifier.setField('graduationYear', val),
                        initialValue: state.graduationYear,
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
    TextInputType? inputType,
    int? maxLength,
    String? initialValue,
    List<TextInputFormatter>? inputFormatters,
  }) {
    // If controller is null, we can use initialValue.
    // Ideally we shouldn't mix controller and initialValue.
    // If no controller provided, we can't use TextEditingController.
    // But TextField needs one for `controller` OR `initialValue` (not both).
    // So we update the logic.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white38, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  initialValue: controller == null ? initialValue : null,
                  onChanged: onChanged,
                  keyboardType: inputType,
                  maxLength: maxLength,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    counterText: "", // Hide counter
                    hintStyle: const TextStyle(color: Colors.white38),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMajorsAutocomplete(
    BuildContext context,
    SignupState state,
    SignupNotifier notifier,
  ) {
    // Dependent Majors
    final List<String> majorSuggestions = state.school != null
        ? (_majors[state.school] ?? [])
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Department / Major',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        // Warning if school not selected
        if (state.school == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Please select a school first',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Autocomplete<String>(
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
                // Directly store the selected major name
                notifier.setField('major', selection);
              },
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            color: Colors.white38,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: fieldTextEditingController,
                              focusNode: fieldFocusNode,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search Major',
                                hintStyle: TextStyle(color: Colors.white38),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: constraints.maxWidth,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E1A3C),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverlayDropdown(
    BuildContext context, {
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    String? Function(String)? itemLabelBuilder,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Theme(
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
                          itemLabelBuilder != null
                              ? itemLabelBuilder(item)!
                              : item,
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: errorText != null
                    ? Border.all(color: Colors.orangeAccent)
                    : Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      (value != null && itemLabelBuilder != null)
                          ? itemLabelBuilder(value)!
                          : (value ?? hint),
                      style: TextStyle(
                        color: value != null ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
