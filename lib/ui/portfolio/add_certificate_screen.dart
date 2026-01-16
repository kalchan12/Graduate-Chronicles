import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../widgets/global_background.dart';

/*
  Add Certificate Screen.

  Form allows users to add a new professional certificate.
  Inputs:
  - Certificate Name
  - Issuing Organization
  - Date Issued
  - File/Certificate upload area
*/
class AddCertificateScreen extends StatefulWidget {
  const AddCertificateScreen({super.key});

  @override
  State<AddCertificateScreen> createState() => _AddCertificateScreenState();
}

class _AddCertificateScreenState extends State<AddCertificateScreen> {
  final _nameCtrl = TextEditingController();
  final _issuerCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _issuerCtrl.dispose();
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
          'Add Certificate',
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
                      _buildLabel('Certificate Name'),
                      _buildTextField(
                        controller: _nameCtrl,
                        hint: "e.g., Google UX Design",
                      ),
                      const SizedBox(height: 24),

                      _buildLabel('Issuing Organization'),
                      _buildTextField(
                        controller: _issuerCtrl,
                        hint: "e.g., Coursera, Udemy",
                      ),

                      const SizedBox(height: 24),

                      _buildLabel('Date Issued'),
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
                      _buildLabel('Certificate File (Optional)'),
                      _buildUploadArea(),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.transparent, // Transparent for gradient
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
                      Navigator.of(context).pop();
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
                      'Save Certificate',
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: DesignSystem.purpleAccent.withValues(alpha: 0.5),
              size: 32,
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload Certificate',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
