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
  
  Refined UI: Matches Login Screen aesthetics.
*/
class SignupStep4 extends ConsumerStatefulWidget {
  const SignupStep4({super.key});

  @override
  ConsumerState<SignupStep4> createState() => _SignupStep4State();
}

class _SignupStep4State extends ConsumerState<SignupStep4> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
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

        final String ext = image.name.split('.').last.toLowerCase();
        final allowed = ['jpg', 'jpeg', 'png', 'webp', 'svg'];
        if (!allowed.contains(ext) && ext != 'heic') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unsupported file type.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

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

    final bgGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [DesignSystem.purpleDark, Color(0xFF240A28)],
    );

    return Scaffold(
      backgroundColor: DesignSystem.purpleDark,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Step 4 of 4',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Set up your profile',
                  style: DesignSystem.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add a photo to personalize your profile',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 12),
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
                    const SizedBox(height: 2),
                    Text(
                      '@${state.username}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: DesignSystem.cardDecoration().copyWith(
                    borderRadius: BorderRadius.circular(28),
                    color: const Color(0xFF1A0A1F).withValues(alpha: 0.85),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              DesignSystem.purpleAccent,
                              DesignSystem.purpleAccent.withValues(alpha: 0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1E1024),
                          ),
                          child: state.profileImage == null
                              ? Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Colors.white.withValues(alpha: 0.15),
                                    size: 60,
                                  ),
                                )
                              : ClipOval(
                                  child: Image.memory(
                                    state.profileImage!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(
                          state.profileImage == null
                              ? Icons.add_a_photo_rounded
                              : Icons.edit_rounded,
                          size: 16,
                          color: DesignSystem.purpleAccent,
                        ),
                        label: Text(
                          state.profileImage == null
                              ? 'Choose Photo'
                              : 'Change Photo',
                          style: const TextStyle(
                            color: DesignSystem.purpleAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'BIO (OPTIONAL)',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D1B36),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 0.5,
                          ),
                        ),
                        child: TextFormField(
                          initialValue: state.bio,
                          maxLength: 150,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tell us a bit about yourself...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.2),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                            counterStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 10,
                            ),
                          ),
                          onChanged: (val) {
                            ref.read(signupFormProvider.notifier).setBio(val);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
                                      ? 'Complete Setup'
                                      : 'Finish',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    ref.read(signupFormProvider.notifier).skipProfile(context);
                  },
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
