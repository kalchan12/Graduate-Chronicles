import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/design_system.dart';
import 'message_detail_screen.dart';

/*
  Messages List Screen.
  
  Shows all active conversations and active users.
  Features:
  - "Active Now" horizontal list (stories style)
  - Recent conversations list with unread counts
  - Search bar for finding classmates
*/
class MessageListScreen extends ConsumerWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch conversations from the new NotifierProvider
    final conversations = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header with App Bar and Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A1727),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.filter_list,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: DesignSystem.purpleAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1727),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white54),
                        const SizedBox(width: 12),
                        Text(
                          'Search classmates...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  const SizedBox(height: 12),
                  // ACTIVE NOW Section
                  const Text(
                    'ACTIVE NOW',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Active Users List
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final names = [
                          'My Story',
                          'Sarah',
                          'Mike',
                          'Jen',
                          'Alex',
                          'Sam',
                        ];
                        final isStory = index == 0;
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: isStory
                                        ? Border.all(
                                            color: Colors.white24,
                                            width: 2,
                                            style: BorderStyle.solid,
                                          )
                                        : Border.all(
                                            color: DesignSystem.purpleAccent,
                                            width: 2,
                                          ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: CircleAvatar(
                                      backgroundColor: const Color(0xFF3A2738),
                                      child: isStory
                                          ? const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            )
                                          : const Icon(
                                              Icons.person,
                                              color: Colors.white70,
                                            ),
                                    ),
                                  ),
                                ),
                                if (!isStory)
                                  Positioned(
                                    bottom: 0,
                                    right: 2,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: DesignSystem.scaffoldBg,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              names[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Conversation List
                  ...conversations.map((conversation) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageDetailScreen(
                                conversationId: conversation.id,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFF3A2738),
                                  child: Text(
                                    conversation.participantName.isNotEmpty
                                        ? conversation.participantName[0]
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                if (conversation.unreadCount > 0)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: DesignSystem.scaffoldBg,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        conversation.participantName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              conversation.unreadCount > 0
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _formatTime(
                                          conversation.lastMessageTime,
                                        ),
                                        style: TextStyle(
                                          color: conversation.unreadCount > 0
                                              ? DesignSystem.purpleAccent
                                              : Colors.white54,
                                          fontSize: 12,
                                          fontWeight:
                                              conversation.unreadCount > 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conversation.lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: conversation.unreadCount > 0
                                                ? Colors.white
                                                : Colors.white54,
                                            fontSize: 14,
                                            fontWeight:
                                                conversation.unreadCount > 0
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (conversation.unreadCount > 0)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          width: 22,
                                          height: 22,
                                          decoration: const BoxDecoration(
                                            color: DesignSystem.purpleAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${conversation.unreadCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
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
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 2) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '1w';
  }
}
