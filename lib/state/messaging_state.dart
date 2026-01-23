import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';

class MessagingState {
  final List<Map<String, dynamic>> conversations;
  final List<Map<String, dynamic>> currentMessages;
  final bool isLoading;

  const MessagingState({
    this.conversations = const [],
    this.currentMessages = const [],
    this.isLoading = false,
  });

  MessagingState copyWith({
    List<Map<String, dynamic>>? conversations,
    List<Map<String, dynamic>>? currentMessages,
    bool? isLoading,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MessagingNotifier extends Notifier<MessagingState> {
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  @override
  MessagingState build() {
    // Cancel subscription on dispose
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return const MessagingState();
  }

  Future<void> fetchConversations() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(supabaseServiceProvider);
      final list = await service.fetchConversations();
      state = state.copyWith(conversations: list, isLoading: false);
    } catch (e) {
      print('Fetch Conversations Error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchMessages(String conversationId) async {
    // Cancel existing subscription if any
    await _subscription?.cancel();
    _subscription = null;

    state = state.copyWith(isLoading: true, currentMessages: []);

    try {
      final service = ref.read(supabaseServiceProvider);
      _subscription = service
          .getMessagesStream(conversationId)
          .listen(
            (messages) {
              state = state.copyWith(
                currentMessages: messages,
                isLoading: false,
              );
            },
            onError: (e) {
              print('Fetch Messages Stream Error: $e');
              state = state.copyWith(isLoading: false);
            },
          );
    } catch (e) {
      print('Fetch Messages Error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.sendMessage(conversationId, content);

      // No need to fetchMessages manually, stream updates automatically

      // Update conversations list for "Last Message"
      await fetchConversations();
    } catch (e) {
      print('Send Message Error: $e');
      rethrow;
    }
  }
}

final messagingProvider = NotifierProvider<MessagingNotifier, MessagingState>(
  MessagingNotifier.new,
);
