import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/signup_state.dart';

/*
  Signup Step 4: Profile Picture (Post-Auth).
  
  Features:
  - Image selection from gallery
  - Upload to Supabase Storage
  - Validation (8MB, types)
*/
class SignupStep4 extends ConsumerStatefulWidget {
  const SignupStep4({super.key});

  @override
  ConsumerState<SignupStep4> createState() => _SignupStep4State();
}

class _SignupStep4State extends ConsumerState<SignupStep4> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // Permission check
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied. Please enable access in settings.'),
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        // Validate File Size (Max 8MB)
        final int sizeInBytes = await image.length();
        final double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > 8) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image is too large. Maximum size is 8MB.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        // Validate File Type
        final String ext = image.name.split('.').last.toLowerCase();
        final allowed = [
          'jpg',
          'jpeg',
          'png',
          'webp',
          'svg',
        ]; // Added webp, svg
        // SVG is tricky with ImagePicker, usually picks raster. But allowing extension check.
        if (!allowed.contains(ext)) {
          // Also allow if it's heic (converted automatically often)
          if (ext != 'heic') {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unsupported file type.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
        }

        // Compress/Convert to JPEG
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          image.path,
          minWidth: 800,
          minHeight: 800,
          quality: 85,
          format: CompressFormat.jpeg,
        );

        if (compressedBytes != null) {
          ref
              .read(signupFormProvider.notifier)
              .setProfileImage(compressedBytes);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _uploadAndFinish() {
    ref.read(signupFormProvider.notifier).uploadProfilePicture(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupFormProvider);

    return Scaffold(
      backgroundColor: DesignSystem.purpleDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E0F3B), DesignSystem.purpleDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Step 4 of 4',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Set up your profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Add a photo to personalize your profile',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ),

              // Shared User Info (Part 3 Requirement)
              Column(
                children: [
                  Text(
                    state.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${state.username}',
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // Avatar with gradient ring
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                DesignSystem.purpleAccent,
                                DesignSystem.purpleAccent.withValues(
                                  alpha: 0.5,
                                ),
                                Colors.pinkAccent.withValues(alpha: 0.3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: DesignSystem.purpleAccent.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E1024),
                            ),
                            child: state.profileImage == null
                                ? Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      size: 80,
                                    ),
                                  )
                                : ClipOval(
                                    child: Image.memory(
                                      state.profileImage!,
                                      fit: BoxFit.cover,
                                      width: 160,
                                      height: 160,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Upload/Change button
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(
                          state.profileImage == null
                              ? Icons.add_a_photo_rounded
                              : Icons.edit_rounded,
                          size: 18,
                          color: DesignSystem.purpleAccent,
                        ),
                        label: Text(
                          state.profileImage == null
                              ? 'Choose Photo'
                              : 'Change Photo',
                          style: const TextStyle(
                            color: DesignSystem.purpleAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Bio Input
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'BIO (OPTIONAL)',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: TextFormField(
                          initialValue: state.bio,
                          maxLength: 200,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tell us a bit about yourself...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(18),
                            counterStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          onChanged: (val) {
                            ref.read(signupFormProvider.notifier).setBio(val);
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Finish Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : (state.profileImage != null
                                    ? _uploadAndFinish
                                    : () => ref
                                          .read(signupFormProvider.notifier)
                                          .skipProfile(context)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            elevation: 0,
                            shadowColor: DesignSystem.purpleAccent.withValues(
                              alpha: 0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  state.profileImage != null
                                      ? 'Complete Setup'
                                      : 'Finish',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(signupFormProvider.notifier)
                              .skipProfile(context);
                        },
                        child: Text(
                          'Skip for now',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
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
