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

  void _skip() {
    Navigator.of(context).pushNamedAndRemoveUntil('/app', (r) => false);
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
                    // No Back Button involved as we are already authenticated.
                    // We can show a 'Skip' button on the left or just keep it clean.
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
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Set up your profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  'Add a photo so your friends can find you.',
                  style: TextStyle(color: Color(0xFFBEB2DF), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
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
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80),
                          border: Border.all(color: Colors.white24, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: state.profileImage == null
                            ? const Center(
                                child: Icon(
                                  Icons.account_circle,
                                  color: Colors.white12,
                                  size: 120,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(80),
                                child: Image.memory(
                                  state.profileImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.white24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.profileImage == null
                                  ? Icons.add_a_photo
                                  : Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.profileImage == null
                                  ? 'Upload Photo'
                                  : 'Change Photo',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _skip,
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Finish Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: state.profileImage != null
                              ? (state.isSubmitting ? null : _uploadAndFinish)
                              : _skip, // If no image, 'Next' behaves like Skip
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  state.profileImage != null
                                      ? 'Upload & Finish'
                                      : 'Finish',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
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
