/// Represents a single message in a conversation.
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Check if this message was sent by the given user.
  bool isSentBy(String? userId) => senderId == userId;

  @override
  String toString() =>
      'Message(id: $id, sender: $senderId, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
}
