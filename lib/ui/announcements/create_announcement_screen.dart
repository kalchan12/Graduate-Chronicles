import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import '../../theme/design_system.dart';
import '../../state/profile_state.dart';
import '../../services/supabase/supabase_service.dart';

/// Create Announcement Screen
///
/// Separate flow from post creation.
/// - Header image picker (optional)
/// - Read-only author identity block
/// - Formal content field
/// - Submits with content_kind='announcement' and interaction_mode='broadcast'
class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final _contentController = TextEditingController();
  String? _headerImagePath;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickHeaderImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _headerImagePath = picked.path);
    }
  }

  void _showGlassToast(String message, {bool isError = false}) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isError
                      ? Colors.red.withValues(alpha: 0.2)
                      : DesignSystem.purpleAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isError
                        ? Colors.red.withValues(alpha: 0.3)
                        : DesignSystem.purpleAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.check_circle,
                      color: isError ? Colors.red : DesignSystem.purpleAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  Future<void> _handlePublish() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      debugPrint('[ANNOUNCEMENT_CREATE] Validation failed: Empty content');
      _showGlassToast('Please enter announcement content', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    debugPrint('[ANNOUNCEMENT_CREATE] Starting publish flow...');

    try {
      final service = ref.read(supabaseServiceProvider);
      final userId = await service.getCurrentUserId();

      if (userId == null) {
        debugPrint('[ANNOUNCEMENT_CREATE] Error: User not authenticated');
        _showGlassToast('Not authenticated', isError: true);
        return;
      }

      // Upload header image if selected
      List<String> mediaUrls = [];
      if (_headerImagePath != null) {
        debugPrint('[ANNOUNCEMENT_CREATE] Uploading header image...');
        try {
          final url = await service.uploadPostMedia(_headerImagePath!);
          mediaUrls.add(url);
          debugPrint('[ANNOUNCEMENT_CREATE] Header image uploaded: $url');
        } catch (e) {
          debugPrint('[ANNOUNCEMENT_CREATE] Header upload failed: $e');
          // Decide if we want to abort or continue without image.
          // For now, abort to be safe.
          throw Exception('Failed to upload header image: $e');
        }
      }

      // Insert announcement
      debugPrint('[ANNOUNCEMENT_CREATE] Calling service.createAnnouncement...');
      await service.createAnnouncement(
        userId: userId,
        description: content,
        mediaUrls: mediaUrls,
      );

      debugPrint('[ANNOUNCEMENT_CREATE] Publish flow completed successfully');
      _showGlassToast('Announcement published!');

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      debugPrint('[ANNOUNCEMENT_CREATE] Fatal Error: $e');
      _showGlassToast('Failed to publish: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final role = profile.role.toLowerCase();

    // Role Verification Safeguard
    // Only Staff and Alumni (Graduate) can access this screen.
    if (role != 'staff' && role != 'alumni' && role != 'graduate') {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1225),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Access Restricted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Only Staff and Alumni can post announcements.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1225),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Announcement',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildPublishButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Picker
            GestureDetector(
              onTap: _pickHeaderImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1225),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
                  ),
                  image: _headerImagePath != null
                      ? DecorationImage(
                          image: FileImage(File(_headerImagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _headerImagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: DesignSystem.purpleAccent.withValues(
                              alpha: 0.6,
                            ),
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Header Image (Optional)',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 24),

            // Author Identity Block (Read-Only)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1F3D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DesignSystem.purpleAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignSystem.purpleAccent,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: profile.profileImage != null
                          ? Image.network(
                              profile.profileImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                  ),
                            )
                          : const Icon(Icons.person, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name.isNotEmpty ? profile.name : 'Your Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.role.isNotEmpty
                              ? '${profile.role} • ${profile.degree}'
                              : profile.degree,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content Field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1225),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: DesignSystem.purpleAccent.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 8,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your announcement...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Guidance text
            Text(
              'Announcements are broadcast-only and do not accept comments or likes.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    final hasContent = _contentController.text.trim().isNotEmpty;

    return GestureDetector(
      onTap: _isLoading ? null : _handlePublish,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: hasContent
              ? const LinearGradient(
                  colors: [Color(0xFFE94CFF), Color(0xFF8B5CF6)],
                )
              : null,
          color: hasContent ? null : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Publish',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
