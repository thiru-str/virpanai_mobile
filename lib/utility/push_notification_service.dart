import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:waioz/utility/app_strings.dart';

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
      print(AppStrings.user_granted_permission);
    } else {
      print(AppStrings.user_declined_or_has_not_accepted_permission);
    }

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('${AppStrings.FCM_Token}: $token');

    // Send token to your server
    if (token != null) {
      await sendTokenToServer(token);
    }

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          '${AppStrings.received_a_message_in_the_foreground}: ${message.notification?.title}');
    });

    // Handle message interactions
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(AppStrings.notification_clicked);
    });
  }

  Future<void> sendTokenToServer(String token) async {}
}
