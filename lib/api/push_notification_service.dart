import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
    // Background messages can arrive before the rest of the app is ready.
    await _initLocalNotifications();

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      debugPrint('User declined or has not accepted notification permission');
      return;
    }

    await _refreshAndSyncToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message, context);
    });

    // Handle notification click when app is opened from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage, context);
    }

    _firebaseMessaging.onTokenRefresh.listen(_persistAndSyncToken);
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
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          final data = Map<String, dynamic>.from(jsonDecode(payload));
          handleNotificationTap(data, navigatorKey.currentContext);
        }
      },
    );

    // Android 8+ channel
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'default_channel',
            'General Notifications',
            description: 'Used for general app notifications',
            importance: Importance.high,
          ));
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    await showNotification(_flutterLocalNotificationsPlugin, message);
  }

  /// Used by both the foreground listener and Android's background isolate.
  static Future<void> showNotification(
    FlutterLocalNotificationsPlugin plugin,
    RemoteMessage message,
  ) async {
    // Server sends data-only for Android while iOS uses an APNs alert.
    final title =
        message.notification?.title ?? message.data['title'] as String? ?? '';
    final body =
        message.notification?.body ?? message.data['body'] as String? ?? '';
    if (title.isEmpty && body.isEmpty) return;

    final imageUrl = _resolveImageUrl(message);
    Uint8List? imageBytes;
    String? savedFilePath;

    if (imageUrl != null) {
      try {
        final result = await _downloadImage(imageUrl);
        imageBytes = result.$1;
        savedFilePath = result.$2;
      } catch (error) {
        debugPrint('Unable to download notification image: $error');
      }
    }

    final ByteArrayAndroidBitmap? largeIconBitmap =
        imageBytes == null ? null : ByteArrayAndroidBitmap(imageBytes);
    final StyleInformation styleInformation = largeIconBitmap == null
        ? BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: body,
          )
        : BigPictureStyleInformation(
            largeIconBitmap,
            contentTitle: title,
            summaryText: body,
            hideExpandedLargeIcon: true,
          );

    final notificationId = message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await plugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'General Notifications',
          styleInformation: styleInformation,
          largeIcon: largeIconBitmap,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          attachments: savedFilePath == null
              ? null
              : [DarwinNotificationAttachment(savedFilePath)],
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static String? _resolveImageUrl(RemoteMessage message) {
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

  // Returns bytes for Android and a file path for the iOS attachment.
  static Future<(Uint8List, String)> _downloadImage(String url) async {
    final directory = await getTemporaryDirectory();
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ));

    Exception? lastError;
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        final response = await dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final rawBytes = response.data;
        if (rawBytes == null || rawBytes.isEmpty) {
          throw StateError('Notification image response was empty');
        }
        final bytes = Uint8List.fromList(rawBytes);
        final contentType =
            response.headers.value(Headers.contentTypeHeader) ?? '';
        final pathSegments = Uri.parse(url).pathSegments;
        final fileName = pathSegments.isEmpty ? '' : pathSegments.last;
        final urlExtension = fileName.contains('.')
            ? fileName.split('.').last.toLowerCase()
            : '';
        final extension = switch (urlExtension) {
          'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' => urlExtension,
          _ when contentType.contains('png') => 'png',
          _ when contentType.contains('gif') => 'gif',
          _ when contentType.contains('webp') => 'webp',
          _ => 'jpg',
        };
        final filePath =
            '${directory.path}/notification_${DateTime.now().microsecondsSinceEpoch}.$extension';
        await File(filePath).writeAsBytes(bytes, flush: true);
        return (bytes, filePath);
      } catch (error) {
        lastError = error is Exception ? error : Exception(error.toString());
        debugPrint(
            'Notification image download attempt $attempt failed: $error');
        if (attempt < 2) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    throw lastError!;
  }

  Future<void> handleNotificationTap(
      dynamic rawData, BuildContext? context) async {
    if (context == null) return;

    final token = await SharedPreferencesUtil().getString('token');
    if (token == null || token.isEmpty) {
      debugPrint('No token found. Redirect flow may require login.');
      return;
    }

    final Map<String, dynamic> data;
    if (rawData is RemoteMessage) {
      data = Map<String, dynamic>.from(rawData.data);
    } else if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else {
      debugPrint(
          'Unsupported notification payload type: ${rawData.runtimeType}');
      return;
    }

    debugPrint('Notification tapped. Data: $data');

    Map<String, dynamic> safeMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      try {
        if (value is String) {
          return Map<String, dynamic>.from(jsonDecode(value));
        }
      } catch (_) {}
      return <String, dynamic>{};
    }

    final searchDataMap = safeMap(data['redirect_search_data']);
    final productDataMap = safeMap(data['redirect_product_data']);
    final orderDataMap = safeMap(data['redirect_order_data']);
    final urlDataMap = safeMap(data['redirect_url_data']);

    final redirectData = RedirectData(
      redirectType: data['redirect_type'] ?? data['type'] ?? '',
      redirectProductData: RedirectProductData(
        productId: productDataMap['product_id'] ??
            productDataMap['productId'] ??
            data['product_id'] ??
            data['productId'] ??
            '',
        variantId: productDataMap['variant_id'] ??
            productDataMap['variantId'] ??
            data['variant_id'] ??
            data['variantId'] ??
            '',
      ),
      redirectOrderData: RedirectOrderData(
        orderId: orderDataMap['order_id'] ??
            orderDataMap['orderId'] ??
            data['order_id'] ??
            data['orderId'] ??
            '',
      ),
      redirectSearchData: RedirectSearchData(
        collection: searchDataMap['collection'] ?? data['collection'] ?? '',
        category: searchDataMap['category'] ?? data['category'] ?? '',
        tag: searchDataMap['tag'] ?? data['tag'] ?? '',
        brand: searchDataMap['brand'] ?? data['brand'] ?? '',
        minPrice: searchDataMap['min_price']?.toString() ??
            searchDataMap['minPrice']?.toString() ??
            data['min_price']?.toString() ??
            data['minPrice']?.toString() ??
            '',
        maxPrice: searchDataMap['max_price']?.toString() ??
            searchDataMap['maxPrice']?.toString() ??
            data['max_price']?.toString() ??
            data['maxPrice']?.toString() ??
            '',
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
