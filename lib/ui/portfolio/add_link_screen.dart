import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

class AddLinkScreen extends StatefulWidget {
  const AddLinkScreen({super.key});

  @override
  State<AddLinkScreen> createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends State<AddLinkScreen> {
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add New Link',
          style: DesignSystem.theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabel('Link Title'),
                  _buildTextField(
                    controller: _titleCtrl,
                    hint: "e.g., Personal Website",
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('URL'),
                  _buildTextField(
                    controller: _urlCtrl,
                    hint: "https://",
                    isUrl: true,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Description (Optional)'),
                  _buildTextField(
                    controller: _descCtrl,
                    hint: 'Short description...',
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: DesignSystem.scaffoldBg,
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
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
                  shadowColor: DesignSystem.purpleAccent.withValues(alpha: 0.4),
                ),
                child: const Text(
                  'Save Link',
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
    bool isUrl = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      keyboardType: isUrl ? TextInputType.url : TextInputType.text,
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
        prefixIcon: isUrl
            ? const Icon(Icons.link, color: Colors.white38)
            : null,
      ),
    );
  }
}
