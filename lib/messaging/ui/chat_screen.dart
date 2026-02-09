import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/messaging_provider.dart';
import '../models/message.dart';
import '../../theme/design_system.dart';
import '../../ui/widgets/global_background.dart';
import '../../ui/profile/profile_screen.dart';

/// Real-time chat screen for a specific conversation.
///
/// Features:
/// - Real-time message updates via Supabase Realtime
/// - Auto-scroll to latest message
/// - Message input with send button
/// - Visual distinction between sent and received messages
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String participantName;
  final String? participantAvatar;
  final String? otherUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatar,
    this.otherUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Mark conversation as read when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(messagingServiceProvider);
      service.markConversationRead(widget.conversationId);
      // Invalidate unread count to refresh badge
      ref.invalidate(unreadMessageCountProvider);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final service = ref.read(messagingServiceProvider);
      await service.sendMessage(widget.conversationId, content);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: ${e.toString()}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesStreamProvider(widget.conversationId),
    );
    final currentUserId = ref.watch(currentAuthUserIdProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Messages
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  // Auto-scroll when new messages arrive
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                  return _buildMessageList(messages, currentUserId);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: DesignSystem.purpleAccent,
                  ),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[300],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load messages',
                        style: TextStyle(
                          color: DesignSystem.textSubtle(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.shadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: DesignSystem.textPrimary(context),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Clickable Profile Info
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.otherUserId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(userId: widget.otherUserId),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: DesignSystem.purpleAccent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DesignSystem.purpleAccent.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: widget.participantAvatar != null
                          ? Image.network(
                              widget.participantAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                color: DesignSystem.textSubtle(context),
                                size: 24,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: DesignSystem.textSubtle(context),
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.participantName,
                          style: TextStyle(
                            color: DesignSystem.textPrimary(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Removed online status indicator as it was hardcoded false positive
                        // TODO: Implement real presence
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages, String? currentUserId) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DesignSystem.purpleAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.waving_hand_rounded,
                color: DesignSystem.purpleAccent.withValues(alpha: 0.8),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Say Hello!',
              style: TextStyle(
                color: DesignSystem.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation with ${widget.participantName}',
              style: TextStyle(
                color: DesignSystem.textSubtle(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.isSentBy(currentUserId);

        // Show timestamp only if time gap > 5 mins or it's the first message
        bool showTime = false;
        if (index == 0) {
          showTime = true;
        } else {
          final prevMessage = messages[index - 1];
          final diff = message.createdAt.difference(prevMessage.createdAt);
          if (diff.inMinutes > 5) showTime = true;
        }

        return Column(
          children: [
            if (showTime)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _formatDate(message.createdAt),
                  style: TextStyle(
                    color: DesignSystem.textSubtle(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            _MessageBubble(message: message, isMe: isMe),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF120815).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment Button (Mock)
          Container(
            height: 48,
            width: 48,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.add_rounded,
              color: DesignSystem.textSubtle(context),
              size: 24,
            ),
          ),

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        color: DesignSystem.textPrimary(context),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(
                          color: DesignSystem.textSubtle(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [DesignSystem.purpleAccent, const Color(0xFFB030D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual message bubble widget.
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4), // Tighter grouping
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isMe
                ? LinearGradient(
                    colors: [
                      DesignSystem.purpleAccent,
                      const Color(0xFF9C27B0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isMe
                ? null
                // Dark curved bubble for others
                : const Color(0xFF2E2333),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 20),
            ),
            boxShadow: [
              if (isMe)
                BoxShadow(
                  color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all_rounded, // Read receipt mock
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
