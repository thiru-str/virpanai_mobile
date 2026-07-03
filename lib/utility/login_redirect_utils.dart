import 'package:flutter/material.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/widgets/search_address.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

class LoginRedirectUtils {
  LoginRedirectUtils._();

  static Future<void> redirectAfterLogin(
    BuildContext context, {
    Widget? redirectPage,
  }) async {
    final selectedAddress =
        await SharedPreferencesUtil().getMap('selected_address');
    final targetPage = redirectPage ?? const BottomNavPage();

    if (selectedAddress == null) {
      PageRouteUtils.pushAndRemoveUntil(
        context,
        SearchAddressPage(
          isMandatory: true,
          redirectPage: targetPage,
        ),
      );
      return;
    }

    PageRouteUtils.pushAndRemoveUntil(context, targetPage);
  }
}
