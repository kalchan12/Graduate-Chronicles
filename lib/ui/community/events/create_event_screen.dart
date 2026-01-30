import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/supabase/supabase_service.dart';
import '../../../theme/design_system.dart';
import '../../widgets/global_background.dart';

/*
  CreateEventScreen
  
  Allows Graduates to post a new event.
  - Multi-Image Picker
  - Caption Input
  - Batch Selection (from Admin Approved list)
  - Category Selection
*/
class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _captionController = TextEditingController();

  // Data State
  List<File> _selectedImages = [];
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // Filter Options State
  Map<String, List<String>> _filterOptions = {};
  bool _isLoadingOptions = true;

  // Selected Values
  String? _selectedCategory;
  int? _selectedBatch;
  String? _selectedProgram;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-fill category if passed from previous screen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['category'] != null) {
      _selectedCategory = args['category'];
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    try {
      final options = await ref
          .read(supabaseServiceProvider)
          .fetchFilterOptions();
      if (mounted) {
        setState(() {
          _filterOptions = options;
          _isLoadingOptions = false;

          // Pre-select program logic could go here if we fetched user profile
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _postEvent() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one photo')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your Batch Year')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await ref
          .read(supabaseServiceProvider)
          .createCommunityEvent(
            mediaFiles: _selectedImages,
            mediaType: 'image',
            caption: _captionController.text.trim(),
            category: _selectedCategory!,
            batchYear: _selectedBatch!,
            program: _selectedProgram,
          );

      if (mounted) {
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post event: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dropdown items
    final batches =
        _filterOptions['batches']?.map((e) => int.parse(e)).toList() ?? [];
    final programs = _filterOptions['programs'] ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'New Event',
                      style: DesignSystem.theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (_isUploading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      TextButton(
                        onPressed:
                            (_selectedImages.isNotEmpty && !_isLoadingOptions)
                            ? _postEvent
                            : null,
                        child: Text(
                          'Post',
                          style: TextStyle(
                            color:
                                (_selectedImages.isNotEmpty &&
                                    !_isLoadingOptions)
                                ? DesignSystem.purpleAccent
                                : Colors.white24,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Picker / Preview Area
                      if (_selectedImages.isEmpty)
                        GestureDetector(
                          onTap: _pickImages,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Colors.white54,
                                    size: 48,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Select Photos",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _selectedImages.length) {
                                // Add more button
                                return GestureDetector(
                                  onTap: _pickImages,
                                  child: Container(
                                    width: 150,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white54,
                                    ),
                                  ),
                                );
                              }
                              return Stack(
                                children: [
                                  Container(
                                    width: 200,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: FileImage(
                                          _selectedImages[index],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Caption
                      TextField(
                        controller: _captionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Write a caption...",
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Metadata Selectors
                      if (_isLoadingOptions)
                        const Center(child: CircularProgressIndicator())
                      else
                        Column(
                          children: [
                            // Category Dropdown
                            _buildDropdown<String>(
                              label: "Category",
                              value: _selectedCategory,
                              items: ['100 Day', '50 Day', 'Other'],
                              onChanged: (val) =>
                                  setState(() => _selectedCategory = val),
                            ),
                            const SizedBox(height: 16),

                            // Batch Dropdown
                            _buildDropdown<int>(
                              label: "Batch Year",
                              value: _selectedBatch,
                              items: batches,
                              onChanged: (val) =>
                                  setState(() => _selectedBatch = val),
                            ),
                            const SizedBox(height: 16),

                            // Program Dropdown
                            _buildDropdown<String>(
                              label: "Program (Optional)",
                              value: _selectedProgram,
                              items: programs,
                              onChanged: (val) =>
                                  setState(() => _selectedProgram = val),
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),
                      const Text(
                        "Your School and Major will be automatically tagged from your profile.",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                        textAlign: TextAlign.center,
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: items.contains(value) ? value : null,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            item.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: const Color(0xFF2A1727),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
