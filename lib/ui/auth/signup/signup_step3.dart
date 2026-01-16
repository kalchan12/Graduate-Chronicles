import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/signup_state.dart';

/*
  Signup Step 3: Profile Picture.
  
  Features:
  - Image selection from gallery
  - Permission handling (Photos/Storage)
  - Preview of selected image
  
  Allows skipping this step if the user prefers.
*/
class SignupStep3 extends ConsumerStatefulWidget {
  const SignupStep3({super.key});

  @override
  ConsumerState<SignupStep3> createState() => _SignupStep3State();
}

class _SignupStep3State extends ConsumerState<SignupStep3> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // Request permission first
    // Note: On Android 13+, READ_MEDIA_IMAGES is used, but library handles details mostly.
    // For simplicity, we check photos.
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    // Some Android versions (standard storage) or iOS behavior nuances:
    // If still denied, try 'storage' or just proceed to picker which might handle it or fail gracefully.
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
        maxWidth: 800, // Reasonable max width for avatars
        maxHeight: 800,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        ref.read(signupFormProvider.notifier).setAvatar(bytes);
      }
    } catch (e) {
      // Handle picker errors
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupFormProvider);

    return Scaffold(
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/signup2'),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48),
                        child: Center(
                          child: Text(
                            'Step 3 of 4',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
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
                        child: state.avatar == null
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
                                  state.avatar!,
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
                              state.avatar == null
                                  ? Icons.add_a_photo
                                  : Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.avatar == null
                                  ? 'Upload Photo'
                                  : 'Change Photo',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/signup4'),
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushReplacementNamed('/signup4'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
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
