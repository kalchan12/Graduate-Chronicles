import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../theme/design_system.dart';
import '../../state/profile_state.dart';
import '../../ui/widgets/toast_helper.dart';

import '../../ui/widgets/global_background.dart';

/*
  Edit Profile Screen.
  
  Allows users to update their personal information.
  Features:
  - Profile image picker
  - Name, Username, Bio text fields
  - Validation (required fields)
  - Updates global profile state on save
*/
class EditProfileSettingsScreen extends ConsumerStatefulWidget {
  const EditProfileSettingsScreen({super.key});

  @override
  ConsumerState<EditProfileSettingsScreen> createState() =>
      _EditProfileSettingsScreenState();
}

class _EditProfileSettingsScreenState
    extends ConsumerState<EditProfileSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile.name);
    _usernameController = TextEditingController(text: profile.username);
    _bioController = TextEditingController(text: profile.bio);
    _pickedImagePath = profile.profileImage;

    // PART 5: Edit Profile MUST Refetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).refresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Watch for changes to update controllers when data comes in
    // This handles the async fetch completion
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      ToastHelper.show(
        context,
        'Name and username cannot be empty',
        isError: true,
      );
      return;
    }

    ref
        .read(profileProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          bio: _bioController.text.trim(),
          profileImage: _pickedImagePath,
        );

    Navigator.pop(context);
    _showSuccessToast();
  }

  void _showSuccessToast() {
    ToastHelper.show(context, 'Profile updated successfully');
  }

  @override
  Widget build(BuildContext context) {
    // Listen to profile updates to sync controllers (specifically for the initial fetch)
    ref.listen<UserProfile>(profileProvider, (previous, next) {
      if (previous != next) {
        // Only update if the values are different to avoid cursor jumping if user is typing
        // Ideally we only do this once on load, but checking for difference helps.
        // Since we refresh on mount, this brings in the DB values.
        if (_nameController.text != next.name) _nameController.text = next.name;
        if (_usernameController.text != next.username) {
          _usernameController.text = next.username;
        }
        if (_bioController.text != next.bio) _bioController.text = next.bio;
        if (_pickedImagePath != next.profileImage &&
            _pickedImagePath == previous?.profileImage) {
          // Only update image path if it wasn't validly changed by user picking a file
          // Actually, if we just loaded, we should overwrite.
          // Because _pickedImagePath is initialized to old state.
          // If user hasn't picked a new image (which would be local file), we accept the new network image.
          if (_pickedImagePath == null ||
              _pickedImagePath!.startsWith('http')) {
            setState(() {
              _pickedImagePath = next.profileImage;
            });
          }
        }
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Image Picker
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DesignSystem.purpleAccent,
                            width: 2,
                          ),
                          color: const Color(0xFF2B1F2E),
                        ),
                        child: ClipOval(
                          child: _pickedImagePath != null
                              ? (_pickedImagePath!.startsWith('http')
                                    ? Image.network(
                                        _pickedImagePath!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.white,
                                                ),
                                      )
                                    : Image.file(
                                        File(_pickedImagePath!),
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.white,
                                                ),
                                      ))
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: DesignSystem.purpleAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildLabel('Display Name'),
                _buildTextField(_nameController, 'Enter display name'),
                const SizedBox(height: 20),

                _buildLabel('Username'),
                _buildTextField(_usernameController, 'Enter username'),
                const SizedBox(height: 20),

                _buildLabel('Bio'),
                _buildTextField(
                  _bioController,
                  'Write a short bio...',
                  maxLines: 4,
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to Portfolio Management
                      // We will create this route next
                      Navigator.pushNamed(context, '/portfolio_management');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: DesignSystem.purpleAccent.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Manage Portfolio',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFBDB1C9),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A1727),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
