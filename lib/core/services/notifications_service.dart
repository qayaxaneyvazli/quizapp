import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/notifications/notifications_provider.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
 

class NotificationsService {
  final Ref _ref;
  
  NotificationsService(this._ref);
  
  // Call this function when you're ready to set up Firebase notifications
  Future<void> initializeNotifications() async {
    // Check if notifications are enabled in app settings
    final isNotificationsEnabled = _ref.read(notificationsEnabledProvider);
    
    // When Firebase is ready, uncomment and implement these:
    /*
    // Request permission
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      // Configure Firebase message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      // Get FCM token
      final token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      
      // Subscribe to topics based on user preferences
      if (isNotificationsEnabled) {
        await FirebaseMessaging.instance.subscribeToTopic('all');
        await FirebaseMessaging.instance.subscribeToTopic('daily_quiz');
      }
    }
    */
  }
  
  // Handle foreground messages
  void _handleForegroundMessage(/*RemoteMessage message*/) {
    // Show a local notification or dialog when message arrives in foreground
    print('Got a message whilst in the foreground!');
    // print('Message data: ${message.data}');
    
    // if (message.notification != null) {
    //   print('Message also contained a notification: ${message.notification}');
    // }
  }
  
  // Handle when user taps on a notification to open the app
  void _handleMessageOpenedApp(/*RemoteMessage message*/) {
    // Navigate to a specific screen based on the notification
    print('A notification was tapped!');
    // print('Message data: ${message.data}');
    
    // Example: navigate to a specific quiz if notification includes quiz_id
    // if (message.data.containsKey('quiz_id')) {
    //   // Navigate to the quiz screen
    // }
  }
  
  // Call this when notification settings change
  Future<void> updateNotificationSubscriptions(bool isEnabled) async {
    // When Firebase is ready, implement these:
    /*
    if (isEnabled) {
      await FirebaseMessaging.instance.subscribeToTopic('all');
      await FirebaseMessaging.instance.subscribeToTopic('daily_quiz');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('all');
      await FirebaseMessaging.instance.unsubscribeFromTopic('daily_quiz');
    }
    */
  }
}

// Provider for the notifications service
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(ref);
});