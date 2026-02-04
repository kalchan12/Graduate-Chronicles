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
  String? get currentAuthUserId => _client.auth.currentUser?.id;

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
    required String? program, // Added program
    required int? graduationYear,
    required String? school, // School abbreviation string
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
        'program': program, // Insert program
        'graduation_year': graduationYear,
        'school': school,
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

  /*
    Fetch Schools.
  */
  Future<List<Map<String, dynamic>>> fetchSchools() async {
    final res = await _client
        .from('schools')
        .select('id, name, abbreviation')
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(res);
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

  Future<Map<String, dynamic>?> fetchUserProfile(String authUserId) async {
    final res = await _client
        .from('users')
        .select(
          'full_name, major, role, username, program',
        ) // Fetch program too
        .eq('auth_user_id', authUserId)
        .maybeSingle();
    return res;
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
    Fetch Random Profiles.
    Returns a list of random user profiles for featured sections.
  */
  Future<List<Map<String, dynamic>>> fetchRandomProfiles({
    int limit = 5,
  }) async {
    try {
      // PostgreSQL random() for random ordering
      final res = await _client
          .from('users')
          .select('user_id, full_name, major, role, username, program')
          .order('random()', ascending: true)
          .limit(limit);

      // Enrich with profile pictures
      final List<Map<String, dynamic>> enriched = [];
      for (final user in res) {
        final profileRes = await _client
            .from('profile')
            .select('profile_picture')
            .eq('user_id', user['user_id'])
            .maybeSingle();

        final Map<String, dynamic> item = Map.from(user);
        if (profileRes != null && profileRes['profile_picture'] != null) {
          item['profile_picture_url'] = _client.storage
              .from('avatar')
              .getPublicUrl(profileRes['profile_picture']);
        }
        item['title'] = user['full_name'] ?? 'Unknown';
        item['description'] = user['major'] ?? user['role'] ?? '';
        item['image_url'] = item['profile_picture_url'];
        enriched.add(item);
      }
      return enriched;
    } catch (e) {
      print('Error fetching random profiles: $e');
      return [];
    }
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

  /// Batch fetch profile pictures for multiple users.
  /// Returns a Map of userId -> profile picture URL (or null if not found).
  /// Optimized for fetching multiple users' avatars in one go.
  Future<Map<String, String?>> fetchProfilePicturesForUsers(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    try {
      final res = await _client
          .from('profile')
          .select('user_id, profile_picture')
          .inFilter('user_id', userIds);

      final Map<String, String?> result = {};
      for (final row in res) {
        final userId = row['user_id'] as String;
        final path = row['profile_picture'] as String?;
        if (path != null && path.isNotEmpty) {
          result[userId] = _client.storage.from('avatar').getPublicUrl(path);
        } else {
          result[userId] = null;
        }
      }
      return result;
    } catch (e) {
      print('Error fetching profile pictures: $e');
      return {};
    }
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

    // Get internal user_id for participant record
    final userRes = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', userId)
        .single();
    final internalUserId = userRes['user_id'] as String;

    final response = await _client
        .from('reunions')
        .insert({
          'created_by': userId,
          'title': title,
          'description': description,
          'event_date': date,
          'event_time': time,
          'location_type': locationType,
          'location_value': locationValue,
          'visibility': visibility,
          'batch_year': batchYear,
        })
        .select()
        .single();

    final reunionId = response['id'] as String;

    // Auto-join the creator
    await _client.from('reunion_participants').insert({
      'reunion_id': reunionId,
      'user_id': internalUserId,
      'status': 'going',
    });
  }

  Future<List<Map<String, dynamic>>> fetchReunions({
    bool futureEventsOnly = false, // Persist future events
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Get current user's UUID (not Auth ID) for join check
    final userRes = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', userId)
        .single();
    final userUuid = userRes['user_id'] as String;

    var query = _client.from('reunions').select('''
      *,
      reunion_participants (count),
      is_joined:reunion_participants!left(user_id)
    ''');
    // Note: The !left join with filtering specific to current user
    // is tricky in simple syntax. simpler approach:
    // fetch all, then map. Or use rpc if performance needed.
    // For now, let's fetch raw and process.

    // Actually, simpler query pattern for 'is_joined':
    // We can just fetch the list, and for each, check participation?
    // OR: use a view.
    // Let's stick to standard select and separate check or join.

    // Better query:
    final res = await _client
        .from('reunions')
        .select('*, reunion_participants(user_id)')
        .order('event_date', ascending: true);

    // Filter future events if requested (client side for simple logic, seeing date is string)
    // Date format in DB is YYYY-MM-DD
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final List<Map<String, dynamic>> enriched = [];

    for (final item in res) {
      final dateStr = item['event_date'] as String;
      // Simple string comparison works for ISO dates YYYY-MM-DD
      // If we want "persist as long as still there", we show past events too?
      // User said: "persist as long as the reunion is still there in futures" -> Future events.
      // But maybe they want history? Let's show all for now, sorted.
      // User complaint: "once reunion plan is created it does not persist".
      // This implies it disappears. Maybe RLS hides it?
      // RLS policies were: visible if public or batch match.

      final participants = item['reunion_participants'] as List;
      final goingCount = participants.length;
      final isJoined = participants.any((p) => p['user_id'] == userUuid);

      if (futureEventsOnly && dateStr.compareTo(todayStr) < 0) {
        continue;
      }

      enriched.add({
        ...item,
        'going_count': goingCount,
        'is_joined': isJoined,
        'reunion_participants': null, // Remove raw list to keep clean
      });
    }

    return enriched;
  }

  Future<void> joinReunion(String reunionId) async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) throw Exception('Not authenticated');

    // Get real UUID
    final userRes = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', authId)
        .single();
    final userUuid = userRes['user_id'] as String;

    await _client.from('reunion_participants').insert({
      'reunion_id': reunionId,
      'user_id': userUuid,
      'status': 'going',
    });
  }

  Future<void> leaveReunion(String reunionId) async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) throw Exception('Not authenticated');

    // Get real UUID
    final userRes = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', authId)
        .single();
    final userUuid = userRes['user_id'] as String;

    await _client
        .from('reunion_participants')
        .delete()
        .eq('reunion_id', reunionId)
        .eq('user_id', userUuid);
  }

  Future<List<Map<String, dynamic>>> fetchReunionParticipants(
    String reunionId,
  ) async {
    final res = await _client
        .from('reunion_participants')
        .select(
          '*, users(full_name, username, profile_picture)',
        ) // Join users info through user_id?
        // Note: users table is authoritative for profile info in this app schema?
        // Or profile table?
        // Earlier code used 'profile' table for avatar.
        // Let's check: users has auth_user_id. profile is separate.
        // We probably need to join users to get name, then profile for avatar?
        // Let's look at users table again.
        // 'users' has: user_id, auth_user_id, full_name, username...
        // 'profile' has: user_id (ref auth?), profile_picture...
        // Actually, let's just get the users info directly.
        // And we'll fetch avatars separately or if we can join.
        // Assuming 'users' has basic info.
        // But wait, profile picture is in 'profile' table usually?
        // Let's check MessagingService: it fetches profile separately.
        // We will stick to that pattern if needed, or simple join.
        // Let's assume we can get basic user info.
        .eq('reunion_id', reunionId);

    // Since complex joins might be tricky without defined FKs in Flutter client sometimes,
    // let's do safe fetch.
    // Actually, let's just fetch participants then fetch user details.

    // Better path:
    return _client
        .from('reunion_participants')
        .select('created_at, users(full_name, username)') // Assuming FK exists
        .eq('reunion_id', reunionId)
        .then((rows) async {
          final List<Map<String, dynamic>> results = [];
          for (final row in rows) {
            final user = row['users'] as Map<String, dynamic>;
            // We ideally want avatar too.
            // Let's keep it simple for "Who is Going": Name is most important.
            results.add(user);
          }
          return results;
        });
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

  /*
    Fetch Random Yearbook Entries.
    Returns random approved yearbook entries for featured carousels.
  */
  Future<List<Map<String, dynamic>>> fetchRandomYearbookEntries({
    int limit = 5,
    int? batchYear,
  }) async {
    try {
      print('🔍 Featured fetch: batchYear=$batchYear, limit=$limit');

      var query = _client
          .from('yearbook_entries')
          .select(
            'id, yearbook_photo_url, yearbook_bio, batch_id, user_id, users!inner (full_name), yearbook_batches!inner(batch_year)',
          )
          .eq(
            'status',
            'approved',
          ); // Fixed: was 'is_approved' which doesn't exist

      if (batchYear != null) {
        query = query.eq('yearbook_batches.batch_year', batchYear);
      }

      final res = await query
          .order('created_at', ascending: false)
          .limit(limit);

      print('🔍 Featured results count: ${res.length}');

      return res.map((e) {
        final data = e as Map<String, dynamic>;
        final user = data['users'] as Map<String, dynamic>?;
        final batch = data['yearbook_batches'] as Map<String, dynamic>?;
        final year = batch?['batch_year'];

        return {
          'id': data['id'],
          'title': user?['full_name'] ?? 'Graduate',
          'description': data['yearbook_bio'] ?? 'Yearbook Entry',
          'image_url': data['yearbook_photo_url'],
          'badge': year != null ? 'GRAD $year' : 'GRAD',
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching random yearbook entries: $e');
      return [];
    }
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
          yearbook_photo_url,
          yearbook_bio,
          more_pictures,
          status,
          created_at,
          updated_at,
          users!yearbook_entries_user_id_fkey (
            full_name,
            username,
            major,
            school,
            institutional_id,
            user_id
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
            'school': userData?['school'],
            'institutional_id': userData?['institutional_id'],
            'public_user_id':
                userData?['user_id'], // Map nested public ID to flat key
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
          yearbook_bio,
          status,
          created_at,
          updated_at,
          more_pictures
        ''')
        .eq('user_id', publicUserId)
        .eq('batch_id', batchId)
        .maybeSingle();

    return res;
  }

  // Helper to get public.users.user_id from auth.uid()
  // Now delegates to the unified cached method
  Future<String> _getPublicUserId() async {
    return _fetchPublicUserId();
  }

  Future<void> createYearbookEntry({
    required String batchId,
    required String yearbookPhotoUrl,
    String? yearbookBio,
    List<String>? morePictures,
  }) async {
    // Get public.users.id (not auth.users.id)
    final publicUserId = await _getPublicUserId();

    await _client.from('yearbook_entries').insert({
      'user_id': publicUserId,
      'batch_id': batchId,
      'yearbook_photo_url': yearbookPhotoUrl,
      'yearbook_bio': yearbookBio,
      'status': 'pending',
      'more_pictures': morePictures ?? [],
    });
  }

  Future<void> updateYearbookEntry({
    required String entryId,
    String? yearbookPhotoUrl,
    String? yearbookBio,
    List<String>? morePictures,
  }) async {
    final data = <String, dynamic>{};
    if (yearbookPhotoUrl != null) data['yearbook_photo_url'] = yearbookPhotoUrl;
    if (yearbookBio != null) data['yearbook_bio'] = yearbookBio;
    if (morePictures != null) data['more_pictures'] = morePictures;

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

  // Gallery upload for yearbook (Unique timestamps)
  Future<String> uploadYearbookGalleryImage(File file, int batchYear) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Compress image first
    final fileBytes = await file.readAsBytes();
    final compressed = await _compressImage(fileBytes);

    // Storage path: batch_<year>/<user_id>/gallery_<timestamp>.jpg
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // We add a random component to be extra safe against rapid uploads
    final uniqueId = DateTime.now().microsecond;
    final storagePath =
        'batch_$batchYear/$userId/gallery_${timestamp}_$uniqueId.jpg';

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
    final authId = _client.auth.currentUser?.id;

    // 1. Get View Count from valid views table
    final views = await _client
        .from('portfolio_views')
        .count(CountOption.exact)
        .eq('portfolio_id', portfolioId);

    // 2. Get Like Count
    final likes = await _client
        .from('portfolio_likes')
        .count(CountOption.exact)
        .eq('portfolio_id', portfolioId);

    // 3. Check if Liked by User (using auth_user_id directly)
    bool isLiked = false;
    if (authId != null) {
      final userLike = await _client
          .from('portfolio_likes')
          .select('id')
          .eq('portfolio_id', portfolioId)
          .eq('auth_user_id', authId)
          .maybeSingle();
      isLiked = userLike != null;
    }

    return {'views': views, 'likes': likes, 'isLiked': isLiked};
  }

  Future<void> togglePortfolioLike(String portfolioId) async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) throw Exception('Not authenticated');

    print('❤️ togglePortfolioLike: portfolioId=$portfolioId, authId=$authId');

    final existing = await _client
        .from('portfolio_likes')
        .select('id')
        .eq('portfolio_id', portfolioId)
        .eq('auth_user_id', authId)
        .maybeSingle();

    if (existing != null) {
      // Unlike
      await _client.from('portfolio_likes').delete().eq('id', existing['id']);
      print('❤️ Like removed');
    } else {
      // Like
      await _client.from('portfolio_likes').insert({
        'portfolio_id': portfolioId,
        'auth_user_id': authId,
      });
      print('❤️ Like added');
    }
  }

  Future<void> incrementPortfolioView(String portfolioId) async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) {
      print('👁️ incrementPortfolioView: Skipping (not authenticated)');
      return;
    }

    print(
      '👁️ incrementPortfolioView: portfolioId=$portfolioId, authId=$authId',
    );
    try {
      await _client.from('portfolio_views').insert({
        'portfolio_id': portfolioId,
        'auth_user_id': authId,
      });
    } catch (e) {
      // Ignore duplicate view errors (user already viewed)
      if (e.toString().contains('duplicate') ||
          e.toString().contains('unique')) {
        print('👁️ View already recorded for this user');
      } else {
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchPortfolioLikes(
    String portfolioId,
  ) async {
    // Join with users table via auth_user_id -> users.auth_user_id
    final response = await _client
        .from('portfolio_likes')
        .select('created_at, auth_user_id')
        .eq('portfolio_id', portfolioId)
        .order('created_at', ascending: false);

    // Enrich with user details
    final likes = List<Map<String, dynamic>>.from(response);
    final enriched = <Map<String, dynamic>>[];
    for (final like in likes) {
      final authId = like['auth_user_id'];
      if (authId != null) {
        final user = await _client
            .from('users')
            .select('full_name, role, major')
            .eq('auth_user_id', authId)
            .maybeSingle();
        enriched.add({'created_at': like['created_at'], 'users': user});
      }
    }
    return enriched;
  }

  Future<List<Map<String, dynamic>>> fetchPortfolioViews(
    String portfolioId,
  ) async {
    final response = await _client
        .from('portfolio_views')
        .select('created_at, auth_user_id')
        .eq('portfolio_id', portfolioId)
        .order('created_at', ascending: false);

    // Enrich with user details
    final views = List<Map<String, dynamic>>.from(response);
    final enriched = <Map<String, dynamic>>[];
    for (final view in views) {
      final authId = view['auth_user_id'];
      if (authId != null) {
        final user = await _client
            .from('users')
            .select('full_name, role, major')
            .eq('auth_user_id', authId)
            .maybeSingle();
        enriched.add({'created_at': view['created_at'], 'users': user});
      }
    }
    return enriched;
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

  // ========== SOCIAL FEATURES (Connect & Notifications) ==========

  // 1. Connection Requests

  /// Send a connection request to a target user
  Future<void> sendConnectionRequest(String targetUserId) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    // Prevent self-connect
    if (myId == targetUserId) {
      throw Exception('Cannot connect with yourself');
    }

    print('🔗 sendConnectionRequest: sender=$myId, target=$targetUserId');

    try {
      // 1. Check for existing request (in either direction)
      // We only care if I already sent one.
      final existingParams = await _client
          .from('connection_requests')
          .select()
          .eq('sender_id', myId)
          .eq('receiver_id', targetUserId)
          .maybeSingle();

      if (existingParams != null) {
        final status = existingParams['status'] as String;
        if (status == 'rejected') {
          // Retry: Update status to pending
          print('🔄 Reactivating rejected request...');
          await _client
              .from('connection_requests')
              .update({
                'status': 'pending',
                'created_at': DateTime.now().toIso8601String(),
              })
              .eq('id', existingParams['id']);
          print('✅ Connection request reactivated');
          return;
        } else if (status == 'pending') {
          throw Exception('Connection request already sent');
        } else if (status == 'accepted') {
          throw Exception('You are already connected');
        }
      }

      // 2. Insert new request if none exists
      await _client.from('connection_requests').insert({
        'sender_id': myId,
        'receiver_id': targetUserId,
        'status': 'pending',
      });
      print('✅ Connection request sent successfully');
    } catch (e) {
      print('❌ sendConnectionRequest failed: $e');
      if (e.toString().contains('duplicate') ||
          e.toString().contains('unique')) {
        throw Exception('Connection request already exists');
      }
      rethrow;
    }
  }

  /// Get the total count of accepted connections for a user (auth_user_id)
  /// Counts both sent and received connections that are accepted
  Future<int> getConnectionCount(String authUserId) async {
    try {
      // Count where user is sender and status is accepted
      final sentResponse = await _client
          .from('connection_requests')
          .select()
          .eq('sender_id', authUserId)
          .eq('status', 'accepted');

      // Count where user is receiver and status is accepted
      final receivedResponse = await _client
          .from('connection_requests')
          .select()
          .eq('receiver_id', authUserId)
          .eq('status', 'accepted');

      return (sentResponse as List).length + (receivedResponse as List).length;
    } catch (e) {
      print('Error fetching connection count: $e');
      return 0;
    }
  }

  /// Remove a connection with a target user (disconnect)
  /// Deletes the connection request row entirely
  Future<void> removeConnection(String targetAuthUserId) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    print('🔗 removeConnection: myId=$myId, target=$targetAuthUserId');

    try {
      // Delete where I am sender and they are receiver
      await _client
          .from('connection_requests')
          .delete()
          .eq('sender_id', myId)
          .eq('receiver_id', targetAuthUserId)
          .eq('status', 'accepted');

      // Also delete where they are sender and I am receiver
      await _client
          .from('connection_requests')
          .delete()
          .eq('sender_id', targetAuthUserId)
          .eq('receiver_id', myId)
          .eq('status', 'accepted');

      print('✅ Connection removed successfully');
    } catch (e) {
      print('❌ removeConnection failed: $e');
      rethrow;
    }
  }

  // ========== ADMIN: CONTENT MODERATION ==========

  Future<List<Map<String, dynamic>>> fetchReportedPosts() async {
    // Direct query approach (matching user_monitoring pattern)
    // Relies on public SELECT RLS policy on post_reports
    try {
      print('DEBUG: Fetching reported posts...');

      final reports = await _client
          .from('post_reports')
          .select('*')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      print('DEBUG: Raw reports count: ${reports.length}');

      if (reports.isEmpty) {
        print('DEBUG: No pending reports found.');
        return [];
      }

      // Enrich each report with post and user data
      final enrichedReports = <Map<String, dynamic>>[];

      for (final report in reports) {
        final postId = report['post_id'];
        final reporterId = report['reporter_id'];

        // Fetch post data
        Map<String, dynamic>? postData;
        Map<String, dynamic>? postOwnerData;

        try {
          final postResult = await _client
              .from('posts')
              .select('*')
              .eq('id', postId)
              .maybeSingle();

          if (postResult != null) {
            postData = postResult;

            // Fetch post owner
            final ownerId = postResult['user_id'];
            if (ownerId != null) {
              try {
                postOwnerData = await _client
                    .from('users')
                    .select('username, institutional_id, full_name, role')
                    .eq('user_id', ownerId)
                    .maybeSingle();
              } catch (e) {
                print('DEBUG: Error fetching post owner $ownerId: $e');
              }
            }
          }
        } catch (e) {
          print('DEBUG: Error fetching post $postId: $e');
        }

        // Attach owner to post object
        if (postData != null && postOwnerData != null) {
          postData['owner'] = postOwnerData;
        }

        // Fetch reporter data
        Map<String, dynamic>? reporterData;
        try {
          reporterData = await _client
              .from('users')
              .select('username, institutional_id')
              .eq('user_id', reporterId)
              .maybeSingle();
        } catch (e) {
          print('DEBUG: Error fetching reporter $reporterId: $e');
        }

        enrichedReports.add({
          ...report,
          'posts': postData,
          'reporter': reporterData,
        });
      }

      print('DEBUG: Enriched reports count: ${enrichedReports.length}');
      return enrichedReports;
    } catch (e) {
      print('Error fetching reported posts: $e');
      rethrow;
    }
  }

  Future<void> banPost(String postId) async {
    // Direct delete (relies on public DELETE RLS policy)
    try {
      await _client.from('posts').delete().eq('id', postId);
      print('Post $postId banned/deleted.');
    } catch (e) {
      print('Error banning post: $e');
      rethrow;
    }
  }

  Future<void> dismissReport(String reportId) async {
    // Update status to dismissed (relies on public UPDATE RLS policy)
    try {
      await _client
          .from('post_reports')
          .update({'status': 'dismissed'})
          .eq('id', reportId);
      print('Report $reportId dismissed.');
    } catch (e) {
      print('Error dismissing report: $e');
      rethrow;
    }
  }

  // ... (keeping other methods)

  // ... at the bottom ...

  /// Report a post
  Future<void> reportPost(
    String postId,
    String reason,
    String postOwnerId,
  ) async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) throw Exception('Not authenticated');

    // Lookup real user_id
    final userRow = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', authId)
        .single();
    final userId = userRow['user_id'] as String;

    await _client.from('post_reports').insert({
      'post_id': postId,
      'reporter_id': userId,
      'post_owner_id': postOwnerId, // Added
      'reason': reason,
      'status': 'pending', // Explicitly set
    });
  }

  /// Respond to a connection request (Accept/Deny)
  Future<void> respondToConnectionRequest(
    String requestId,
    String status,
  ) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    await _client
        .from('connection_requests')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId);
  }

  /// Get connection status between current user and target user
  /// Returns: 'none', 'pending_sent', 'pending_received', 'accepted', 'denied'
  Future<String> getConnectionStatus(String targetUserId) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) return 'none';

    print('🔍 getConnectionStatus: myId=$myId, targetId=$targetUserId');

    // 1. Check if I sent a request
    final myRequest = await _client
        .from('connection_requests')
        .select('status')
        .eq('sender_id', myId)
        .eq('receiver_id', targetUserId)
        .maybeSingle();

    if (myRequest != null) {
      final status = myRequest['status'] as String;
      print('🔍 Found my request with status: $status');
      if (status == 'accepted') return 'accepted';
      if (status == 'pending') return 'pending_sent';
    }

    // 2. Check if they sent a request
    final theirRequest = await _client
        .from('connection_requests')
        .select('status')
        .eq('sender_id', targetUserId)
        .eq('receiver_id', myId)
        .maybeSingle();

    if (theirRequest != null) {
      final status = theirRequest['status'] as String;
      print('🔍 Found their request with status: $status');
      // If they sent it and it's accepted, we are connected
      if (status == 'accepted') return 'accepted';
      // If they sent it and it's pending, I have a request to answer
      if (status == 'pending') return 'pending_received';
    }

    print('🔍 No connection found, returning none');
    return 'none';
  }

  // 2. Notifications

  /// Fetch notifications  // 4. Notifications
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) {
      print('❌ fetchNotifications: Not authenticated');
      throw Exception('Not authenticated');
    }

    print('🔔 Fetching notifications for user: $myId');

    print('🔔 DEBUG: fetchNotifications START for user: $myId');
    try {
      final response = await _client
          .from('notifications')
          .select(
            'id, title, description, created_at, is_read, type, user_id, reference_id, related_user_id',
          )
          .eq('user_id', myId)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> notifications =
          List<Map<String, dynamic>>.from(response);

      // Collect connection request IDs
      final connectionRequestIds = <String>[];
      for (var n in notifications) {
        if (n['type'] == 'connection_request' && n['reference_id'] != null) {
          connectionRequestIds.add(n['reference_id'] as String);
        }
      }

      if (connectionRequestIds.isNotEmpty) {
        // Batch fetch connection requests to identify senders
        final requests = await _client
            .from('connection_requests')
            .select('id, sender_id')
            .filter('id', 'in', connectionRequestIds);

        final requestIdToSenderId = {
          for (var r in requests) r['id'] as String: r['sender_id'] as String,
        };

        final senderIds = requestIdToSenderId.values.toSet().toList();

        if (senderIds.isNotEmpty) {
          // Batch fetch profiles
          // Using select * to get all potential fields needed, especially avatar_url
          // Batch fetch profiles
          // Using select * to get all potential fields needed, especially avatar_url
          final profilesData = await _client
              .from('users')
              .select('user_id, full_name, username')
              .filter('user_id', 'in', senderIds);

          final senderIdToProfile = {
            for (var p in profilesData) p['user_id'] as String: p,
          };

          // attach profile to notification
          for (var n in notifications) {
            if (n['type'] == 'connection_request' &&
                n['reference_id'] != null) {
              final reqId = n['reference_id'] as String;
              final senderId = requestIdToSenderId[reqId];
              if (senderId != null) {
                n['related_user_id'] = senderId;
                n['sender_profile'] = senderIdToProfile[senderId];
              }
            }
          }
        }
      }

      print('✅ Fetched ${notifications.length} notifications (enriched)');
      return notifications;
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MENTORSHIP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch users eligible to be mentors (e.g. graduates, staff)
  Future<List<Map<String, dynamic>>> fetchMentors() async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    try {
      // Get users who are 'graduate' or 'staff'
      final response = await _client
          .from('users')
          .select('user_id, full_name, role, job_title, company, auth_user_id')
          .or('role.eq.graduate,role.eq.staff') // Filter eligible roles
          .neq('auth_user_id', myId); // Exclude self

      // Enrich with profile picture and tags if needed
      // For now, returning basic user info + role/job
      final List<Map<String, dynamic>> mentors = [];

      for (var user in response) {
        final userId = user['user_id'] as String;

        // Fetch profile specifically for the image & tags/skills
        // (Assuming tags might be in profile or bio?)
        final profile = await _client
            .from('profile')
            .select('profile_picture, bio')
            .eq('user_id', userId)
            .maybeSingle();

        String? avatarUrl;
        if (profile != null && profile['profile_picture'] != null) {
          avatarUrl = _client.storage
              .from('avatar')
              .getPublicUrl(profile['profile_picture']);
        }

        mentors.add({
          ...user,
          'bio': profile?['bio'] ?? '',
          'avatar_url': avatarUrl,
        });
      }
      return mentors;
    } catch (e) {
      print('❌ fetchMentors error: $e');
      rethrow;
    }
  }

  /// Get all mentorship records where I am Mentee OR Mentor
  Future<List<Map<String, dynamic>>> fetchMyMentorships() async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    try {
      final response = await _client
          .from('mentorships')
          .select()
          .or('mentee_id.eq.$myId,mentor_id.eq.$myId');
      return response;
    } catch (e) {
      print('❌ fetchMyMentorships error: $e');
      return [];
    }
  }

  Future<void> requestMentorship(String mentorId) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    await _client.from('mentorships').insert({
      'mentee_id': myId,
      'mentor_id': mentorId,
      'status': 'pending',
    });
  }

  Future<void> updateMentorshipStatus(
    String mentorshipId,
    String status,
  ) async {
    await _client
        .from('mentorships')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', mentorshipId);
  }

  Future<Map<String, dynamic>?> fetchUserWithProfile(String authUserId) async {
    try {
      final user = await _client
          .from('users')
          .select('user_id, full_name, role, job_title, company')
          .eq('auth_user_id', authUserId)
          .maybeSingle();

      if (user == null) return null;

      final userId = user['user_id'] as String;
      final profile = await _client
          .from('profile')
          .select('profile_picture, bio')
          .eq('user_id', userId)
          .maybeSingle();

      return {
        ...user,
        'profile_picture': profile?['profile_picture'],
        'bio': profile?['bio'],
      };
    } catch (e) {
      print('❌ fetchUserWithProfile error: $e');
      return null;
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _client.from('notifications').update({'is_read': true}).match({
      'id': notificationId,
    });
  }

  // ========== POSTS SYSTEM ==========

  /// Upload media for a post
  Future<String> uploadPostMedia(String filePath) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fileName = '${DateTime.now().toIso8601String()}_${myId}.$fileExt';
    final path = '$myId/$fileName';

    try {
      // 1. Upload
      await _client.storage
          .from('post_uploads')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // 2. Get Public URL
      final url = _client.storage.from('post_uploads').getPublicUrl(path);
      return url;
    } catch (e) {
      // If error, might be compression issue or network.
      // For now, assume simpler upload.
      rethrow;
    }
  }

  /// Create a new post
  /// Create a new post and return its ID
  Future<String> createPost({
    required String description,
    required List<String> mediaUrls,
    String mediaType = 'image',
  }) async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) throw Exception('Not authenticated');

    // CRITICAL: Lookup the user's user_id from users table
    // posts.user_id references users(user_id), NOT auth.users(id)
    final userRow = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', authId)
        .single();

    final userId = userRow['user_id'] as String;

    // Insert with .select() to verify success
    final result = await _client.from('posts').insert({
      'user_id': userId,
      'description': description,
      'media_urls': mediaUrls,
      'media_type': mediaType,
    }).select();

    if (result.isEmpty) {
      throw Exception(
        'Post insert failed - RLS may have blocked the operation',
      );
    }

    return result.first['id'] as String;
  }

  /// Create an announcement (broadcast mode)
  /// Inserts into posts with content_kind='announcement', interaction_mode='broadcast'
  Future<String> createAnnouncement({
    required String userId,
    required String description,
    required List<String> mediaUrls,
  }) async {
    print('[ANNOUNCEMENT_CREATE] Starting creation for userId=$userId');

    try {
      final result = await _client.from('posts').insert({
        'user_id': userId,
        'description': description,
        'media_urls': mediaUrls,
        'media_type': 'image',
        'content_kind': 'announcement',
        'interaction_mode': 'broadcast',
      }).select();

      if (result.isEmpty) {
        print('[ANNOUNCEMENT_CREATE] ERROR: Insert returned empty result');
        throw Exception('Announcement insert failed');
      }

      print('[ANNOUNCEMENT_CREATE] Success, id=${result.first['id']}');
      return result.first['id'] as String;
    } catch (e, stack) {
      print('[ANNOUNCEMENT_CREATE] ERROR: $e');
      print(stack);
      rethrow;
    }
  }

  /// Fetch latest announcements for the home screen (Global)
  Future<List<Map<String, dynamic>>> fetchLatestAnnouncements({
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('posts')
          .select('''
            *,
            users!posts_user_id_fkey(
              full_name,
              role,
              profile:profile(profile_picture)
            )
          ''')
          .eq('content_kind', 'announcement')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('❌ fetchLatestAnnouncements error: $e');
      return [];
    }
  }

  /// Fetch announcements by a specific user
  Future<List<Map<String, dynamic>>> fetchAnnouncementsByUser(
    String userId,
  ) async {
    print('[PROFILE_ANNOUNCEMENTS_FETCH] Fetching for userId=$userId');

    try {
      final result = await _client
          .from('posts')
          .select('''
            *,
            users (
              full_name,
              username,
              role,
              major,
              profile:profile(profile_picture)
            )
          ''')
          .eq('user_id', userId)
          .eq('content_kind', 'announcement')
          .order('created_at', ascending: false);

      print(
        '[PROFILE_ANNOUNCEMENTS_FETCH] Success, found ${result.length} items',
      );
      return List<Map<String, dynamic>>.from(result);
    } catch (e, stack) {
      print('[PROFILE_ANNOUNCEMENTS_FETCH] ERROR: $e');
      print(stack);
      rethrow; // Rethrow to let UI handle it
    }
  }

  /// Fetch posts for the feed (paginated)
  Future<List<Map<String, dynamic>>> fetchPosts({
    int limit = 10,
    int offset = 0,
  }) async {
    // Join users AND profile to get the avatar
    // Note: This relies on profile table having a FK to user_id or auth_user_id.
    // Based on getFullProfile, profile.user_id FK exists.
    // users table also has user_id.
    // The relationship from posts -> users is 'posts_user_id_fkey'.
    // The relationship from users -> profile is not always auto-detected if not strict.
    // Try: nested select.

    // We select users data, AND we want profile picture.
    // Since complex nested joins can be tricky with exact FK names, we might need a workaround
    // or assume standard naming.
    // Let's try to fetch profile data via the users table if possible: users(..., profile(...))
    // IF users has a One-to-One to profile.

    // Fallback/Simpler: Just fetch posts + users. The UI uses userAvatar.
    // If we can't join profile easily, we might need to fix it later or use a different strategy.
    // But let's try the deep join:
    // select('*, users!posts_user_id_fkey(full_name, username, profile(profile_picture))')

    // If that fails, we can just use the public bucket URL logic in the UI if we know the path pattern?
    // No, path has random timestamp.

    // Let's try the join. If it errors, I'll fix it.
    final response = await _client
        .from('posts')
        .select(
          '*, users!posts_user_id_fkey(full_name, username, profile(profile_picture))',
        )
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Fetch posts by a specific user (for Profile "My Posts" tab)
  Future<List<Map<String, dynamic>>> fetchPostsByUser(
    String userId, {
    int limit = 20,
  }) async {
    final response = await _client
        .from('posts')
        .select(
          '*, users!posts_user_id_fkey(full_name, username, profile(profile_picture))',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Toggle Like on a post
  /// Returns true if liked, false if unliked (after action)
  // Cache for public user ID to reduce queries
  String? _cachedPublicUserId;
  String? _cachedAuthId; // To ensure cache belongs to current auth user

  /// Helper to get the REAL public user_id (not auth_user_id) with caching
  /// This is the SINGLE source of truth for the internal user_id.
  Future<String> _fetchPublicUserId() async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) throw Exception('Not authenticated');

    // Return cached ID only if it matches current auth user
    if (_cachedPublicUserId != null && _cachedAuthId == authId) {
      return _cachedPublicUserId!;
    }

    final userRow = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', authId)
        .maybeSingle();

    if (userRow == null) {
      throw Exception('User record not found for authId: $authId');
    }

    _cachedPublicUserId = userRow['user_id'] as String;
    _cachedAuthId = authId; // Sync cache with current auth ID

    return _cachedPublicUserId!;
  }

  /// Toggle Like on a post (Explicit Action)
  /// [wantLike] - true to like, false to unlike.
  /// Returns actual final state (true=liked, false=unliked).
  Future<bool> toggleLike(String postId, {required bool wantLike}) async {
    final userId = await _fetchPublicUserId();

    print(
      '[LIKE_ACTION] user_id=$userId post_id=$postId action=${wantLike ? 'LIKE' : 'UNLIKE'}',
    );

    try {
      if (!wantLike) {
        // UNLIKE
        await _client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

        print('[LIKE_DB_RESULT] success=true action=UNLIKE');
        // Triggers handle count
        return false;
      } else {
        // LIKE
        await _client.from('post_likes').insert({
          'post_id': postId,
          'user_id': userId,
        });

        print('[LIKE_DB_RESULT] success=true action=LIKE');
        // Triggers handle count
        return true;
      }
    } on PostgrestException catch (e) {
      // Handle known races
      if (e.code == '23505') {
        // Unique violation
        print(
          '[LIKE_DB_RESULT] error=duplicate_key action=LIKE -> treating as success',
        );
        return true;
      }
      print('[LIKE_DB_RESULT] error=${e.message} code=${e.code}');
      rethrow;
    } catch (e) {
      print('[LIKE_DB_RESULT] error=$e');
      rethrow;
    }
  }

  /// Check if current user liked a post
  Future<bool> hasLikedPost(String postId) async {
    // optimizations: use cached ID
    String userId;
    try {
      userId = await _fetchPublicUserId();
    } catch (_) {
      return false; // Not authenticated or no public profile
    }

    final count = await _client
        .from('post_likes')
        .count(CountOption.exact)
        .eq('post_id', postId)
        .eq('user_id', userId);

    return count > 0;
  }

  /// Add a comment
  Future<void> addComment(String postId, String content) async {
    final userId = await _getPublicUserId(); // Use cached helper

    print('[COMMENT_ACTION] user_id=$userId post_id=$postId');

    try {
      await _client.from('post_comments').insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
      });
      print('[COMMENT_DB_RESULT] success=true');
    } catch (e) {
      print('[COMMENT_DB_RESULT] error=$e');
      rethrow;
    }
  }

  /// Fetch comments for a post
  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final response = await _client
        .from('post_comments')
        .select('*, users!post_comments_user_id_fkey(full_name, username)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) throw Exception('Not authenticated');

    // Lookup real user_id
    final userRow = await _client
        .from('users')
        .select('user_id')
        .eq('auth_user_id', authId)
        .single();
    final userId = userRow['user_id'] as String;

    // Delete (RLS will enforce ownership)
    // We add user_id filter purely as an extra safety/sanity check
    await _client.from('posts').delete().eq('id', postId).eq('user_id', userId);
  }

  /// Check if user details are unique (for Signup)
  /// Returns a String error message if a conflict is found, or null if unique.
  Future<String?> checkUserUniqueness({
    required String username,
    required String email,
    String? institutionalId,
  }) async {
    // 1. Check Username
    final usernameRes = await _client
        .from('users')
        .select('user_id')
        .eq('username', username)
        .maybeSingle();
    if (usernameRes != null) return 'Username already taken';

    // 2. Check Email (in users table, separate from Auth)
    final emailRes = await _client
        .from('users')
        .select('user_id')
        .eq('email', email)
        .maybeSingle();
    if (emailRes != null) return 'Email already registered';

    // 3. Check Institutional ID (if provided)
    if (institutionalId != null && institutionalId.isNotEmpty) {
      final idRes = await _client
          .from('users')
          .select('user_id')
          .eq('institutional_id', institutionalId)
          .maybeSingle();
      if (idRes != null) return 'Institutional ID already registered';
    }

    return null; // All good
  }

  // --- Community Events Feature ---

  /*
    Fetch Filter Options: Batches, Schools, Majors, Programs
    Returns a Map with Lists of options.
  */
  Future<Map<String, List<String>>> fetchFilterOptions() async {
    // For now, simpler implementation:
    // - Batches: query 'yearbook_batches' or 'community_events.batch_year' distinct?
    //   User asked for "admin approved batches" for posting.
    //   For filtering, we can check existing event data OR reference data.

    // - Schools, Majors: query 'users' distinct? or static list.
    // - Program: query 'users' distinct?

    // Fetch batches from yearbook_batches (Authorized batches)
    final batchesRes = await _client
        .from('yearbook_batches')
        .select('batch_year')
        .order('batch_year', ascending: false);
    final batches = (batchesRes as List)
        .map((e) => e['batch_year'].toString())
        .toList();

    return {
      'batches': batches,
      'schools': [
        'SoEE',
        'SoMCME',
        'SoCEA',
        'SoANS',
      ], // Static or fetch distinct from users
      'programs': ['Regular', 'Extension', 'Weekend'],
    };
  }

  /*
    Fetch User Profile Data for Event Metadata.
    Returns map with graduation_year, school, major.
    Also attempts to determine program if recorded (assuming column exists or derived).
  */
  Future<Map<String, dynamic>> _fetchUserMetadata() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Note: 'program' column depends on schema. If not in users, we default to 'Regular' or null.
    // If user's table updated, add 'program'.
    // For now, we will handle potential missing column gracefully or mocking it.

    final userRes = await _client
        .from('users')
        .select('graduation_year, school, major') // Add program if it exists
        .eq('auth_user_id', userId)
        .single();

    return userRes;
  }

  /*
    Create Community Event.
    Uploads multiple media files and inserts event with user metadata.
  */
  Future<void> createCommunityEvent({
    required List<File> mediaFiles,
    required String mediaType, // 'image' or 'video'
    String? caption,
    required String category, // '100 Day', '50 Day', 'Other'
    required int batchYear, // Selected by user (must be validated ideally)
    String? program, // e.g. 'Regular'
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // 1. Upload Media Files
    List<String> uploadedUrls = [];
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < mediaFiles.length; i++) {
      final file = mediaFiles[i];
      final ext = file.path.split('.').last;
      final path = '$userId/event_${timestamp}_$i.$ext';

      await _client.storage
          .from('events_upload') // Updated bucket name
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      final url = _client.storage.from('events_upload').getPublicUrl(path);
      uploadedUrls.add(url);
    }

    // 2. Fetch User Metadata (for school/major auto-tagging)
    final userData = await _fetchUserMetadata();

    // 3. Insert Event
    await _client.from('community_events').insert({
      'user_id': userId,
      'media_urls': uploadedUrls, // Array
      'media_type': mediaType,
      'caption': caption,
      'category': category,
      'batch_year': batchYear, // User selected admin-approved batch
      'school': userData['school'],
      'major': userData['major'],
      'program': program ?? 'Regular', // Default if not provided
    });
  }

  /*
    Fetch Random Community Events.
    Returns random events for featured carousels.
  */
  Future<List<Map<String, dynamic>>> fetchRandomEvents({int limit = 5}) async {
    try {
      final res = await _client
          .from('community_events')
          .select(
            'id, caption, cover_url, category, created_at, users!inner (full_name)',
          )
          .order('random()', ascending: true)
          .limit(limit);

      return res.map((e) {
        final data = e as Map<String, dynamic>;
        final user = data['users'] as Map<String, dynamic>?;
        return {
          'id': data['id'],
          'title': data['caption'] ?? 'Event',
          'description':
              '${data['category']} • ${user?['full_name'] ?? 'Unknown'}',
          'image_url': data['cover_url'],
          'badge': data['category'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching random events: $e');
      return [];
    }
  }

  /*
    Fetch Community Events.
    Supports filtering by Category, Batch, School, Major, Program.
  */
  Future<List<Map<String, dynamic>>> fetchCommunityEvents({
    String? category,
    int? batchYear,
    String? school,
    String? major,
    String? program,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;

    // 1. Base Query - Fetch events ONLY (no joins that fail)
    // We select * because we can't join users table directly (different FK)
    var query = _client.from('community_events').select();

    if (category != null) {
      query = query.eq('category', category);
    }
    if (batchYear != null) {
      query = query.eq('batch_year', batchYear);
    }
    if (school != null) {
      query = query.eq('school', school);
    }
    if (major != null) {
      query = query.eq('major', major);
    }
    if (program != null) {
      query = query.eq('program', program);
    }

    // Apply Order last
    final res = await query.order('created_at', ascending: false);

    final List<dynamic> eventsRaw = res;

    if (eventsRaw.isEmpty) return [];

    final events = eventsRaw.cast<Map<String, dynamic>>();

    // 2. Collect all User IDs to fetch profiles in one go
    final userIds = events.map((e) => e['user_id'] as String).toSet().toList();
    final eventIds = events.map((e) => e['id'] as String).toList();

    // 3. Fetch User Profiles (Manual Join)
    Map<String, Map<String, dynamic>> userProfiles = {};
    if (userIds.isNotEmpty) {
      try {
        final usersRes = await _client
            .from('users')
            .select('auth_user_id, full_name, username, role')
            .inFilter('auth_user_id', userIds);

        for (var u in usersRes) {
          userProfiles[u['auth_user_id']] = u;
        }
      } catch (e) {
        print('Error fetching user profiles for events: $e');
        // Continue even if user fetch fails, events will just have missing names
      }
    }

    // 4. Fetch Like Counts for these events
    Map<String, int> likeCounts = {};
    if (eventIds.isNotEmpty) {
      try {
        final allLikes = await _client
            .from('community_event_likes')
            .select('event_id')
            .inFilter('event_id', eventIds);

        for (var like in allLikes) {
          final eid = like['event_id'] as String;
          likeCounts[eid] = (likeCounts[eid] ?? 0) + 1;
        }
      } catch (e) {
        print('Error fetching likes: $e');
      }
    }

    // 5. Determine 'is_liked' by current user
    Set<String> likedEventIds = {};
    if (currentUserId != null && eventIds.isNotEmpty) {
      try {
        final myLikes = await _client
            .from('community_event_likes')
            .select('event_id')
            .eq('user_id', currentUserId)
            .inFilter('event_id', eventIds);

        likedEventIds = (myLikes as List)
            .map((r) => r['event_id'] as String)
            .toSet();
      } catch (e) {
        print('Error fetching my likes: $e');
      }
    }

    // 6. Merge Data
    return events.map((event) {
      final authorId = event['user_id'] as String;
      final authorProfile = userProfiles[authorId];
      final eventId = event['id'] as String;

      return {
        ...event,
        'username': authorProfile?['username'] ?? 'Unknown',
        'user_full_name': authorProfile?['full_name'] ?? 'Unknown User',
        'like_count': likeCounts[eventId] ?? 0,
        'is_liked_by_me': likedEventIds.contains(eventId),
      };
    }).toList();
  }

  /*
    Toggle Like on Event.
  */
  Future<void> toggleEventLike(String eventId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Check if liked
    final existing = await _client
        .from('community_event_likes')
        .select()
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      // Unlike
      await _client
          .from('community_event_likes')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);
    } else {
      // Like
      await _client.from('community_event_likes').insert({
        'event_id': eventId,
        'user_id': userId,
      });
    }
  }
}
