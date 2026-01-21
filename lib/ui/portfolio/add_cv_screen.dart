import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_system.dart';
import '../widgets/global_background.dart';
import '../widgets/toast_helper.dart';
import '../../state/portfolio_state.dart';
import '../../services/supabase/supabase_service.dart';

/*
  Add CV/Resume Screen.
  
  Form to upload a PDF resume.
  - Uploads PDF to 'portfolio_uploads' bucket.
  - Saves record to 'portfolio_resumes' via PortfolioNotifier.
*/
class AddCvScreen extends ConsumerStatefulWidget {
  const AddCvScreen({super.key});

  @override
  ConsumerState<AddCvScreen> createState() => _AddCvScreenState();
}

class _AddCvScreenState extends ConsumerState<AddCvScreen> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _pickedFilePath;
  String? _pickedFileName;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
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
        // Auto-fill title if empty
        if (_nameCtrl.text.isEmpty) {
          _nameCtrl.text = _pickedFileName!;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_pickedFilePath == null) {
      ToastHelper.show(context, 'Please select a file', isError: true);
      return;
    }

    if (_nameCtrl.text.trim().isEmpty) {
      // default to filename if name is empty
      _nameCtrl.text = _pickedFileName ?? 'Resume';
    }

    setState(() => _isUploading = true);

    try {
      final service = ref.read(supabaseServiceProvider);
      final fileUrl = await service.uploadPortfolioFile(
        path: _pickedFilePath!,
        type: 'resumes',
      );

      await ref.read(portfolioProvider.notifier).addItem('resume', {
        'file_url': fileUrl,
        'file_name': _nameCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ToastHelper.show(context, 'Resume uploaded!');
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
          'Upload CV',
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
                      _buildUploadArea(),

                      const SizedBox(height: 32),

                      _buildLabel('File Name'),
                      _buildTextField(
                        controller: _nameCtrl,
                        hint: "e.g., My_Design_CV_2024.pdf",
                      ),

                      const SizedBox(height: 24),

                      _buildLabel('Notes (Optional)'),
                      _buildTextField(
                        controller: _notesCtrl,
                        hint: 'Brief description for this version...',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

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
                            'Save CV',
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _pickedFilePath != null
                ? DesignSystem.purpleAccent
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignSystem.purpleAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _pickedFilePath != null
                    ? Icons.description
                    : Icons.file_upload_outlined,
                color: DesignSystem.purpleAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _pickedFileName ?? 'Tap to upload PDF/Image',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Max file size: 8MB',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
