import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/design_system.dart';
import '../../state/yearbook_state.dart';
import '../../state/profile_state.dart';
import '../../services/supabase/supabase_service.dart';
import '../widgets/toast_helper.dart';
import '../widgets/global_background.dart';

/*
  Yearbook Submission Screen.

  Allows graduate users to create or edit their yearbook entry.
  Features:
  - Photo upload with preview
  - Bio text input
  - Batch selection
  - Submit as pending for admin approval
*/
class YearbookSubmissionScreen extends ConsumerStatefulWidget {
  const YearbookSubmissionScreen({super.key});

  @override
  ConsumerState<YearbookSubmissionScreen> createState() =>
      _YearbookSubmissionScreenState();
}

class _YearbookSubmissionScreenState
    extends ConsumerState<YearbookSubmissionScreen> {
  final _bioController = TextEditingController();
  final _picker = ImagePicker();

  File? _selectedImage;
  String? _selectedBatchId;
  bool _isUploading = false;

  // Gallery
  final List<XFile> _newGalleryImages = [];
  List<String> _existingGalleryImages = [];

  @override
  void initState() {
    super.initState();
    // Load batches if not loaded
    Future.microtask(() {
      ref.read(yearbookProvider.notifier).loadBatches();
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  // When batch is selected, load existing entry
  void _onBatchSelected(String? batchId) {
    if (batchId == null) return;
    setState(() => _selectedBatchId = batchId);

    // Load existing entry
    ref.read(yearbookProvider.notifier).loadMyEntry(batchId).then((_) {
      _populateForm();
    });
  }

  void _populateForm() {
    final state = ref.read(yearbookProvider);
    final entry = state.myEntry;

    if (entry != null && _selectedBatchId == entry.batchId) {
      _bioController.text = entry.yearbookBio ?? '';
      _existingGalleryImages = List.from(entry.morePictures);
      _newGalleryImages.clear();
      // We don't set _selectedImage as it is a File, relying on NetworkImage preview if valid
    } else {
      _bioController.clear();
      _existingGalleryImages.clear();
      _newGalleryImages.clear();
      // _selectedImage = null; // Don't clear image if user just switched batches? Maybe yes.
    }
  }

  Future<void> _pickImage() async {
    // Prevent edit if approved/rejected logic check?
    // We will check in _submit, but UI disabling is better.
    final state = ref.read(yearbookProvider);
    if (state.myEntry != null && state.myEntry!.status != 'pending') {
      _showToast(
        'Cannot edit entry after it has been processed.',
        isError: true,
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showToast('Error picking image: $e', isError: true);
    }
  }

  Future<void> _pickGalleryImages() async {
    final state = ref.read(yearbookProvider);
    if (state.myEntry != null && state.myEntry!.status != 'pending') {
      _showToast(
        'Cannot edit entry after it has been processed.',
        isError: true,
      );
      return;
    }

    final currentCount =
        _existingGalleryImages.length + _newGalleryImages.length;
    if (currentCount >= 6) {
      _showToast('Maximum 6 additional photos allowed.', isError: true);
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final remainingSlots = 6 - currentCount;
        final imagesToAdd = images.take(remainingSlots).toList();

        setState(() {
          _newGalleryImages.addAll(imagesToAdd);
        });

        if (images.length > remainingSlots) {
          _showToast('Only ${imagesToAdd.length} photo(s) added. Limit is 6.');
        }
      }
    } catch (e) {
      _showToast('Error picking photos: $e', isError: true);
    }
  }

  Future<void> _submit() async {
    if (_selectedBatchId == null) {
      _showToast('Please select a batch', isError: true);
      return;
    }

    final state = ref.read(yearbookProvider);
    final existingEntry = state.myEntry;

    // Restriction
    if (existingEntry != null && existingEntry.status != 'pending') {
      _showToast(
        'Entry cannot be edited as it is ${existingEntry.status}',
        isError: true,
      );
      return;
    }

    if (_selectedImage == null && existingEntry == null) {
      // New entry requires photo
      _showToast('Please select a yearbook photo', isError: true);
      return;
    }

    final bio = _bioController.text.trim();
    setState(() => _isUploading = true);

    try {
      // Get batch year for upload path
      final selectedBatch = state.batches.firstWhere(
        (b) => b.id == _selectedBatchId,
      );

      final service = ref.read(supabaseServiceProvider);
      String? photoUrl;

      // Upload photo if new image selected
      if (_selectedImage != null) {
        photoUrl = await service.uploadYearbookPhoto(
          _selectedImage!,
          selectedBatch.batchYear,
        );
      } else {
        photoUrl = existingEntry?.yearbookPhotoUrl;
      }

      if (photoUrl == null) throw 'Photo URL missing';

      // Upload new gallery images
      final List<String> finalGalleryUrls = List.from(_existingGalleryImages);
      for (final xFile in _newGalleryImages) {
        final file = File(xFile.path);
        // Use specific method to ensure unique filename (timestamps)
        final url = await service.uploadYearbookGalleryImage(
          file,
          selectedBatch.batchYear,
        );
        finalGalleryUrls.add(url);
      }

      if (existingEntry == null) {
        // Create
        await ref
            .read(yearbookProvider.notifier)
            .createEntry(
              batchId: _selectedBatchId!,
              yearbookPhotoUrl: photoUrl,
              yearbookBio: bio.isNotEmpty ? bio : null,
              morePictures: finalGalleryUrls,
            );
      } else {
        // Update
        await ref
            .read(yearbookProvider.notifier)
            .updateEntry(
              entryId: existingEntry.id,
              batchId: _selectedBatchId!,
              yearbookPhotoUrl: _selectedImage != null
                  ? photoUrl
                  : null, // Only send if changed
              yearbookBio: bio,
              morePictures: finalGalleryUrls,
            );
      }

      if (mounted) {
        _showToast(
          existingEntry == null
              ? 'Yearbook entry submitted!'
              : 'Entry updated!',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showToast('Error submitting entry: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ToastHelper.show(context, message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final yearbookState = ref.watch(yearbookProvider);
    final profile = ref.watch(profileProvider);
    final existingEntry = yearbookState.myEntry;

    // Check if user is a graduate
    final isGraduate = profile.degree.isNotEmpty;

    // Auto-select first batch if none selected and batches exist
    if (_selectedBatchId == null && yearbookState.batches.isNotEmpty) {
      // Use scheduleMicrotask to update state after build
      Future.microtask(() {
        if (mounted && _selectedBatchId == null) {
          _onBatchSelected(yearbookState.batches.first.id);
        }
      });
    }

    final isReadOnly =
        existingEntry != null && existingEntry.status != 'pending';

    if (!isGraduate) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: GlobalBackground(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ... existing restricted UI ...
                  Icon(Icons.lock_outline, color: Colors.white24, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Yearbook submissions are for graduates only',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.purpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        existingEntry == null
                            ? 'Submit Yearbook Entry'
                            : 'Edit Yearbook Entry',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isReadOnly)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: existingEntry.status == 'approved'
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          existingEntry.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Batch Selection
                      const Text(
                        'Select Batch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: yearbookState.batches.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No batches available',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            : DropdownButton<String>(
                                value: _selectedBatchId,
                                isExpanded: true,
                                hint: const Text(
                                  'Choose your graduation year',
                                  style: TextStyle(color: Colors.white38),
                                ),
                                dropdownColor: DesignSystem.scaffoldBg,
                                underline: const SizedBox(),
                                style: const TextStyle(color: Colors.white),
                                items: yearbookState.batches.map((batch) {
                                  return DropdownMenuItem<String>(
                                    value: batch.id,
                                    child: Text('Class of ${batch.batchYear}'),
                                  );
                                }).toList(),
                                onChanged: _onBatchSelected, // Call our method
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Photo Upload
                      const Text(
                        'Yearbook Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: isReadOnly ? null : _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : (existingEntry?.yearbookPhotoUrl != null &&
                                      existingEntry!
                                          .yearbookPhotoUrl
                                          .isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(
                                      existingEntry.yearbookPhotoUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              (_selectedImage == null &&
                                  (existingEntry == null ||
                                      existingEntry.yearbookPhotoUrl.isEmpty))
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: Colors.white24,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tap to select photo',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bio
                      const Text(
                        'Yearbook Bio (Optional)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isReadOnly
                              ? Colors.black26
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: TextField(
                          controller: _bioController,
                          maxLines: 4,
                          maxLength: 200,
                          readOnly: isReadOnly,
                          style: TextStyle(
                            color: isReadOnly ? Colors.white70 : Colors.white,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Share a message or memory...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          cursorColor: DesignSystem.purpleAccent,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Gallery Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gallery (Optional)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_existingGalleryImages.length + _newGalleryImages.length}/6',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Existing Images
                          ..._existingGalleryImages.map((url) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(url),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _existingGalleryImages.remove(url);
                                      });
                                    },
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
                          }),

                          // New Images
                          ..._newGalleryImages.map((xFile) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(File(xFile.path)),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _newGalleryImages.remove(xFile);
                                      });
                                    },
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
                          }),

                          // Add Button
                          if ((_existingGalleryImages.length +
                                  _newGalleryImages.length) <
                              6)
                            GestureDetector(
                              onTap: isReadOnly ? null : _pickGalleryImages,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    style: BorderStyle.none,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    color: Colors.white54,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      if (!isReadOnly)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.purpleAccent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isUploading ? null : _submit,
                            child: _isUploading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    existingEntry == null
                                        ? 'Submit for Approval'
                                        : 'Update Entry',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Info message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isReadOnly
                              ? (existingEntry.status == 'approved'
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1))
                              : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isReadOnly
                                ? (existingEntry.status == 'approved'
                                      ? Colors.green
                                      : Colors.red)
                                : Colors.blueAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isReadOnly
                                  ? (existingEntry.status == 'approved'
                                        ? Icons.check_circle
                                        : Icons.error)
                                  : Icons.info_outline,
                              color: isReadOnly
                                  ? (existingEntry.status == 'approved'
                                        ? Colors.green
                                        : Colors.red)
                                  : Colors.blueAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isReadOnly
                                    ? (existingEntry.status == 'approved'
                                          ? 'Your entry has been approved and is visible in the yearbook.'
                                          : 'Your entry was rejected. Please contact support.')
                                    : 'Your entry will be reviewed by an admin before appearing in the yearbook.',
                                style: TextStyle(
                                  color: isReadOnly
                                      ? (existingEntry.status == 'approved'
                                            ? Colors.green.shade200
                                            : Colors.red.shade200)
                                      : Colors.blue.shade200,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
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
}
