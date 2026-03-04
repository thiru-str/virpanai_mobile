import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/public_detail_model.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_link_helper.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../ui/splash_page.dart';
import 'package:flutter/material.dart';

import 'api/api_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set Stripe publishable key
  Stripe.publishableKey = AppConfig.publishableKeyStripe;

  final prefs = SharedPreferencesUtil();
  final String currencySymbol = await prefs.getString('currency_symbol') ?? '₹';

  // Initialize the currency symbol cache
  await CurrencyUtil.initializeCurrencySymbol(currencySymbol);

  await Firebase.initializeApp();

  // Render immediately using cached config (if present), then refresh in background.
  final PublicDetailsResponse? cachedPublicDetails =
      await SharedPreferencesUtil().getPublicDetails();
  _applyThemeFromPublicDetails(cachedPublicDetails);
  final bool skipLogin = await prefs.getBool('skip_login') ??
      (cachedPublicDetails?.storeDetails?.storeMetadata?.skipLogin ?? false);

  runApp(
    HomeScreen(
      skipLogin: skipLogin,
      publicDetailsResponse: cachedPublicDetails,
    ),
  );

  unawaited(_bootstrapPublicDetails());
  Future.delayed(Duration.zero, () {
    AppLinkHelper.init();
  });
}

Future<void> _bootstrapPublicDetails() async {
  try {
    final PublicDetailsResponse publicDetailsResponse =
        await ApiService().getPublicDetails();
    await _savePublicDetailsToPrefs(publicDetailsResponse);
    _applyThemeFromPublicDetails(publicDetailsResponse);
  } catch (e) {
    debugPrint('public/details bootstrap failed: $e');
  }
}

Future<void> _savePublicDetailsToPrefs(PublicDetailsResponse details) async {
  final prefs = SharedPreferencesUtil();
  await prefs.saveMap('public_details', details.toJson());
  await prefs.saveString('publishable_key', details.token ?? '');
  await prefs.saveBool('google_map_usage', false);
  await prefs.saveString('app_header', details.theme?.header ?? '');
  await prefs.saveString('product_view', details.theme?.productView ?? '');
  await prefs.saveString(
      'invoice_url', details.storeDetails?.storeMetadata?.invoiceUrl ?? '');
  final bool skipLogin =
      details.storeDetails?.storeMetadata?.skipLogin ?? false;
  await prefs.saveBool('skip_login', skipLogin);
  await prefs.saveBool(
      'email_login', ((details.storeDetails?.loginType ?? '') == 'email'));
}

void _applyThemeFromPublicDetails(PublicDetailsResponse? details) {
  if (details == null) return;

  FontUtils.updateFonts(
    primaryFont: details.theme?.titleFont ?? FontUtils.defaultCircularStd,
    secondaryFont: details.theme?.contentFont ?? FontUtils.defaultGabarito,
  );

  final Color apiPrimaryColor =
      AppUtils.parseHexColor(details.theme?.primaryColor) ?? AppColors.primary;
  final Color apiSecondaryColor =
      AppUtils.parseHexColor(details.theme?.secondaryColor) ??
          AppColors.secondary;

  AppColors.updateColors(
    newPrimary: apiPrimaryColor,
    newSecondary: apiSecondaryColor,
  );
}

class HomeScreen extends StatelessWidget {
  final bool skipLogin;
  final PublicDetailsResponse? publicDetailsResponse;
  HomeScreen({super.key, this.skipLogin = false, this.publicDetailsResponse});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: SplashPage(
        skipLogin: skipLogin,
        publicDetailsResponse: publicDetailsResponse,
      ),
    );
  }

  ThemeData theme = ThemeData(
    textTheme: TextTheme(
      displayLarge: FontUtils.primaryFontStyle(
          fontWeight: FontWeight.w800, fontSize: 14.0),
      displayMedium: FontUtils.secondaryFontStyle(
          fontWeight: FontWeight.w500, fontSize: 14.0),
      displaySmall: FontUtils.primaryFontStyle(
          fontWeight: FontWeight.w400, fontSize: 24.0),
    ),
  );
}
