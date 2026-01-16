import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../widgets/global_background.dart';

/*
  Add Achievement Screen.

  Form allows users to add a new achievement to their portfolio.
  Inputs:
  - Title & Description
  - Date picker
  - Evidence/Photo upload area
*/
class AddAchievementScreen extends StatefulWidget {
  const AddAchievementScreen({super.key});

  @override
  State<AddAchievementScreen> createState() => _AddAchievementScreenState();
}

class _AddAchievementScreenState extends State<AddAchievementScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: DesignSystem.purpleAccent,
              onPrimary: Colors.white,
              surface: DesignSystem.purpleDark,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E1E2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Achievement',
          style: DesignSystem.theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLabel('Achievement Title'),
                      _buildTextField(
                        controller: _titleCtrl,
                        hint: "e.g., Dean's List - Fall 2024",
                      ),
                      const SizedBox(height: 24),

                      _buildLabel('Date Achieved'),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white54,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "${_selectedDate.toLocal()}".split(' ')[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildLabel('Description (Optional)'),
                      _buildTextField(
                        controller: _descCtrl,
                        hint: 'Describe what makes this achievement special...',
                        maxLines: 4,
                      ),

                      const SizedBox(height: 24),
                      _buildLabel('Evidence / Photo'),
                      _buildUploadArea(),
                    ],
                  ),
                ),
              ),

              // Bottom CTA
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save logic would go here
                      Navigator.of(context).pop();
                      // Ideally we don't push a new PortfolioHubScreen on top of the stack,
                      // we just pop back to it. But for now matching existing nav flow if needed,
                      // but popping is cleaner.
                      // The prompt said "Add / Edit Screens", usually these are modal or pushed.
                      // Previous code pushed Hub. I will stick to pop().
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      shadowColor: DesignSystem.purpleAccent.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    child: const Text(
                      'Save Achievement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: DesignSystem.purpleAccent,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          style: BorderStyle.solid,
        ), // User asked for no heavy borders, so solid thin is better than dash if dash looks "dashed border".
        // Or "No heavy borders or thick outlines". I'll use a dashed border effect cleanly or just thin solid.
        // Prompt said "No heavy borders".
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_rounded,
              color: DesignSystem.purpleAccent.withValues(alpha: 0.8),
              size: 32,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap to upload image',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
