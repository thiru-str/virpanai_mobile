import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../main.dart';

class AppLinkHelper {

  static final _appLinks = AppLinks();

  static Future<void> init() async {
    try {

      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
        return;
      }

      // Retry once after delay (optional)
      await Future.delayed(const Duration(milliseconds: 500));
      final retryLink = await _appLinks.getInitialLink();
      if (retryLink != null) {
        _handleLink(retryLink);
      }

    } catch (e) {
      debugPrint('❌ AppLink cold start failed: $e');
    }

    // Live stream
    _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }



  static Future<void> _handleLink(Uri uri) async {
    AppLogger.print('🔗 AppLink Received: ', '$uri');
    final token = await SharedPreferencesUtil().getString('token');
    if (token == null || token.isEmpty) return;

    if (uri.path == '/details') {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(productId: uri.queryParameters['id'] ?? '',isFromLogin: true,),
        ),
            (Route<dynamic> route) => false,
      );
    }
  }

  static Future<void> shareProductInvite(
    String productId, {
    BuildContext? context,
  }) async {
    try {

      final Uri link = Uri.parse('${AppConfig.baseUrl}products/$productId');

      final String message = 'Check out this product on ${AppConfig.appName}! 🛍️\n\n$link';

      // iOS 26+ requires a source rect for the share sheet to appear.
      Rect? origin;
      if (Platform.isIOS && context != null) {
        final size = MediaQuery.sizeOf(context);
        origin = Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 4),
          width: 1,
          height: 1,
        );
      }

      await Share.share(
        message,
        subject: 'Check out this product on ${AppConfig.appName}!',
        sharePositionOrigin: origin,
      );
    } catch (e) {
      debugPrint('❌ Failed to share product: $e');
    }
  }

}
