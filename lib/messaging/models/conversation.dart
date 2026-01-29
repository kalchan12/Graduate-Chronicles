/// Represents a conversation between two users.
class Conversation {
  final String id;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  // Populated via join
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? lastMessageContent;
  final DateTime? lastMessageTime;

  const Conversation({
    required this.id,
    required this.createdAt,
    required this.lastMessageAt,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.lastMessageContent,
    this.lastMessageTime,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastMessageAt: DateTime.parse(map['last_message_at'] as String),
      otherUserId: map['other_user_id'] as String?,
      otherUserName: map['other_user_name'] as String?,
      otherUserAvatar: map['other_user_avatar'] as String?,
      lastMessageContent: map['last_message_content'] as String?,
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.parse(map['last_message_time'] as String)
          : null,
    );
  }

  @override
  String toString() => 'Conversation(id: $id, otherUser: $otherUserName)';
}
