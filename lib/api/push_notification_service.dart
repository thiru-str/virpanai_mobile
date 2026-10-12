import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import '../../main.dart';
import 'api_service.dart';
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
    await _refreshAndSyncToken();

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
      await _persistAndSyncToken(newToken);
    });
  }

  Future<void> _refreshAndSyncToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _persistAndSyncToken(token);
      }
    } catch (error) {
      debugPrint('Unable to refresh FCM token: $error');
    }
  }

  Future<void> _persistAndSyncToken(String token) async {
    final preferences = SharedPreferencesUtil();
    await preferences.saveString('fcm_token', token);

    final authToken = await preferences.getString('token');
    if (authToken == null || authToken.isEmpty) return;

    final uploadedToken =
        await preferences.getString('fcm_token_uploaded') ?? '';
    if (uploadedToken == token) return;

    try {
      await ApiService().syncDeviceToken(token);
      await preferences.saveString('fcm_token_uploaded', token);
    } catch (error) {
      // Leave this token pending so the next launch or token refresh retries.
      debugPrint('Unable to sync FCM token with backend: $error');
    }
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

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null) {
      // Extract data
      final String? imageUrl = _getImageUrl(message);
      final String body = notification.body ?? "";
      final String title = notification.title ?? "";
      String? downloadedImagePath;

      if (imageUrl != null) {
        try {
          downloadedImagePath = await _downloadAndSaveFile(imageUrl);
        } catch (error) {
          // A bad or temporarily unavailable image must not suppress the text
          // notification.
          debugPrint('Unable to download notification image: $error');
        }
      }

      // Android Style Information
      StyleInformation styleInformation;

      if (downloadedImagePath != null) {
        // Show big picture if image exists
        styleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(downloadedImagePath),
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
      await _flutterLocalNotificationsPlugin.show(
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
            attachments: downloadedImagePath != null
                ? [DarwinNotificationAttachment(downloadedImagePath)]
                : null,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  String? _getImageUrl(RemoteMessage message) {
    final candidates = [
      message.data['image'],
      message.data['image_url'],
      message.notification?.android?.imageUrl,
      message.notification?.apple?.imageUrl,
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        final uri = Uri.tryParse(candidate.trim());
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          return uri.toString();
        }
      }
    }
    return null;
  }

  Future<String> _downloadAndSaveFile(String url) async {
    final Directory directory = await getTemporaryDirectory();

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ));
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';
      final urlExtension = Uri.parse(url).pathSegments.lastOrNull
          ?.split('.')
          .last
          .toLowerCase();
      final extension = switch (urlExtension) {
        'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' => urlExtension,
        _ when contentType.contains('png') => 'png',
        _ when contentType.contains('gif') => 'gif',
        _ when contentType.contains('webp') => 'webp',
        _ => 'jpg',
      };
      final filePath = '${directory.path}/notification_${DateTime.now().microsecondsSinceEpoch}.$extension';
      final file = File(filePath);
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Notification image response was empty');
      }
      await file.writeAsBytes(bytes, flush: true);
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
        tag: searchDataMap['tag'] ?? data['tag'] ?? '',
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
