import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeFCM() async {
    // Request permissions for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Send token to your server
    if (token != null) {
      await sendTokenToServer(token);
    }

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground: ${message.notification?.title}');
    });

    // Handle message interactions
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
    });
  }

  Future<void> sendTokenToServer(String token) async {

  }
}
