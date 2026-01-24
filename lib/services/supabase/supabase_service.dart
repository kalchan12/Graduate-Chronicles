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

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

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
    Smart Sign In (Email OR Institutional ID).
  */
  Future<AuthResponse> signInWithEmailOrId(
    String identifier,
    String password,
  ) async {
    final isEmail = identifier.contains('@');
    if (isEmail) {
      return await _client.auth.signInWithPassword(
        email: identifier,
        password: password,
      );
    } else {
      return await signInWithInstitutionalId(identifier, password);
    }
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
        .select('*, auth_user_id')
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
  /*
    Fetch Portfolio for a User.
    Fetches all items grouped by type.
    Returns grouping + 'portfolio_id' (from the most recent portfolio entry).
  */
  Future<Map<String, dynamic>> fetchPortfolio(String authUserId) async {
    // 1. Fetch Parent Rows
    final portItems = await _client
        .from('portfolio')
        .select()
        .eq('user_id', authUserId)
        .order('created_at', ascending: false);

    final Map<String, dynamic> result = {
      'achievement': <Map<String, dynamic>>[],
      'resume': <Map<String, dynamic>>[],
      'certificate': <Map<String, dynamic>>[],
      'link': <Map<String, dynamic>>[],
      'portfolio_id': null,
    };

    if (portItems.isEmpty) return result;

    // Use the most recent portfolio as the "active" one for ID purposes
    result['portfolio_id'] = portItems.first['portfolio_id'];

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
        if (child != null) (result['achievement'] as List).add(child);
      } else if (type == 'resume') {
        final child = await _client
            .from('portfolio_resumes')
            .select()
            .eq('portfolio_id', pid)
            .maybeSingle();
        if (child != null) (result['resume'] as List).add(child);
      } else if (type == 'certificate') {
        final child = await _client
            .from('portfolio_certificates')
            .select()
            .eq('portfolio_id', pid)
            .maybeSingle();
        if (child != null) (result['certificate'] as List).add(child);
      } else if (type == 'link') {
        final child = await _client
            .from('portfolio_links')
            .select()
            .eq('portfolio_id', pid)
            .maybeSingle();
        if (child != null) (result['link'] as List).add(child);
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

  // --- Reunion System Methods ---

  Future<void> createReunion({
    required String title,
    required String description,
    required String date,
    required String time,
    required String locationType,
    required String locationValue,
    required String visibility,
    int? batchYear,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _client.from('reunions').insert({
      'created_by': userId,
      'title': title,
      'description': description,
      'event_date': date,
      'event_time': time,
      'location_type': locationType,
      'location_value': locationValue,
      'visibility': visibility,
      'batch_year': batchYear,
    });
  }

  Future<List<Map<String, dynamic>>> fetchReunions() async {
    final res = await _client
        .from('reunions')
        .select()
        .order('event_date', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  // --- Yearbook System Methods ---

  // Batch operations
  // --- Stories Feature ---

  Future<String> uploadStoryMedia(File file) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Simple file validation
    final length = await file.length();
    if (length > 15 * 1024 * 1024) throw Exception('File size exceeds 15MB');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = file.path.split('.').last;
    final path = '$userId/story_$timestamp.$ext';

    await _client.storage
        .from('stories')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    final url = _client.storage.from('stories').getPublicUrl(path);
    return url;
  }

  Future<void> createStory({
    required String mediaUrl,
    required String type, // 'image' or 'video'
    String? caption,
  }) async {
    final publicUserId = await _getPublicUserId();

    await _client.from('stories').insert({
      'user_id': publicUserId,
      'media_url': mediaUrl,
      'media_type': type,
      'caption': caption,
      // expires_at defaults to 24h in DB
    });
  }

  Future<List<Map<String, dynamic>>> fetchActiveStories() async {
    // 1. Fetch active stories with user data join (single join to avoid PostgREST alias conflict)
    final res = await _client
        .from('stories')
        .select('''
          id,
          media_url,
          media_type,
          caption,
          created_at,
          expires_at,
          users (
            user_id,
            username,
            full_name
          )
        ''')
        .gt('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // --- Yearbook Feature ---
  Future<List<Map<String, dynamic>>> fetchYearbookBatches() async {
    final res = await _client
        .from('yearbook_batches')
        .select()
        .order('batch_year', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>?> fetchBatchByYear(int year) async {
    final res = await _client
        .from('yearbook_batches')
        .select()
        .eq('batch_year', year)
        .maybeSingle();

    return res;
  }

  /// Create a new yearbook batch (Admin only - enforced at UI layer)
  Future<void> createYearbookBatch({
    String? batchLabel,
    int? batchYear,
    String? slogan,
    String? createdByAdminId,
  }) async {
    await _client.from('yearbook_batches').insert({
      if (batchLabel != null) 'batch_label': batchLabel,
      if (batchYear != null) 'batch_year': batchYear,
      if (slogan != null) 'slogan': slogan,
      if (createdByAdminId != null) 'created_by_admin_id': createdByAdminId,
    });
  }

  // Entry operations with JOIN to users table
  Future<List<Map<String, dynamic>>> fetchApprovedYearbookEntries({
    required String batchId,
    String? majorFilter,
  }) async {
    var query = _client
        .from('yearbook_entries')
        .select('''
          id,
          user_id,
          batch_id,
          yearbook_photo_url,
          yearbook_bio,
          status,
          created_at,
          updated_at,
          users!yearbook_entries_user_id_fkey (
            full_name,
            username,
            major
          )
        ''')
        .eq('batch_id', batchId)
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    final res = await query;

    // Flatten the JOIN result
    final entries = List<Map<String, dynamic>>.from(res);
    return entries
        .map((entry) {
          final userData = entry['users'] as Map<String, dynamic>?;
          return {
            ...entry,
            'full_name': userData?['full_name'],
            'username': userData?['username'],
            'major': userData?['major'],
          }..remove('users');
        })
        .where((entry) {
          if (majorFilter != null && majorFilter.isNotEmpty) {
            return entry['major'] == majorFilter;
          }
          return true;
        })
        .toList();
  }

  Future<Map<String, dynamic>?> fetchMyYearbookEntry(String batchId) async {
    // Get public user ID (not auth.uid())
    final publicUserId = await _getPublicUserId();

    final res = await _client
        .from('yearbook_entries')
        .select('''
          id,
          user_id,
          batch_id,
          yearbook_photo_url,
          yearbook_bio,
          status,
          created_at,
          updated_at
        ''')
        .eq('user_id', publicUserId)
        .eq('batch_id', batchId)
        .maybeSingle();

    return res;
  }

  // Helper to get public.users.user_id from auth.uid()
  Future<String> _getPublicUserId() async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) throw Exception('Not authenticated');

    final res = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', authId)
        .single();

    return res['user_id'] as String;
  }

  Future<void> createYearbookEntry({
    required String batchId,
    required String yearbookPhotoUrl,
    String? yearbookBio,
  }) async {
    // Get public.users.id (not auth.users.id)
    final publicUserId = await _getPublicUserId();

    await _client.from('yearbook_entries').insert({
      'user_id': publicUserId,
      'batch_id': batchId,
      'yearbook_photo_url': yearbookPhotoUrl,
      'yearbook_bio': yearbookBio,
      'status': 'pending',
    });
  }

  Future<void> updateYearbookEntry({
    required String entryId,
    String? yearbookPhotoUrl,
    String? yearbookBio,
  }) async {
    final data = <String, dynamic>{};
    if (yearbookPhotoUrl != null) data['yearbook_photo_url'] = yearbookPhotoUrl;
    if (yearbookBio != null) data['yearbook_bio'] = yearbookBio;

    if (data.isEmpty) return;

    await _client.from('yearbook_entries').update(data).eq('id', entryId);
  }

  // Photo upload for yearbook
  Future<String> uploadYearbookPhoto(File file, int batchYear) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Compress image first
    final fileBytes = await file.readAsBytes();
    final compressed = await _compressImage(fileBytes);

    // Storage path: batch_<year>/<user_id>/yearbook.jpg
    final storagePath = 'batch_$batchYear/$userId/yearbook.jpg';

    await _client.storage
        .from('yearbook_upload')
        .uploadBinary(
          storagePath,
          compressed,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final publicUrl = _client.storage
        .from('yearbook_upload')
        .getPublicUrl(storagePath);

    return publicUrl;
  }

  // Admin operations
  Future<void> approveYearbookEntry(String entryId) async {
    await _client
        .from('yearbook_entries')
        .update({'status': 'approved'})
        .eq('id', entryId);
  }

  Future<void> rejectYearbookEntry(String entryId) async {
    await _client
        .from('yearbook_entries')
        .update({'status': 'rejected'})
        .eq('id', entryId);
  }

  Future<List<Map<String, dynamic>>> fetchPendingYearbookEntries() async {
    final res = await _client
        .from('yearbook_entries')
        .select('''
          id,
          user_id,
          batch_id,
          yearbook_photo_url,
          yearbook_bio,
          status,
          created_at,
          updated_at,
          users (
            full_name,
            username,
            major
          ),
          yearbook_batches (
             batch_year,
             batch_label
          )
        ''')
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    // Flatten the JOIN result
    final entries = List<Map<String, dynamic>>.from(res);
    return entries.map((entry) {
      final userData = entry['users'] as Map<String, dynamic>?;
      final batchData = entry['yearbook_batches'] as Map<String, dynamic>?;
      return {
        ...entry,
        'full_name': userData?['full_name'],
        'username': userData?['username'],
        'major': userData?['major'],
        'batch_label': batchData?['batch_label'],
        'batch_year': batchData?['batch_year'],
      }..removeWhere(
        (key, value) => key == 'users' || key == 'yearbook_batches',
      );
    }).toList();
  }

  Future<List<String>> fetchDistinctMajors() async {
    // res from RPC is removed as we are using fallback logic below
    // If RPC fails or acts up, we can fallback to raw query but distinct is annoying in client.
    // Actually, let's try a raw query workaround if RPC is not preferred,
    // but typically standard SQL: `select distinct major from users`
    // Supabase JS client doesn't support `.distinct()` easily on a column select without `.csv` or specific postgrest syntax.
    // But since the user instructions say "Populate dropdown values dynamically from: DISTINCT majors in users table",
    // We will use a hacky but standard way: fetch all (lightweight) and distinct in Dart, OR use a Postgres function.
    // Given I cannot create RPC functions easily without `setup.sql` access rights confirmed or risk breaking things,
    // I will fetch 'major' from users where major is not null.

    // Note: If users table is huge, this is bad. But for a uni project, it's fine.
    final data = await _client
        .from('users')
        .select('major')
        .neq('major', 'null');

    final majors = List<Map<String, dynamic>>.from(data)
        .map((e) => e['major'] as String?)
        .where((e) => e != null && e.isNotEmpty)
        .toSet()
        .toList();
    // toSet removes duplicates

    majors.sort();
    return majors.cast<String>();
  }

  /*
    Upload Portfolio Picture (Profile or Cover).
    Uploads to 'portfolio_uploads/{user_id}/{type}'.
    Returns the public URL.
    Also inserts/updates the 'portfolio_pictures' table.
  */
  Future<String> uploadPortfolioPicture({
    required String path,
    required String type, // 'profile' or 'cover'
    required String portfolioId, // Parent ID
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final file = File(path);
    final fileExt = path.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Overwrite per type usually, but uniqueness helps cache busting
    final storagePath = '$userId/$type/${timestamp}_$type.$fileExt';

    // 1. Upload to Storage
    await _client.storage
        .from('portfolio_uploads')
        .upload(
          storagePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    final publicUrl = _client.storage
        .from('portfolio_uploads')
        .getPublicUrl(storagePath);

    // 2. Upsert DB Record
    // We use upsert based on (portfolio_id, type) unique constraint
    await _client.from('portfolio_pictures').upsert({
      'portfolio_id': portfolioId,
      'type': type,
      'image_url': publicUrl,
    }, onConflict: 'portfolio_id, type');

    return publicUrl;
  }

  Future<Map<String, String?>> fetchPortfolioPictures(
    String portfolioId,
  ) async {
    final res = await _client
        .from('portfolio_pictures')
        .select('type, image_url')
        .eq('portfolio_id', portfolioId);

    final data = List<Map<String, dynamic>>.from(res);
    String? profileUrl;
    String? coverUrl;

    for (var item in data) {
      if (item['type'] == 'profile') profileUrl = item['image_url'];
      if (item['type'] == 'cover') coverUrl = item['image_url'];
    }

    return {'profile': profileUrl, 'cover': coverUrl};
  }

  // --- Portfolio Stats & Interaction ---

  Future<Map<String, dynamic>> getPortfolioStats(String portfolioId) async {
    final userId = _client.auth.currentUser?.id;

    // 1. Get View Count
    final portfolioRes = await _client
        .from('portfolio')
        .select('view_count')
        .eq('portfolio_id', portfolioId)
        .single();
    final views = portfolioRes['view_count'] as int? ?? 0;

    // 2. Get Like Count
    final likes = await _client
        .from('portfolio_likes')
        .count(CountOption.exact)
        .eq('portfolio_id', portfolioId);

    // 3. Check if Liked by User
    bool isLiked = false;
    if (userId != null) {
      final userLike = await _client
          .from('portfolio_likes')
          .select('id')
          .eq('portfolio_id', portfolioId)
          .eq('user_id', userId)
          .maybeSingle();
      isLiked = userLike != null;
    }

    return {'views': views, 'likes': likes, 'isLiked': isLiked};
  }

  Future<void> togglePortfolioLike(String portfolioId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final existing = await _client
        .from('portfolio_likes')
        .select('id')
        .eq('portfolio_id', portfolioId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      // Unlike
      await _client.from('portfolio_likes').delete().eq('id', existing['id']);
    } else {
      // Like
      await _client.from('portfolio_likes').insert({
        'portfolio_id': portfolioId,
        'user_id': userId,
      });
    }
  }

  Future<void> incrementPortfolioView(String portfolioId) async {
    // Ideally use RPC, but simple fetch-update is acceptable for this scope.
    // We don't worry about race conditions for views in this prototype.
    final res = await _client
        .from('portfolio')
        .select('view_count')
        .eq('portfolio_id', portfolioId)
        .single();

    final current = res['view_count'] as int? ?? 0;

    await _client
        .from('portfolio')
        .update({'view_count': current + 1})
        .eq('portfolio_id', portfolioId);
  }

  // --- User Discovery ---

  Future<List<Map<String, dynamic>>> fetchDiscoverableUsers() async {
    final userId = _client.auth.currentUser?.id;

    // FILTERS FIRST, then order.

    // We need two queries depending on auth? No, just filter applier.
    // We'll use the joined query strategy, but correct order.

    var joinedQuery = _client
        .from('users')
        .select('*, profile(profile_picture)');

    if (userId != null) {
      joinedQuery = joinedQuery.neq('auth_user_id', userId);
    }

    // order() is a modifier, comes last.
    final res = await joinedQuery.order('created_at', ascending: false);

    final List<Map<String, dynamic>> users = [];

    for (var row in (res as List)) {
      final user = Map<String, dynamic>.from(row);

      // Fix Profile Picture URL
      // profile is a single object or list depending on relationship (1:1 -> object)
      final profile = user['profile'];
      String? avatarUrl;

      if (profile != null && profile['profile_picture'] != null) {
        final path = profile['profile_picture'];
        avatarUrl = _client.storage.from('avatar').getPublicUrl(path);
      }

      user['avatar_url'] = avatarUrl;
      users.add(user);
    }

    return users;
  }

  // --- Messaging System ---

  Future<String> startConversation(String targetUserId) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');

    // 1. Try to reuse existing conversation via secure RPC
    // The RPC 'get_conversation_id' bypasses RLS to check for an existing chat ID
    try {
      final data = await _client.rpc(
        'get_conversation_id',
        params: {'target_user_id': targetUserId},
      );

      if (data != null) {
        return data as String;
      }
    } catch (e) {
      // If RPC is missing or fails, log it but proceed to try creating (or fail if critical)
      print('RPC get_conversation_id error (ignoring): $e');
    }

    // 2. Create New Conversation (Strict Order Required by RLS)

    // Step A: Create Conversation Row (No user_id, public creation allowed)
    final convoRes = await _client
        .from('conversations')
        .insert({})
        .select('id')
        .single();
    final convoId = convoRes['id'] as String;

    // Step B: Add SELF (Allowed by RLS rule: "user_id = auth.uid()")
    await _client.from('conversation_participants').insert({
      'conversation_id': convoId,
      'user_id': currentUserId,
    });

    // Step C: Add TARGET (Allowed by RLS rule: "EXISTS... I am a participant")
    // This MUST happen after Step B.
    await _client.from('conversation_participants').insert({
      'conversation_id': convoId,
      'user_id': targetUserId,
    });

    return convoId;
  }

  // Need helper to resolve Public ID -> Auth ID if we use Public IDs in UI
  // I already have `getAuthIdFromPublicId`.

  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Get my conversations
    final myConvos = await _client
        .from('conversation_participants')
        .select('conversation_id, conversations(updated_at)')
        .eq('user_id', userId)
        .order('created_at', ascending: false); // Order by join? tricky.

    // We want to sort by updated_at of conversation usually.
    // For now, simple list.

    final List<Map<String, dynamic>> fullConvos = [];

    for (var c in (myConvos as List)) {
      final convoId = c['conversation_id'];

      // Get Other Participants (names, avatars)
      final participants = await _client
          .from('conversation_participants')
          .select('user_id')
          .eq('conversation_id', convoId)
          .neq('user_id', userId); // Exclude me

      if ((participants as List).isEmpty) continue; // Just me?

      final otherAuthId = participants.first['user_id'];

      // Get details for snippet
      final userDetails = await _client
          .from('users')
          .select('full_name, username')
          .eq('auth_user_id', otherAuthId)
          .maybeSingle();

      // Get Avatar
      final profileParams = await _client
          .from('profile')
          .select('profile_picture')
          .eq('user_id', otherAuthId)
          .maybeSingle();
      String? avatar;
      if (profileParams != null && profileParams['profile_picture'] != null) {
        avatar = _client.storage
            .from('avatar')
            .getPublicUrl(profileParams['profile_picture']);
      }

      // Get Last Message
      final lastMsg = await _client
          .from('messages')
          .select('content, created_at, sender_id')
          .eq('conversation_id', convoId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      fullConvos.add({
        'id': convoId,
        'other_user_name': userDetails?['full_name'] ?? 'User',
        'other_user_avatar': avatar,
        'target_auth_id': otherAuthId, // Useful for navigation
        'last_message': lastMsg?['content'],
        'last_message_time': lastMsg?['created_at'],
      });
    }

    return fullConvos;
  }

  Future<List<Map<String, dynamic>>> fetchMessages(
    String conversationId,
  ) async {
    final res = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true); // Oldest first for chat list

    return List<Map<String, dynamic>>.from(res);
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'content': content,
    });

    // Update conversation updated_at
    await _client
        .from('conversations')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', conversationId);
  }

  // --- Admin Access System ---

  /*
     Submit Admin Request (Isolated System).
     Inserts into `admin_requests` via secure RPC.
     Does NOT create a Supabase Auth User.
  */
  Future<void> submitAdminRequest({
    required String fullName,
    required String username,
    required String email,
    required String adminId,
    required String password,
  }) async {
    // Call the RPC that handles hashing
    await _client.rpc(
      'submit_admin_request',
      params: {
        'full_name': fullName,
        'username': username,
        'email': email,
        'admin_id': adminId,
        'password_text': password,
      },
    );
  }

  /*
     Verify Admin Login (Isolated System).
     Calls secure RPC to verify credentials against `admins` table.
     Returns the Admin Map if successful, or throws Exception.
  */
  Future<Map<String, dynamic>> verifyAdminLogin({
    required String identifier, // Email or Admin ID
    required String password,
  }) async {
    final response = await _client.rpc(
      'verify_admin_login',
      params: {'identifier': identifier, 'password_input': password},
    );

    if (response == null || response['success'] != true) {
      throw Exception(response?['message'] ?? 'Login failed');
    }

    return Map<String, dynamic>.from(response);
  }

  /*
    Fetch request status (Isolated).
    We can't rely on 'user_id' anymore since we are unauthenticated.
    However, for privacy, we can't just let anyone search by email without auth.
    
    Refactor: 
    The "Check Status" feature for users who submitted a request is tricky without Auth.
    They would need to "Login" to check status?
    
    For now, we will return null/empty or implement a limited check if needed.
    But strictly speaking, once submitted, they wait for approval email or just try to login.
  */
  Future<String?> fetchAdminRequestStatus(String email) async {
    // NOTE: This might be insecure if open to public.
    // Ideally, we move this logic.
    // For this iteration, we will rely on "Try Login -> Failed (Inactive)" flow.
    return null;
  }

  Future<Map<String, int>> getAdminDashboardStats() async {
    // Run count queries in parallel for efficiency
    final results = await Future.wait([
      _client.from('users').count(CountOption.exact), // Total
      _client.from('users').count(CountOption.exact).eq('role', 'Student'),
      _client.from('users').count(CountOption.exact).eq('role', 'Graduate'),
      _client.from('users').count(CountOption.exact).eq('role', 'Alumni'),
      _client.from('users').count(CountOption.exact).eq('role', 'Staff'),
    ]);

    return {
      'total': results[0],
      'student': results[1],
      'graduate': results[2],
      'alumni': results[3],
      'staff': results[4],
    };
  }

  // ========== USER DIRECTORY (ADMIN) ==========

  /// Fetch all users for admin directory
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final response = await _client
        .from('users')
        .select('user_id, full_name, username, email, role, created_at')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Fetch users filtered by role
  Future<List<Map<String, dynamic>>> fetchUsersByRole(String role) async {
    final response = await _client
        .from('users')
        .select('user_id, full_name, username, email, role, created_at')
        .eq('role', role)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Search users by name, username, or email with optional role filter
  Future<List<Map<String, dynamic>>> searchUsers(
    String query,
    String? roleFilter,
  ) async {
    var queryBuilder = _client
        .from('users')
        .select('user_id, full_name, username, email, role, created_at');

    // Apply role filter if provided
    if (roleFilter != null && roleFilter != 'All') {
      queryBuilder = queryBuilder.eq('role', roleFilter);
    }

    // Search across multiple fields (case-insensitive)
    // Using OR condition for name, username, email
    queryBuilder = queryBuilder.or(
      'full_name.ilike.%$query%,username.ilike.%$query%,email.ilike.%$query%',
    );

    final response = await queryBuilder.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }
}
