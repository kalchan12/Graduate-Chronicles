import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/design_system.dart';
import '../widgets/global_background.dart';
import '../widgets/toast_helper.dart';
import '../../state/portfolio_state.dart';
import '../../services/supabase/supabase_service.dart';

/*
  Add Certificate Screen.
  
  Form allows users to add a new professional certificate.
  - Uploads Certificate PDF/Image to 'portfolio_uploads'.
  - Saves record to 'portfolio_certificates' via PortfolioNotifier.
*/
class AddCertificateScreen extends ConsumerStatefulWidget {
  const AddCertificateScreen({super.key});

  @override
  ConsumerState<AddCertificateScreen> createState() =>
      _AddCertificateScreenState();
}

class _AddCertificateScreenState extends ConsumerState<AddCertificateScreen> {
  final _nameCtrl = TextEditingController();
  final _issuerCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _pickedFilePath;
  String? _pickedFileName;
  bool _isUploading = false;

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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFilePath = result.files.single.path;
        _pickedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ToastHelper.show(context, 'Please enter certificate name', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? fileUrl;
      if (_pickedFilePath != null) {
        final service = ref.read(supabaseServiceProvider);
        fileUrl = await service.uploadPortfolioFile(
          path: _pickedFilePath!,
          type: 'certificates',
        );
      }

      await ref.read(portfolioProvider.notifier).addItem('certificate', {
        'certificate_name': _nameCtrl.text.trim(),
        'issuing_organization': _issuerCtrl.text.trim(),
        'date_issued': _selectedDate.toIso8601String(),
        'certificate_url': fileUrl,
      });

      if (mounted) {
        Navigator.of(context).pop();
        ToastHelper.show(context, 'Certificate saved!');
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(context, 'Error: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                    onPressed: _isUploading ? null : _save,
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
                    child: _isUploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pickedFilePath != null
                ? DesignSystem.purpleAccent
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _pickedFilePath != null
                  ? Icons.check_circle
                  : Icons.workspace_premium_rounded,
              color: DesignSystem.purpleAccent.withValues(alpha: 0.5),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              _pickedFileName ?? 'Upload Certificate',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
