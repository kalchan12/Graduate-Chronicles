import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/design_system.dart';

/*
  Notification Screen.

  Central hub for user notifications.
  Features:
  - Tabbed filtering (All, Mentions, System, Requests).
  - Chronological grouping (New vs Earlier).
  - Rich notification cards with badges and actions.
*/
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    // Simple grouping logic based on string (Mock)
    final newNotifications = notifications
        .where((n) => n.time.contains('m ago'))
        .toList();
    final earlierNotifications = notifications
        .where((n) => !n.time.contains('m ago'))
        .toList();

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
                        onPressed: () {},
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (newNotifications.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...newNotifications.map((n) => _NotificationCard(item: n)),
                  ],

                  if (earlierNotifications.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'EARLIER',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...earlierNotifications.map(
                      (n) => _NotificationCard(item: n),
                    ),
                  ],
                  const SizedBox(height: 80), // Bottom padding
                ],
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

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF3A2738),
                backgroundImage:
                    item.iconType == 'like' || item.iconType == 'mention'
                    ? const AssetImage('assets/images/user_placeholder.png')
                    : null, // Mock logic
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
              ],
            ),
          ),
          if (item.iconType == 'follow')
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF32113F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Follow Back',
                  style: TextStyle(
                    color: DesignSystem.purpleAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (item.metaImage != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                width: 48,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.image,
                  size: 16,
                  color: Colors.white54,
                ), // Placeholder
              ),
            ),
        ],
      ),
    );
  }

  Widget? _getAvatarChild(NotificationItem item) {
    if (item.iconType == 'alert' ||
        item.iconType == 'system' ||
        item.iconType == 'milestone') {
      return null; // Will use icon badge or similar mainly
    }
    // Initials for users
    return Text(
      item.title[0],
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
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

    if (type == 'milestone' || type == 'alert') {
      // For these types the main avatar IS the icon usually, but let's stick to badge style or update main avatar.
      // Design uses main large icon for Alert/Milestone.
      // Let's keep it simple with badge.
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
