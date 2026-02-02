import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';

// Notification Model
class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time; // Display time (e.g. "2m ago")
  final String
  iconType; // 'connection_request', 'connection_accepted', 'like', 'comment', 'system'
  final bool isRead;
  final String? referenceId; // e.g., connection request ID
  final String? relatedUserId; // For navigation
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.iconType,
    required this.createdAt,
    this.isRead = false,
    this.referenceId,
    this.relatedUserId,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    final created = DateTime.parse(map['created_at']).toLocal();
    final now = DateTime.now();
    final diff = now.difference(created);

    String timeDisplay;
    if (diff.inMinutes < 60) {
      timeDisplay = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeDisplay = '${diff.inHours}h ago';
    } else {
      timeDisplay = '${diff.inDays}d ago';
    }

    // Map DB types to Icon types
    String type = map['type'] ?? 'system';

    return NotificationItem(
      id: map['id'],
      title: map['title'] ?? 'Notification',
      description: map['description'] ?? '',
      time: timeDisplay,
      iconType: type,
      isRead: map['is_read'] ?? false,
      referenceId: map['reference_id'],
      relatedUserId: map['related_user_id'],
      createdAt: created,
    );
  }
}

class NotificationNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() async {
    return _fetchNotifications();
  }

  Future<List<NotificationItem>> _fetchNotifications() async {
    final service = ref.read(supabaseServiceProvider);
    final data = await service.fetchNotifications();
    return data.map((e) => NotificationItem.fromMap(e)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotifications());
  }

  Future<void> markAsRead(String id) async {
    final service = ref.read(supabaseServiceProvider);
    await service.markNotificationAsRead(id);

    // Optimistic update
    state = state.whenData(
      (list) => list.map((item) {
        if (item.id == id) {
          return NotificationItem(
            id: item.id,
            title: item.title,
            description: item.description,
            time: item.time,
            iconType: item.iconType,
            createdAt: item.createdAt,
            isRead: true,
            referenceId: item.referenceId,
          );
        }
        return item;
      }).toList(),
    );
  }

  Future<void> acceptConnectionRequest(
    String notificationId,
    String requestId,
  ) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.respondToConnectionRequest(requestId, 'accepted');
      await service.markNotificationAsRead(notificationId); // Auto read
      await refresh(); // Refresh to update potentially related constraints or UI
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  Future<void> denyConnectionRequest(
    String notificationId,
    String requestId,
  ) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.respondToConnectionRequest(requestId, 'denied');
      await service.markNotificationAsRead(notificationId);
      await refresh();
    } catch (e) {
      print('Error denying request: $e');
    }
  }

  Future<void> acceptMentorshipRequest(
    String notificationId,
    String mentorshipId,
  ) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.updateMentorshipStatus(mentorshipId, 'accepted');
      await service.markNotificationAsRead(notificationId);
      await refresh();
    } catch (e) {
      print('Error accepting mentorship: $e');
    }
  }

  Future<void> denyMentorshipRequest(
    String notificationId,
    String mentorshipId,
  ) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.updateMentorshipStatus(mentorshipId, 'rejected');
      await service.markNotificationAsRead(notificationId);
      await refresh();
    } catch (e) {
      print('Error denying mentorship: $e');
    }
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationItem>>(
      NotificationNotifier.new,
    );
