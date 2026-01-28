import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/notification_state.dart';
import '../../theme/design_system.dart';

/*
  Notification Screen.

  Central hub for user notifications.
  Features:
  - Tabbed filtering (All, Mentions, System, Requests).
  - Rich notification cards with badges and actions.
*/
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Mark all is not yet implemented in notifier, but individual is
                        },
                        child: const Text(
                          'Mark all as read',
                          style: TextStyle(color: DesignSystem.purpleAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTab('All', true),
                        const SizedBox(width: 8),
                        _buildTab('Mentions', false),
                        const SizedBox(width: 8),
                        _buildTab('System', false),
                        const SizedBox(width: 8),
                        _buildTab('Requests', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notifications.length + 1, // +1 for padding
                      itemBuilder: (context, index) {
                        if (index == notifications.length) {
                          return const SizedBox(height: 80);
                        }
                        return _NotificationCard(item: notifications[index]);
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: DesignSystem.purpleAccent,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? DesignSystem.purpleAccent : const Color(0xFF2A1727),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final NotificationItem item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mark as read if not read (optional, can be done on tap or seen)
    // For now, let's keep it manual or implicit on action.

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isRead
            ? Colors.transparent
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: item.isRead
            ? null
            : Border.all(color: DesignSystem.purpleAccent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF3A2738),
                // We could fetch sender avatar if backend provided it.
                // For now use placeholder.
                backgroundImage: const AssetImage(
                  'assets/images/user_placeholder.png',
                ),
                child: _getAvatarChild(item),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: _getIconBadge(item.iconType),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: item.description,
                        style: const TextStyle(color: Color(0xFFD6C9E6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.time,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),

                // ACTIONS for Connection Request
                if (item.iconType == 'connection_request' &&
                    item.referenceId != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(notificationsProvider.notifier)
                                .acceptConnectionRequest(
                                  item.id,
                                  item.referenceId!,
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(notificationsProvider.notifier)
                                .denyConnectionRequest(
                                  item.id,
                                  item.referenceId!,
                                );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            foregroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text('Deny'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Follow back logic (if still relevant)
          if (item.iconType == 'follow')
            // ... (kept minimal)
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget? _getAvatarChild(NotificationItem item) {
    if (item.iconType == 'alert' ||
        item.iconType == 'system' ||
        item.iconType == 'milestone') {
      return null;
    }
    // Initials for users
    if (item.title.isNotEmpty) {
      return Text(
        item.title[0],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return null;
  }

  Widget _getIconBadge(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'like':
        icon = Icons.favorite;
        color = Colors.pinkAccent;
        break;
      case 'mention':
        icon = Icons.alternate_email;
        color = Colors.greenAccent;
        break;
      case 'comment':
        icon = Icons.chat_bubble;
        color = Colors.blueAccent;
        break;
      case 'connection_request':
        icon = Icons.person_add;
        color = DesignSystem.purpleAccent;
        break;
      case 'connection_accepted':
        icon = Icons.check_circle;
        color = Colors.greenAccent;
        break;
      case 'follow':
        icon = Icons.person_add;
        color = DesignSystem.purpleAccent;
        break;
      case 'milestone':
        icon = Icons.celebration;
        color = DesignSystem.purpleAccent;
        break;
      case 'alert':
        icon = Icons.warning;
        color = Colors.orangeAccent;
        break;
      default:
        icon = Icons.notifications;
        color = DesignSystem.purpleAccent;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: DesignSystem.scaffoldBg, width: 2),
      ),
      child: Icon(icon, size: 10, color: Colors.white),
    );
  }
}
