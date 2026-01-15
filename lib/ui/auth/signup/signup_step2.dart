import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/signup_state.dart';

class SignupStep2 extends ConsumerStatefulWidget {
  const SignupStep2({super.key});

  @override
  ConsumerState<SignupStep2> createState() => _SignupStep2State();
}

class _SignupStep2State extends ConsumerState<SignupStep2> {
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  // Roles updated as per requirements: Student, Graduate, Alumni, Staff
  final List<String> _roles = ['Student', 'Graduate', 'Alumni', 'Staff'];
  final List<String> _years = List.generate(16, (i) => '${2020 + i}');

  @override
  void initState() {
    super.initState();
    final state = ref.read(signupFormProvider);
    _deptController.text = state.department ?? '';
    _userIdController.text = state.userId ?? '';
  }

  @override
  void dispose() {
    _deptController.dispose();
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
                          if (state.role == 'Student' ||
                              state.role == 'Graduate') ...[
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildField(
                                label: 'User ID',
                                hint: 'ID #',
                                icon: Icons.badge_outlined,
                                controller: _userIdController,
                                errorText: state.userIdError,
                                onChanged: (val) =>
                                    notifier.setField('userId', val),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildField(
                        label: 'Department / Major',
                        hint: 'e.g. Computer Science',
                        icon: Icons.school_outlined,
                        controller: _deptController,
                        errorText: state.departmentError,
                        onChanged: (val) =>
                            notifier.setField('department', val),
                      ),
                      const SizedBox(height: 16),

                      _buildYearPicker(
                        context,
                        label: 'Graduation Year',
                        hint: state.graduationYear ?? 'Select your year',
                        value: state.graduationYear,
                        onChanged: (val) =>
                            notifier.setField('graduationYear', val),
                        errorText: state.yearError,
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
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
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

  Widget _buildOverlayDropdown(
    BuildContext context, {
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onChanged,
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
                      value ?? hint,
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

  Widget _buildYearPicker(
    BuildContext context, {
    required String label,
    required String hint,
    required String? value,
    required ValueChanged<String> onChanged,
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
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF1F0C24),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              isScrollControlled: true,
              builder: (ctx) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.4,
                  maxChildSize: 0.8,
                  expand: false,
                  builder: (_, controller) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Select Graduation Year',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: GridView.builder(
                              controller: controller,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 2.0,
                                  ),
                              itemCount: _years.length,
                              itemBuilder: (context, index) {
                                final year = _years[index];
                                final isSelected = year == value;
                                return GestureDetector(
                                  onTap: () {
                                    onChanged(year);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? DesignSystem.purpleAccent
                                          : Colors.white.withValues(
                                              alpha: 0.05,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.white10,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      year,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white38,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value == null ? Colors.white38 : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.unfold_more_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
