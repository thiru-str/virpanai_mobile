import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:waioz/ui/product_detail_page.dart';
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
      String productId,
      ) async {
    try {

      final Uri link = Uri.parse('https://virpanai.waioz.com/details?id=${productId}');

      final String message = '''
Check out this product on VirpanAI! 🛍️

I think you'll love this. Here's the link: $link
''';

      await Share.share(
        message,
        subject: 'Look what I found on GoWelMart!',
      );
    } catch (e, stack) {
      debugPrint('❌ Failed to share booking invite: $e');
      // Optionally show toast or dialog
    }
  }

}
