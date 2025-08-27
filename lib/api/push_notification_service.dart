import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io' show Platform;


import '../../main.dart';


import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../model/home_page_response.dart';
import '../utility/redirect_utils.dart';
import '../utility/shared_preferences_util.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context) async {
    // Request notification permissions (especially for iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('User declined or has not accepted permission');
      return;
    }

    // Initialize local notifications
    await _initLocalNotifications();

    // // Get FCM token
    // String? token = await _firebaseMessaging.getToken();
    // debugPrint('FCM Token: $token');
    // // Save or send token to backend
    //  await SharedPreferencesUtil().saveString('fcm_token', token ?? '');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle notification click when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message, context);
    });

    // Handle notification click when app is opened from terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage, context);
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await SharedPreferencesUtil().saveString('fcm_token', newToken);
    });
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(payload));
          handleNotificationTap(data, navigatorKey.currentContext);
        }
      },
    );


    // Android 8+ channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel',
        'General Notifications',
        description: 'Used for general app notifications',
        importance: Importance.high,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      // Extract data
      final String? imageUrl = message.data['image'];
      final String body = notification.body ?? "";
      final String title = notification.title ?? "";

      // Android Style Information
      StyleInformation styleInformation;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Show big picture if image exists
        final bigPicture = await _downloadAndSaveFile(imageUrl, 'bigImage.jpg');
        styleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicture),
          contentTitle: title,
          summaryText: body,
          hideExpandedLargeIcon: true,
        );
      } else {
        // Fallback to big text
        styleInformation = BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: body,
        );
      }

      // Show notification
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'General Notifications',
            styleInformation: styleInformation,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            attachments: imageUrl != null && imageUrl.isNotEmpty
                ? [DarwinNotificationAttachment(await _downloadAndSaveFile(imageUrl, 'iosImage.jpg'))]
                : null,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';

    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final file = File(filePath);
      await file.writeAsBytes(response.data!);
      return filePath;
    } catch (e) {
      print("❌ Error downloading file: $e");
      rethrow;
    }
  }

  Future<void> handleNotificationTap(dynamic rawData, BuildContext? context) async {
    if (context == null) return;

    final token = await SharedPreferencesUtil().getString('token');
    if (token == null || token.isEmpty) {
      debugPrint('No token found. Redirect flow may require login.');
      // Optionally: Navigate to login with deep-link data preserved
      return;
    }

    // Normalize data
    final Map<String, dynamic> data;
    if (rawData is RemoteMessage) {
      data = Map<String, dynamic>.from(rawData.data);
    } else if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else {
      debugPrint('Unsupported notification payload type: ${rawData.runtimeType}');
      return;
    }

    debugPrint('Notification tapped. Data: $data');

    Map<String, dynamic> _safeMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      try {
        if (value is String) return Map<String, dynamic>.from(jsonDecode(value));
      } catch (_) {}
      return <String, dynamic>{};
    }

    final searchDataMap = _safeMap(data['redirect_search_data']);
    final productDataMap = _safeMap(data['redirect_product_data']);
    final orderDataMap = _safeMap(data['redirect_order_data']);
    final urlDataMap    = _safeMap(data['redirect_url_data']);

    final redirectData = RedirectData(
      redirectType: data['redirect_type'] ?? data['type'] ?? '',
      redirectProductData: RedirectProductData(
        productId: productDataMap['product_id'] ?? productDataMap['productId'] ?? data['product_id'] ?? data['productId'] ?? '',
        variantId: productDataMap['variant_id'] ?? productDataMap['variantId'] ?? data['variant_id'] ?? data['variantId'] ?? '',
      ),
      redirectOrderData: RedirectOrderData(
        orderId: orderDataMap['order_id'] ?? productDataMap['orderId'] ?? data['order_id'] ?? data['orderId'] ?? '',
      ),
      redirectSearchData: RedirectSearchData(
        collection: searchDataMap['collection'] ?? data['collection'] ?? '',
        category: searchDataMap['category'] ?? data['category'] ?? '',
        brand: searchDataMap['brand'] ?? data['brand'] ?? '',
        minPrice: searchDataMap['min_price']?.toString() ?? searchDataMap['minPrice']?.toString() ?? data['min_price']?.toString() ?? data['minPrice']?.toString() ?? '',
        maxPrice: searchDataMap['max_price']?.toString() ?? searchDataMap['maxPrice']?.toString() ?? data['max_price']?.toString() ?? data['maxPrice']?.toString() ?? '',
      ),
      redirectUrlData: RedirectUrlData(
        url: urlDataMap['url'] ?? data['url'] ?? '',
      ),
    );

    RedirectUtils.handleContentRedirectViewAll(
      context: context,
      redirectData: redirectData,
    );
  }




}

