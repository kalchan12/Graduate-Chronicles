import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../theme/design_system.dart';
import '../widgets/global_background.dart';
import '../widgets/toast_helper.dart';
import '../../state/portfolio_state.dart';
import '../../services/supabase/supabase_service.dart';

/*
  Add Achievement Screen.
  
  Allows users to add a new achievement to their portfolio.
  - Uploads evidence image/PDF to 'portfolio_uploads' bucket.
  - Saves record to 'portfolio_achievements' via PortfolioNotifier.
*/
class AddAchievementScreen extends ConsumerStatefulWidget {
  const AddAchievementScreen({super.key});

  @override
  ConsumerState<AddAchievementScreen> createState() =>
      _AddAchievementScreenState();
}

class _AddAchievementScreenState extends ConsumerState<AddAchievementScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _pickedFilePath;
  String? _pickedFileName;
  bool _isUploading = false;

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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFilePath = result.files.single.path;
        _pickedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ToastHelper.show(context, 'Please enter a title', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? evidenceUrl;
      if (_pickedFilePath != null) {
        final service = ref.read(supabaseServiceProvider);
        evidenceUrl = await service.uploadPortfolioFile(
          path: _pickedFilePath!,
          type: 'achievements',
        );
      }

      await ref.read(portfolioProvider.notifier).addItem('achievement', {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'date_achieved': _selectedDate.toIso8601String(),
        'evidence_url': evidenceUrl,
      });

      if (mounted) {
        Navigator.of(context).pop();
        ToastHelper.show(context, 'Achievement saved!');
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(context, 'Error saving: $e', isError: true);
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
    bool isPdf =
        _pickedFilePath != null &&
        _pickedFilePath!.toLowerCase().endsWith('.pdf');

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _pickedFilePath != null
              ? DesignSystem.purpleAccent
              : Colors.white.withValues(alpha: 0.1),
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: _pickFile,
        borderRadius: BorderRadius.circular(16),
        child: _pickedFilePath != null
            ? (isPdf
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.redAccent,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _pickedFileName ?? 'PDF File',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_pickedFilePath!),
                        fit: BoxFit.cover,
                      ),
                    ))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_rounded,
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.8),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap to upload image or PDF',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
      ),
    );
  }
}
