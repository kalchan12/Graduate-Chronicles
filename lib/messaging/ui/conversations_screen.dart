import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/messaging_provider.dart';
import '../../theme/design_system.dart';
import '../../ui/widgets/global_background.dart';
import '../../ui/widgets/custom_app_bar.dart';
import 'chat_screen.dart';

/// Screen displaying all conversations for the current user.
///
/// Features:
/// - Pull-to-refresh
/// - Tap to open chat
/// - Shows other user's name, avatar, and last message preview
class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load conversations on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: Column(
          children: [
            // App Bar
            CustomAppBar(
              title: 'Messages',
              showLeading: true,
              onLeading: () => Navigator.of(context).pop(),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(conversationsProvider.notifier).refresh(),
                color: DesignSystem.purpleAccent,
                child: _buildContent(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ConversationsState state) {
    // Loading state
    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: DesignSystem.purpleAccent),
      );
    }

    // Error state
    if (state.error != null && state.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load conversations',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(conversationsProvider.notifier).refresh(),
              child: const Text(
                'Retry',
                style: TextStyle(color: DesignSystem.purpleAccent),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white.withValues(alpha: 0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a chat from someone\'s profile',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Conversations list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.conversations.length,
      itemBuilder: (context, index) {
        final convo = state.conversations[index];
        return _ConversationTile(
          conversation: convo,
          onTap: () => _openChat(convo),
        );
      },
    );
  }

  void _openChat(conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conversation.id,
          participantName: conversation.otherUserName ?? 'User',
          participantAvatar: conversation.otherUserAvatar,
        ),
      ),
    );
  }
}

/// Individual conversation tile widget.
class _ConversationTile extends StatelessWidget {
  final dynamic conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B141E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2B1F2E),
                border: Border.all(
                  color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
                ),
              ),
              child: ClipOval(
                child: conversation.otherUserAvatar != null
                    ? Image.network(
                        conversation.otherUserAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 28,
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white54, size: 28),
              ),
            ),
            const SizedBox(width: 14),

            // Name and message preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.otherUserName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessageContent ?? 'Start chatting...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Timestamp
            if (conversation.lastMessageTime != null)
              Text(
                _formatTime(conversation.lastMessageTime!),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
