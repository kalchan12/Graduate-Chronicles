import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/auth_provider.dart';

class SignupStep2 extends ConsumerStatefulWidget {
  const SignupStep2({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupStep2> createState() => _SignupStep2State();
}

class _SignupStep2State extends ConsumerState<SignupStep2> {
  String? _selectedRole;
  String? _selectedYear;
  final TextEditingController _deptController = TextEditingController();

  final List<String> _roles = ['Graduate student', 'admin', 'staff', 'alumni'];
  final List<String> _years = List.generate(16, (i) => '${2020 + i}');

  @override
  void initState() {
    super.initState();
    final draft = ref.read(authProvider).draft;
    _selectedRole = draft.role;
    _selectedYear = draft.graduationYear;
    _deptController.text = draft.department ?? '';
  }

  @override
  void dispose() {
    _deptController.dispose();
    super.dispose();
  }

  Future<void> _pickOption(BuildContext context, List<String> options, ValueChanged<String> onSelected) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (c, i) => ListTile(title: Text(options[i]), onTap: () => Navigator.of(c).pop(options[i])),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: options.length,
        ),
      ),
    );
    if (result != null) onSelected(result);
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
              const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Step 2 of 4', style: TextStyle(color: Colors.white70))),
              const SizedBox(height: 8),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 28), child: Text('Academic Details', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800), textAlign: TextAlign.center)),
              const SizedBox(height: 12),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 36), child: Text("Let's find your campus community.", style: TextStyle(color: Color(0xFFBEB2DF), fontSize: 14), textAlign: TextAlign.center)),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      _buildDropdown(context, label: 'I am a...', hint: _selectedRole ?? 'Select your role', onTap: () => _pickOption(context, _roles, (r) => setState(() => _selectedRole = r))),
                      const SizedBox(height: 12),
                      _buildField(label: 'Department / Major', hint: 'e.g. Computer Science', icon: Icons.book, controller: _deptController),
                      const SizedBox(height: 12),
                      _buildDropdown(context, label: 'Graduation Year', hint: _selectedYear ?? 'Select your year', onTap: () => _pickOption(context, _years, (y) => setState(() => _selectedYear = y))),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            // persist draft
                            ref.read(authProvider.notifier).updateDraft(role: _selectedRole, department: _deptController.text.trim(), graduationYear: _selectedYear);
                            Navigator.of(context).pushReplacementNamed('/signup3');
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Next', style: TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _buildField({required String label, required String hint, required IconData icon, TextEditingController? controller}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFFD6C9E6))),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [Icon(icon, color: Colors.white54), const SizedBox(width: 10), Expanded(child: TextField(controller: controller, decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: Colors.white38))))]),
      )
    ]);
  }

  Widget _buildDropdown(BuildContext context, {required String label, required String hint, required VoidCallback onTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFFD6C9E6))),
      const SizedBox(height: 6),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(children: [const Icon(Icons.arrow_drop_down, color: Colors.white54), const SizedBox(width: 8), Expanded(child: Text(hint, style: const TextStyle(color: Colors.white38))), const Icon(Icons.keyboard_arrow_down, color: Colors.white38)]),
        ),
      )
    ]);
  }
}
