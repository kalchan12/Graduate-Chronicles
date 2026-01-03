import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../widgets/custom_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {'title': 'Alex liked your post', 'time': '2m ago', 'icon': 'favorite'},
      {
        'title': 'You have a new comment from Sarah',
        'time': '15m ago',
        'icon': 'chat_bubble',
      },
      {
        'title': 'Reunion reminder: CS Batch \'22',
        'time': '1h ago',
        'icon': 'groups',
      },
      {
        'title': 'New job opportunity in your network',
        'time': '3h ago',
        'icon': 'work',
      },
      {
        'title': 'Your profile was viewed by 5 people',
        'time': 'Yesterday',
        'icon': 'person',
      },
    ];

    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Notifications',
              showLeading: true,
              onLeading: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Notification tapped: ${item['title']}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1727),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: DesignSystem.purpleMid,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(item['icon']!),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['time']!,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'chat_bubble':
        return Icons.chat_bubble;
      case 'groups':
        return Icons.groups;
      case 'work':
        return Icons.work;
      case 'person':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }
}
