import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_service.dart';
import 'notification_handlers.dart';

/// Top-level function for handling background messages from FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Requires: await Firebase.initializeApp(); if you use Firebase Core here.
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseService _supabaseService;

  NotificationService(this._supabaseService);

  Future<void> init() async {
    try {
      // 1. Request permissions (shows prompt on iOS, ignored or requires newer API on Android)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted push notification permission');
      } else {
        print('User declined push notification permission');
      }

      // 2. Set up background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Listen to foreground messages
      FirebaseMessaging.onMessage.listen(NotificationHandlers.handleForegroundMessage);

      // 4. Handle notification taps when app is backgrounded
      FirebaseMessaging.onMessageOpenedApp.listen(NotificationHandlers.handleMessageOpenedApp);

      // 5. Handle taps when app is fully terminated
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        // Add a slight delay to ensure first frame is rendered and navigatorKey is attached
        Future.delayed(const Duration(milliseconds: 500), () {
           NotificationHandlers.handleMessageOpenedApp(initialMessage);
        });
      }

      // 6. Push the token to your backend immediately
      await saveDeviceToken();

      // 7. Subscribe to token refreshes
      _messaging.onTokenRefresh.listen((newToken) async {
        print("FCM Token Refreshed: $newToken");
        await _updateTokenOnBackend(newToken);
      });
    } catch (e) {
      print('Warning: Notification Service failed to initialize. $e');
    }
  }

  Future<void> saveDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        print("Fetched FCM Device Token: $token");
        await _updateTokenOnBackend(token);
      }
    } catch (e) {
      print('Failed to get FCM token (is Firebase configured?): $e');
    }
  }

  Future<void> _updateTokenOnBackend(String token) async {
    try {
      final userId = await _supabaseService.getCurrentUserId();
      if (userId == null) return;
      
      // Upserts the push notification token into the new multi-device system
      await _supabaseService.client
          .from('device_tokens')
          .upsert({
            'user_id': userId,
            'fcm_token': token,
            'platform': Platform.operatingSystem,
            'last_seen': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'fcm_token');
          
      print('Successfully registered FCM token to Supabase device_tokens.');
    } catch (e) {
      print('Error saving FCM token to Supabase: $e');
    }
  }

  /// Removes the current device's FCM token. Safe to call on logout to prevent ghost notifications.
  Future<void> deleteCurrentDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token == null) return;
      
      final userId = await _supabaseService.getCurrentUserId();
      if (userId == null) return;

      await _supabaseService.client
          .from('device_tokens')
          .delete()
          .eq('fcm_token', token)
          .eq('user_id', userId);
          
      // Also tell Firebase to delete the instance ID to aggressively revoke token locally
      await _messaging.deleteToken();
      print("Successfully revoked current device FCM token.");
    } catch (e) {
      print("Error revoking device FCM token: $e");
    }
  }
}

// Global provider to easily access the notification service via Riverpod
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return NotificationService(supabaseService);
});
