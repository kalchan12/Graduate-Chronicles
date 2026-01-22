// Riverpod providers and simple mock models for UI-first development.
// Import both flutter_riverpod and riverpod to ensure provider types are available.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  Data model representing a single item in the Home Feed.
  Used to display news, announcements, and updates.
*/
// Simple feed item model used by the home feed provider.
class FeedItem {
  final String id;
  final String title;
  final String subtitle;
  FeedItem({required this.id, required this.title, required this.subtitle});
}

/*
  Core user profile model.
  
  Contains personal and academic details.
  Includes a `copyWith` method to support immutable state updates.
*/
// Simple profile model used by the profile provider.
class Profile {
  final String id;
  final String name;
  final String degree;
  final String year;
  final String username;
  final String bio;
  final String? profileImage; // Local path or URL
  final String? authUserId; // Supabase Auth ID

  Profile({
    required this.id,
    required this.name,
    required this.degree,
    required this.year,
    this.username = '',
    this.bio = '',
    this.profileImage,
    this.authUserId,
  });

  Profile copyWith({
    String? name,
    String? degree,
    String? year,
    String? username,
    String? bio,
    String? profileImage,
    String? authUserId,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      degree: degree ?? this.degree,
      year: year ?? this.year,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      authUserId: authUserId ?? this.authUserId,
    );
  }
}

// ... existing code ...

// Chat Message model
class ChatMessage {
  final String id;
  final String content;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isMe,
    required this.timestamp,
  });
}

// Conversation model to support message history and list view
class Conversation {
  final String id;
  final String participantName;
  final String
  participantAvatar; // URL or local asset path handling to be done in UI
  final List<ChatMessage> messages;
  final bool isGroup;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.participantName,
    required this.participantAvatar,
    required this.messages,
    this.isGroup = false,
    this.unreadCount = 0,
  });

  String get lastMessage => messages.isNotEmpty ? messages.last.content : '';
  DateTime get lastMessageTime =>
      messages.isNotEmpty ? messages.last.timestamp : DateTime.now();

  Conversation copyWith({
    String? id,
    String? participantName,
    String? participantAvatar,
    List<ChatMessage>? messages,
    bool? isGroup,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      messages: messages ?? this.messages,
      isGroup: isGroup ?? this.isGroup,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// Notification Item model
class NotificationItem {
  final String id;
  final String title;
  final String description; // Combined text: "liked your..."
  final String time;
  final String
  iconType; // 'like', 'follow', 'alert', 'comment', 'milestone', 'mention'
  final bool isRead;
  final String? metaImage; // For thumbnails like the grad walk video

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.iconType,
    this.isRead = false,
    this.metaImage,
  });
}

// Simple batch summary model used by the batch provider.
class BatchSummary {
  final String id;
  final String title;
  final String subtitle;
  BatchSummary({required this.id, required this.title, required this.subtitle});
}

// Mock feed provider returning a list of feed items.
final feedProvider = Provider<List<FeedItem>>((ref) {
  return [
    FeedItem(
      id: '1',
      title: 'Graduation Day',
      subtitle: 'The moment we\'ve all been waiting for.',
    ),
    FeedItem(
      id: '2',
      title: 'Dean\'s List announced',
      subtitle: 'Congratulations to the top performers.',
    ),
  ];
});

