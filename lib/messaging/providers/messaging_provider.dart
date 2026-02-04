import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/messaging_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SERVICE PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

/// Provides the MessagingService singleton.
final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService(Supabase.instance.client);
});

// ═══════════════════════════════════════════════════════════════════════════
// CONVERSATION PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// State for the conversations list.
class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing conversations state.
class ConversationsNotifier extends Notifier<ConversationsState> {
  @override
  ConversationsState build() {
    return const ConversationsState();
  }

  MessagingService get _service => ref.read(messagingServiceProvider);

  /// Load all conversations for the current user.
  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final convos = await _service.fetchConversations();
      state = state.copyWith(conversations: convos, isLoading: false);
      // Refresh unread count whenever conversations are re-fetched
      ref.invalidate(unreadMessageCountProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh conversations (pull-to-refresh).
  Future<void> refresh() => loadConversations();

  /// Get or create a conversation with a target user.
  Future<String> startConversation(String targetUserId) async {
    final convoId = await _service.getOrCreateConversation(targetUserId);

    // Refresh list to include new conversation
    await loadConversations();
    // Force refresh of unread count
    ref.invalidate(unreadMessageCountProvider);

    return convoId;
  }
}

/// Provider for conversations state.
final conversationsProvider =
    NotifierProvider<ConversationsNotifier, ConversationsState>(() {
      return ConversationsNotifier();
    });

// ═══════════════════════════════════════════════════════════════════════════
// MESSAGE PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Stream provider for real-time messages in a specific conversation.
///
/// Usage: ref.watch(messagesStreamProvider(conversationId))
final messagesStreamProvider = StreamProvider.family<List<Message>, String>((
  ref,
  conversationId,
) {
  final service = ref.read(messagingServiceProvider);
  return service.getMessagesStream(conversationId);
});

/// Provider for sending messages.
///
/// Usage: ref.read(sendMessageProvider(SendMessageParams(convoId, content)))
final sendMessageProvider = FutureProvider.family<void, SendMessageParams>((
  ref,
  params,
) async {
  final service = ref.read(messagingServiceProvider);
  await service.sendMessage(params.conversationId, params.content);
});

/// Parameters for sending a message.
class SendMessageParams {
  final String conversationId;
  final String content;

  const SendMessageParams(this.conversationId, this.content);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendMessageParams &&
          conversationId == other.conversationId &&
          content == other.content;

  @override
  int get hashCode => conversationId.hashCode ^ content.hashCode;
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider for getting the current user's auth ID.
final currentAuthUserIdProvider = Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
});

/// Provider for total unread message count.
/// Refreshes when invalidated.
final unreadMessageCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(messagingServiceProvider);
  return service.getUnreadCount();
});
