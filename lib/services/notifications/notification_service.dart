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
      
      // Updates the profile with the push notification token
      await _supabaseService.client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('user_id', userId);
          
      print('Successfully registered FCM token to Supabase Profiles.');
    } catch (e) {
      print('Error saving FCM token to Supabase: $e');
    }
  }
}

// Global provider to easily access the notification service via Riverpod
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return NotificationService(supabaseService);
});
