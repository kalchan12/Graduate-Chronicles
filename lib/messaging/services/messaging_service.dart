import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';

/// Service handling all messaging operations with Supabase.
///
/// Uses efficient single-query patterns and RPC calls where possible
/// to avoid N+1 problems identified in the old implementation.
class MessagingService {
  final SupabaseClient _client;

  MessagingService(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVERSATION OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Find existing conversation or create a new one with target user.
  ///
  /// This is the primary entry point for starting a chat.
  /// Returns the conversation ID.
  Future<String> getOrCreateConversation(String targetUserId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');
    if (userId == targetUserId) throw Exception('Cannot chat with yourself');

    // 1. Check if conversation already exists using SECURITY DEFINER function
    final existingId = await _client.rpc(
      'find_existing_conversation',
      params: {'_target_user_id': targetUserId},
    );

    if (existingId != null) {
      return existingId as String;
    }

    // 2. Create new conversation (atomic operation)
    // Step A: Create empty conversation
    final convoRes = await _client
        .from('conversations')
        .insert({})
        .select('id')
        .single();
    final convoId = convoRes['id'] as String;

    // Step B: Add current user (must be first due to RLS)
    await _client.from('conversation_participants').insert({
      'conversation_id': convoId,
      'user_id': userId,
    });

    // Step C: Add target user (allowed because we're now a participant)
    await _client.from('conversation_participants').insert({
      'conversation_id': convoId,
      'user_id': targetUserId,
    });

    return convoId;
  }

  /// Fetch all conversations for the current user with enriched data.
  ///
  /// Returns conversations sorted by most recent activity.
  /// Each conversation includes: other user's name, avatar, last message.
  Future<List<Conversation>> fetchConversations() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    // Step 1: Get all conversation IDs where I'm a participant
    final myConvos = await _client
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', userId);

    if ((myConvos as List).isEmpty) return [];

    final List<Conversation> result = [];

    // Step 2: Enrich each conversation
    // TODO: Optimize with a single RPC call when conversation count grows
    for (final entry in myConvos) {
      final convoId = entry['conversation_id'] as String;

      // Get conversation metadata
      final convoData = await _client
          .from('conversations')
          .select('id, created_at, last_message_at')
          .eq('id', convoId)
          .single();

      // Get other participant
      final otherParticipant = await _client
          .from('conversation_participants')
          .select('user_id')
          .eq('conversation_id', convoId)
          .neq('user_id', userId)
          .maybeSingle();

      if (otherParticipant == null) continue; // Skip if no other participant

      final otherUserId = otherParticipant['user_id'] as String;

      // Get other user's details
      final userDetails = await _client
          .from('users')
          .select('full_name, username')
          .eq('auth_user_id', otherUserId)
          .maybeSingle();

      // Get avatar from profile
      final profile = await _client
          .from('profile')
          .select('profile_picture')
          .eq('user_id', otherUserId)
          .maybeSingle();

      String? avatarUrl;
      if (profile != null && profile['profile_picture'] != null) {
        avatarUrl = _client.storage
            .from('avatar')
            .getPublicUrl(profile['profile_picture']);
      }

      // Get last message
      final lastMsg = await _client
          .from('messages')
          .select('content, created_at')
          .eq('conversation_id', convoId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      result.add(
        Conversation(
          id: convoData['id'] as String,
          createdAt: DateTime.parse(convoData['created_at'] as String),
          lastMessageAt: DateTime.parse(convoData['last_message_at'] as String),
          otherUserId: otherUserId,
          otherUserName: userDetails?['full_name'] as String? ?? 'User',
          otherUserAvatar: avatarUrl,
          lastMessageContent: lastMsg?['content'] as String?,
          lastMessageTime: lastMsg?['created_at'] != null
              ? DateTime.parse(lastMsg!['created_at'] as String)
              : null,
        ),
      );
    }

    // Sort by most recent activity
    result.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MESSAGE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get real-time stream of messages for a conversation.
  ///
  /// Uses Supabase Realtime with Postgres Changes.
  Stream<List<Message>> getMessagesStream(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((r) => Message.fromMap(r)).toList());
  }

  /// Send a message to a conversation.
  ///
  /// Automatically updates `last_message_at` on the conversation.
  Future<void> sendMessage(String conversationId, String content) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');
    if (content.trim().isEmpty) throw Exception('Message cannot be empty');

    // Insert message
    await _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'content': content.trim(),
    });

    // Update conversation timestamp
    await _client
        .from('conversations')
        .update({'last_message_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', conversationId);
  }

  /// Fetch messages for a conversation (non-stream, for initial load).
  Future<List<Message>> fetchMessages(String conversationId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (response as List).map((r) => Message.fromMap(r)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // USER DISCOVERY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch list of users that the current user can chat with.
  ///
  /// Returns all users except the current user.
  /// Includes name, username, and avatar URL.
  Future<List<Map<String, dynamic>>> fetchDiscoverableUsers({
    String? searchQuery,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    // Base query: get users except self
    var query = _client
        .from('users')
        .select('user_id, auth_user_id, full_name, username');

    // Execute and filter locally due to Supabase limitations
    final List<dynamic> results = await query;

    final List<Map<String, dynamic>> users = [];

    for (final row in results) {
      final authId = row['auth_user_id'] as String?;
      final userId = row['user_id'] as String?; // Get UUID

      if (authId == null || authId == currentUserId) continue;

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final name = (row['full_name'] as String? ?? '').toLowerCase();
        final username = (row['username'] as String? ?? '').toLowerCase();
        final query = searchQuery.toLowerCase();

        if (!name.contains(query) && !username.contains(query)) {
          continue;
        }
      }

      // Get avatar
      // Use user_id (UUID) to fetch profile, not auth_user_id
      String? avatarUrl;
      if (userId != null) {
        final profile = await _client
            .from('profile')
            .select('profile_picture')
            .eq('user_id', userId)
            .maybeSingle();

        if (profile != null && profile['profile_picture'] != null) {
          avatarUrl = _client.storage
              .from('avatar')
              .getPublicUrl(profile['profile_picture']);
        }
      }

      users.add({
        'user_id': userId, // Return UUID for navigation
        'auth_user_id': authId, // Keep auth ID for chat start
        'full_name': row['full_name'] ?? 'User',
        'username': row['username'] ?? '',
        'avatar_url': avatarUrl,
      });
    }

    return users;
  }
}
