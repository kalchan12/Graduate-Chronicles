import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

enum NotificationType {
  message,
  connectionRequest,
  announcement,
  unknown;

  static NotificationType fromString(String? type) {
    switch (type) {
      case 'message':
        return NotificationType.message;
      case 'connection_request':
        return NotificationType.connectionRequest;
      case 'announcement':
        return NotificationType.announcement;
      default:
        return NotificationType.unknown;
    }
  }
}

class NotificationHandlers {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Handles incoming messages when the app is in the foreground.
  static void handleForegroundMessage(RemoteMessage message) {
    print('Got a notification whilst in the foreground!');
    if (message.notification != null) {
      print('Notification body: ${message.notification?.body}');
      
      // If we have a context, we can display a local snackbar or dialog to not interrupt
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification?.title ?? "New Notification"),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'View', onPressed: () {
               handleMessageOpenedApp(message);
            }),
          )
        );
      }
    }
  }

  /// Handles when a user taps on a notification to open the app.
  static void handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.data}');
    final typeStr = message.data['type'] as String?;
    final type = NotificationType.fromString(typeStr);

    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case NotificationType.message:
        final senderId = message.data['sender_id'];
        if (senderId != null) {
          // Navigator.pushNamed(context, '/messages', arguments: senderId);
          print("Navigate to messages: $senderId");
        }
        break;
      case NotificationType.connectionRequest:
        // Navigator.pushNamed(context, '/network');
        print("Navigate to connections");
        break;
      case NotificationType.announcement:
        // Navigator.pushNamed(context, '/notifications');
        print("Navigate to announcements");
        break;
      case NotificationType.unknown:
        print('Unknown notification tapped');
        break;
    }
  }
}