// StateNotifier for managing conversations (Inbox + Chat details)
class ConversationsNotifier extends Notifier<List<Conversation>> {
  @override
  List<Conversation> build() {
    return [
      Conversation(
        id: 'c1',
        participantName: 'Sarah Jenkins',
        participantAvatar: 'assets/avatars/sarah.png', // Placeholder path
        unreadCount: 1,
        messages: [
          ChatMessage(
            id: 'm1_1',
            content: 'Hey! Are you going to the mixer tonight? 🎉',
            isMe: false,
            timestamp: DateTime.now().subtract(
              const Duration(days: 1, hours: 2),
            ),
          ),
          ChatMessage(
            id: 'm1_2',
            content: 'I think so! Just finishing up some yearbook edits.',
            isMe: true,
            timestamp: DateTime.now().subtract(
              const Duration(days: 1, hours: 1),
            ),
          ),
          ChatMessage(
            id: 'm1_3',
            content: 'Did you see the new yearbook page layout? It\'s sick! 🔥',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
        ],
      ),
      Conversation(
        id: 'c2',
        participantName: 'Graduation Committee',
        participantAvatar: 'assets/avatars/committee.png',
        messages: [
          ChatMessage(
            id: 'm2_1',
            content: 'Reminder: Photo submission deadline is tomorrow!',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      Conversation(
        id: 'c3',
        participantName: 'Mark D.',
        participantAvatar: 'assets/avatars/mark.png',
        messages: [
          ChatMessage(
            id: 'm3_1',
            content: 'You going to the mixer tonight?',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      Conversation(
        id: 'c4',
        participantName: 'Graduate Chronicles Team',
        participantAvatar: 'assets/avatars/team.png',
        messages: [
          ChatMessage(
            id: 'm4_1',
            content:
                'Welcome to your inbox! Start chatting with your batchmates.',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
      ),
    ];
  }

  void sendMessage(String conversationId, String content) {
    state = [
      for (final deepConversation in state)
        if (deepConversation.id == conversationId)
          deepConversation.copyWith(
            messages: [
              ...deepConversation.messages,
              ChatMessage(
                id: DateTime.now().toString(),
                content: content,
                isMe: true,
                timestamp: DateTime.now(),
              ),
            ],
            unreadCount: 0, // Assume we read it if we reply
          )
        else
          deepConversation,
    ];
  }

  void markAsRead(String conversationId) {
    state = [
      for (final conv in state)
        if (conv.id == conversationId) conv.copyWith(unreadCount: 0) else conv,
    ];
  }
}

/*
  Provider for managing the list of conversations.
  
  Capabilities:
  - Stores the state of all active chats
  - Handles sending new messages (updates local state)
  - Marks conversations as read
  
  Note: This is currently using in-memory mock data.
*/
final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
      ConversationsNotifier.new,
    );

// Notifications Provider
final notificationsProvider = Provider<List<NotificationItem>>((ref) {
  return [
    NotificationItem(
      id: 'n1',
      title: 'Alex Smith',
      description: 'liked your yearbook quote about "Future CEO".',
      time: '2m ago',
      iconType: 'like',
    ),
    NotificationItem(
      id: 'n2',
      title: 'CS Club',
      description: 'started following you.',
      time: '15m ago',
      iconType: 'follow',
    ),
    NotificationItem(
      id: 'n3',
      title: 'Don\'t forget!',
      description: 'Yearbook quote submissions close in 2 days.',
      time: '5h ago',
      iconType: 'alert',
    ),
    NotificationItem(
      id: 'n4',
      title: 'Sarah J.',
      description:
          'commented: "Love this memory! 🎓" on your Graduation Walk video.',
      time: '1d ago',
      iconType: 'comment',
      metaImage: 'grad_walk_thumb.jpg',
    ),
    NotificationItem(
      id: 'n5',
      title: 'Milestone Reached!',
      description: 'Your profile just hit 100 views.',
      time: '2d ago',
      iconType: 'milestone',
    ),
    NotificationItem(
      id: 'n6',
      title: 'Michael Chen',
      description:
          'mentioned you in a post: "Big thanks to @You for the help studying!"',
      time: '3d ago',
      iconType: 'mention',
    ),
  ];
});

// Mock batch summaries provider.
final batchProvider = Provider<List<BatchSummary>>((ref) {
  return [
    BatchSummary(
      id: 'b1',
      title: 'Batch of \u201824',
      subtitle: 'Highlights and memories.',
    ),
    BatchSummary(
      id: 'b2',
      title: 'Alumni Spotlight',
      subtitle: 'Where are they now?',
    ),
  ];
});

// Directory/provider list used by the batch/directory screen (mock profiles).
final directoryProvider = Provider<List<Profile>>((ref) {
  return [
    Profile(
      id: 'p1',
      name: 'Jordan Lee',
      degree: 'Computer Science',
      year: '2024',
    ),
    Profile(
      id: 'p2',
      name: 'Priya Sharma',
      degree: 'Business Administration',
      year: 'Alumni',
    ),
    Profile(
      id: 'p3',
      name: 'Alex Chen',
      degree: 'Graphic Design',
      year: '2025',
    ),
    Profile(
      id: 'p4',
      name: 'Maria Rodriguez',
      degree: 'Engineering',
      year: '2024',
    ),
    Profile(
      id: 'p5',
      name: 'Kenji Tanaka',
      degree: 'Marketing',
      year: 'Alumni',
    ),
    Profile(id: 'p6', name: 'Fatima Al-Sayed', degree: 'Biology', year: '2026'),
  ];
});
