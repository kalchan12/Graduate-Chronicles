import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/notification_state.dart';
import '../../theme/design_system.dart';
import '../profile/profile_screen.dart';

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
    final isConnectionRequest = item.iconType == 'connection_request';
    final isMentorshipRequest = item.iconType == 'mentorship_request';
    final hasRelatedUser = item.relatedUserId != null;

    void navigateToProfile() {
      if (hasRelatedUser) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: item.relatedUserId),
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Glassmorphic background
        color: item.isRead
            ? const Color(0xFF1E1E2E).withOpacity(0.4)
            : const Color(0xFF2D1F35).withOpacity(0.8),
        border: Border.all(
          color: item.isRead
              ? Colors.white.withOpacity(0.05)
              : DesignSystem.purpleAccent.withOpacity(0.5),
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: item.isRead
            ? []
            : [
                BoxShadow(
                  color: DesignSystem.purpleAccent.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasRelatedUser ? navigateToProfile : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with Badge
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: DesignSystem.purpleAccent.withOpacity(0.3),
                              width: 2,
                            ),
                            gradient: hasRelatedUser
                                ? const LinearGradient(
                                    colors: [
                                      DesignSystem.purpleAccent,
                                      Colors.blueAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF151515),
                            backgroundImage: const AssetImage(
                              'assets/images/user_placeholder.png',
                            ),
                            child: _getAvatarChild(item),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: _getIconBadge(item.iconType),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title, // Sender Name
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                item.time,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (isConnectionRequest && item.referenceId != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasRelatedUser) ...[
                          GestureDetector(
                            onTap: navigateToProfile,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_search,
                                  size: 16,
                                  color: DesignSystem.purpleAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'View Profile',
                                  style: TextStyle(
                                    color: DesignSystem.purpleAccent
                                        .withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: Colors.white30,
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.1),
                            height: 24,
                          ),
                        ],
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
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Confirm'),
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
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white70,
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                if (isMentorshipRequest && item.referenceId != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasRelatedUser) ...[
                          GestureDetector(
                            onTap: navigateToProfile,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.school, // Changed icon for mentorship
                                  size: 16,
                                  color: DesignSystem.purpleAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'View Applicant Profile',
                                  style: TextStyle(
                                    color: DesignSystem.purpleAccent
                                        .withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: Colors.white30,
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.1),
                            height: 24,
                          ),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(notificationsProvider.notifier)
                                      .acceptMentorshipRequest(
                                        item.id,
                                        item.referenceId!,
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DesignSystem.purpleAccent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Accept Mentorship'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(notificationsProvider.notifier)
                                      .denyMentorshipRequest(
                                        item.id,
                                        item.referenceId!,
                                      );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white70,
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Decline'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _getAvatarChild(NotificationItem item) {
    if (item.title.isNotEmpty) {
      return Text(
        item.title[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      );
    }
    return const Icon(Icons.person, color: Colors.white54);
  }

  Widget _getIconBadge(String type) {
    IconData icon;
    Color color;
    List<Color> gradient;

    switch (type) {
      case 'like':
        icon = Icons.favorite_rounded;
        color = Colors.pinkAccent;
        gradient = [Colors.pinkAccent, Colors.purpleAccent];
        break;
      case 'comment':
        icon = Icons.chat_bubble_rounded;
        color = Colors.blueAccent;
        gradient = [Colors.blueAccent, Colors.cyanAccent];
        break;
      case 'connection_request':
        icon = Icons.person_add_rounded;
        color = DesignSystem.purpleAccent;
        gradient = [DesignSystem.purpleAccent, Colors.deepPurpleAccent];
        break;
      case 'connection_accepted':
        icon = Icons.check_circle_rounded;
        color = Colors.greenAccent;
        gradient = [Colors.greenAccent, Colors.tealAccent];
        break;
      case 'mentorship_request':
        icon = Icons.school_rounded;
        color = Colors.orangeAccent;
        gradient = [Colors.orangeAccent, Colors.deepOrangeAccent];
        break;
      case 'mentorship_accepted':
        icon = Icons.verified_rounded;
        color = Colors.indigoAccent;
        gradient = [Colors.indigoAccent, Colors.blueAccent];
        break;
      default:
        icon = Icons.notifications_rounded;
        color = Colors.amberAccent;
        gradient = [Colors.amberAccent, Colors.orangeAccent];
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF151515), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, size: 12, color: Colors.white),
    );
  }
}
