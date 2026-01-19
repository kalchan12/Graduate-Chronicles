import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/*
  Supabase Service.
  
  Handles all interactions with the Supabase backend including:
  - Authentication (Sign Up, Sign In)
  - Database Operations (Inserting user profiles)
  - Storage (Image uploads)
  - Image Compression (Optimizing assets before upload)
*/

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(Supabase.instance.client);
});

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  /*
    Compresses and converts image to JPEG.
    Handles HEIC/HEIF and large file sizes.
  */
  Future<Uint8List> _compressImage(Uint8List bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 1024,
        minWidth: 1024,
        quality: 85,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      print('Compression error: $e');
      return bytes; // Fallback to original if compression fails
    }
  }

  /*
    Uploads a profile picture file to Supabase Storage.
    Returns the public URL of the uploaded file.
    
    Validation:
    - Max size: 8MB
    - Bucket: 'avatar'
    - Format: JPEG (converted)
  */
  Future<String?> uploadProfilePicture(
    String userId,
    Uint8List fileBytes,
  ) async {
    // 1. Size Validation (8MB = 8 * 1024 * 1024 bytes)
    if (fileBytes.lengthInBytes > 8 * 1024 * 1024) {
      throw Exception('Image size exceeds 8MB');
    }

    try {
      // 2. Compress & Convert to JPEG
      // This handles format standardization (jpg, jpeg, png, heic -> jpeg)
      final compressedBytes = await _compressImage(fileBytes);

      // 3. Generate path (force .jpeg extension)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$userId/profile_$timestamp.jpeg';

      // DEBUG: Log upload details
      print('🔍 DEBUG - Uploading to bucket: "avatar"');
      print('🔍 DEBUG - Path: $path');

      // 4. Upload to 'avatar' bucket
      await _client.storage
          .from('avatar')
          .uploadBinary(
            path,
            compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // 5. Return public URL
      return _client.storage.from('avatar').getPublicUrl(path);
    } catch (e) {
      print('Profile upload error: $e');
      if (e.toString().contains('400') || e.toString().contains('404')) {
        // Helper for bucket issues
        throw Exception(
          'Storage bucket "avatar" not found or permissions invalid. details: $e',
        );
      }
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /*
    Sign Up User.
    
    Creates a new user in Supabase Auth and then creates a corresponding
    record in the public 'users' table using the STRICT final schema.
  */
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String role,
    required String? institutionalId,
    required String? major,
    required int? graduationYear,
    required List<String> interests,
  }) async {
    // 1. Auth Signup
    final AuthResponse res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username, 'full_name': fullName},
    );

    final userId = res.user?.id;
    if (userId == null) throw Exception('Signup failed: user ID is null');

    // 2. Database Sync (Public Users Table)
    // Note: profile_picture_url is REMOVED from users table.
    try {
      await _client.from('users').insert({
        'auth_user_id': userId,
        'username': username,
        'full_name': fullName,
        'email': email,
        'role': role,
        'institutional_id': institutionalId,
        'major': major,
        'graduation_year': graduationYear,
        'interests': interests,
      });
    } catch (e) {
      print('DB Sync error: $e');
      throw Exception('Profile creation failed: $e');
    }
  }

  /*
    SignIn with Institutional ID.
  */
  Future<AuthResponse> signInWithInstitutionalId(
    String institutionalId,
    String password,
  ) async {
    final data = await _client
        .from('users')
        .select('email')
        .eq('institutional_id', institutionalId)
        .maybeSingle();

    if (data == null || data['email'] == null) {
      throw Exception('User ID not found.');
    }

    return await _client.auth.signInWithPassword(
      email: data['email'],
      password: password,
    );
  }

  /*
    Validation checks.
  */
  Future<bool> isUsernameTaken(String username) async {
    final data = await _client
        .from('users')
        .select('username')
        .eq('username', username)
        .maybeSingle();
    return data != null;
  }
}
