import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import '../../../../theme/design_system.dart';
import '../../../../state/posts_state.dart';
import '../../../../state/post_recommendation_state.dart';
import '../../../core/providers/current_user_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref.read(createPostProvider.notifier).addMedia(image.path);
    }
  }

  /// Custom glassmorphism toast with dark purple theme
  void _showGlassToast(String message, {bool isError = false}) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
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
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E1A36).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isError
                        ? Colors.redAccent.withOpacity(0.4)
                        : DesignSystem.purpleAccent.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isError
                                  ? Colors.redAccent
                                  : DesignSystem.purpleAccent)
                              .withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (isError
                                    ? Colors.redAccent
                                    : DesignSystem.purpleAccent)
                                .withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isError ? Icons.error_outline : Icons.check_circle,
                        color: isError
                            ? Colors.redAccent
                            : DesignSystem.purpleAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
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
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Future<void> _handlePost() async {
    final notifier = ref.read(createPostProvider.notifier);
    final success = await notifier.publishPost(_captionController.text);

    if (!mounted) return;

    if (success) {
      // Refresh the personalized feed (used by Home Screen)
      ref.invalidate(personalizedFeedProvider);
      // Also refresh the standard feed for other screens
      ref.invalidate(feedProvider);

      _showGlassToast('Post shared successfully!');
      Navigator.pop(context);
    } else {
      final errorMsg =
          ref.read(createPostProvider).error ?? 'Something went wrong';
      _showGlassToast(errorMsg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final state = ref.watch(createPostProvider);
    final hasContent =
        _captionController.text.isNotEmpty || state.selectedMedia.isNotEmpty;

    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                  const Text(
                    'New Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildPostButton(state, hasContent),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // --- Content ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: currentUser?.profileImage != null
                              ? NetworkImage(currentUser!.profileImage!)
                              : null,
                          child: currentUser?.profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white54,
                                  size: 22,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currentUser?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Caption input
                    TextField(
                      controller: _captionController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.5,
                      ),
                      maxLines: null,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 24),

                    // Media preview
                    if (state.selectedMedia.isNotEmpty) ...[
                      _buildMediaPreview(state.selectedMedia),
                      const SizedBox(height: 24),
                    ],

                    // Add media button
                    _buildAddMediaButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostButton(CreatePostState state, bool hasContent) {
    final isEnabled = !state.isLoading && hasContent;

    return GestureDetector(
      onTap: isEnabled ? _handlePost : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? DesignSystem.purpleAccent : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: state.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Share',
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.white30,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildMediaPreview(List<String> media) {
    if (media.length == 1) {
      return _buildSingleImage(media[0]);
    }
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => _buildMediaThumbnail(media[index]),
      ),
    );
  }

  Widget _buildSingleImage(String path) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(path),
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(top: 8, right: 8, child: _buildRemoveButton(path)),
      ],
    );
  }

  Widget _buildMediaThumbnail(String path) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(path),
            width: 140,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(top: 6, right: 6, child: _buildRemoveButton(path)),
      ],
    );
  }

  Widget _buildRemoveButton(String path) {
    return GestureDetector(
      onTap: () => ref.read(createPostProvider.notifier).removeMedia(path),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildAddMediaButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: DesignSystem.purpleAccent,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Add Photo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
