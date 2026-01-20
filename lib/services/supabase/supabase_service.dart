import 'dart:io';
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

  User? get currentUser => _client.auth.currentUser;

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

      // 5. Return Storage Path (NOT URL)
      return path;
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

  // --- Profile System Methods ---

  /*
    Upsert Profile (Insert or Update).
    Used during setup or editing.
  */
  Future<void> upsertProfile({
    required String userId,
    String? bio,
    String? profilePictureUrl,
  }) async {
    // We strictly use the user_id to map to profile.
    // Ideally we fetch the internal user_id first if we only have auth_user_id,
    // but typically we pass the PUBLIC user_id here.

    // Check if profile exists
    final existing = await _client
        .from('profile')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      // Insert
      await _client.from('profile').insert({
        'user_id': userId,
        'bio': bio,
        'profile_picture': profilePictureUrl,
      });
    } else {
      // Update - Only updated non-null fields
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (bio != null) updates['bio'] = bio;
      if (profilePictureUrl != null) {
        updates['profile_picture'] = profilePictureUrl;
      }

      await _client.from('profile').update(updates).eq('user_id', userId);
    }
  }

  /*
    Get Full Profile (User + Profile).
    Returns a Map with joined data.
  */
  Future<Map<String, dynamic>?> getFullProfile(String userId) async {
    // Fetch users table data
    final userRes = await _client
        .from('users')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (userRes == null) return null;

    // Fetch profile table data
    final profileRes = await _client
        .from('profile')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    // Merge logic
    final Map<String, dynamic> data = Map.from(userRes);
    if (profileRes != null) {
      data['bio'] = profileRes['bio'];

      // Convert Storage Path -> Public URL
      final path = profileRes['profile_picture'];
      if (path != null && path.toString().isNotEmpty) {
        data['profile_picture'] = _client.storage
            .from('avatar')
            .getPublicUrl(path);
      } else {
        data['profile_picture'] = null;
      }
    }

    return data;
  }

  /*
    Update Profile Settings (Split update).
    Updates 'users' table (Identity) AND 'profile' table (Rich content).
  */
  Future<void> updateProfileSettings({
    required String userId,
    String? fullName,
    String? username,
    String? bio,
    String? profileImage,
  }) async {
    // 1. Update Users Table (Identity)
    if (fullName != null || username != null) {
      final Map<String, dynamic> userUpdates = {};
      if (fullName != null) userUpdates['full_name'] = fullName;
      if (username != null) userUpdates['username'] = username;
      // Add other allowed user fields here (e.g. major)

      await _client.from('users').update(userUpdates).eq('user_id', userId);
    }

    // 2. Update Profile Table (Content)
    if (bio != null || profileImage != null) {
      // Use upsert logic to ensure row exists
      await upsertProfile(
        userId: userId,
        bio: bio,
        profilePictureUrl: profileImage,
      );
    }
  }

  // Get current public user ID based on Auth ID (Session)
  Future<String?> getCurrentUserId() async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) return null;

    final res = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', authId)
        .maybeSingle();

    return res?['user_id'];
  }

  // --- Portfolio System Methods ---

  /*
    Get Auth ID from Public User ID.
    Required because Portfolio tables use Auth ID (UUID) as key,
    but the app primarily uses Public User ID (UUID) for navigation.
  */
  Future<String?> getAuthIdFromPublicId(String publicUserId) async {
    final res = await _client
        .from('users')
        .select('auth_user_id')
        .eq('user_id', publicUserId)
        .maybeSingle();

    return res?['auth_user_id'];
  }

  /*
    Fetch Portfolio for a User.
    Fetches all items grouped by type.
  */
  Future<Map<String, List<Map<String, dynamic>>>> fetchPortfolio(
    String authUserId,
  ) async {
    // 1. Fetch Parent Rows
    final portItems = await _client
        .from('portfolio')
        .select()
        .eq('user_id', authUserId)
        .order('created_at', ascending: false);

    final Map<String, List<Map<String, dynamic>>> result = {
      'achievement': [],
      'resume': [],
      'certificate': [],
      'link': [],
    };

    if (portItems.isEmpty) return result;

    // 2. Fetch Children based on type
    // We could do this with joins if we had foreign keys set up nicely in standard PostgREST way,
    // but separate queries are often cleaner for heterogeneous types.

    for (var item in portItems) {
      final pid = item['portfolio_id'];
      final type = item['type'] as String;

      if (type == 'achievement') {
        final child = await _client
            .from('portfolio_achievements')
            .select()
            .eq('portfolio_id', pid)
            .maybeSingle();
        if (child != null) result['achievement']!.add(child);
      } else if (type == 'resume') {
        final child = await _client
            .from('portfolio_resumes')
            .select()
            .eq('portfolio_id', pid)
            .maybeSingle();
        if (child != null) result['resume']!.add(child);
      } else if (type == 'certificate') {
        final child = await _client
            .from('portfolio_certificates')
            .select()
            .eq('portfolio_id', pid)
            .maybeSingle();
        if (child != null) result['certificate']!.add(child);
      } else if (type == 'link') {
        final child = await _client
            .from('portfolio_links')
            .select()
            .eq('portfolio_id', pid)
            .maybeSingle();
        if (child != null) result['link']!.add(child);
      }
    }

    return result;
  }

  /*
    Add Portfolio Item.
    Creates parent 'portfolio' row and child specific row transactionally-ish.
  */
  Future<void> addPortfolioItem({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // 1. Insert Parent
    final parentRes = await _client
        .from('portfolio')
        .insert({'user_id': userId, 'type': type})
        .select('portfolio_id')
        .single();

    final portfolioId = parentRes['portfolio_id'];

    // 2. Insert Child
    final childData = Map<String, dynamic>.from(data);
    childData['portfolio_id'] = portfolioId;

    String tableName;
    switch (type) {
      case 'achievement':
        tableName = 'portfolio_achievements';
        break;
      case 'resume':
        tableName = 'portfolio_resumes';
        break;
      case 'certificate':
        tableName = 'portfolio_certificates';
        break;
      case 'link':
        tableName = 'portfolio_links';
        break;
      default:
        throw Exception('Invalid portfolio type');
    }

    await _client.from(tableName).insert(childData);
  }

  Future<void> deletePortfolioItem(String portfolioId, String type) async {
    // Cascade delete on DB handles children, so just delete parent.
    // Extra safety: Verify ownership via RLS (automatic).
    await _client.from('portfolio').delete().eq('portfolio_id', portfolioId);
  }

  /*
    Upload Portfolio File.
    Uploads file to 'portfolio_uploads/{user_id}/{type}/{filename}'.
    Returns the purely public URL to be stored in the DB.
  */
  Future<String> uploadPortfolioFile({
    required String path, // Local file path
    required String type, // 'achievements', 'resumes', 'certificates'
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final file = File(path);
    final fileName = path.split('/').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = '$userId/$type/${timestamp}_$fileName';

    await _client.storage
        .from('portfolio_uploads')
        .upload(
          storagePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final publicUrl = _client.storage
        .from('portfolio_uploads')
        .getPublicUrl(storagePath);

    return publicUrl;
  }
}
