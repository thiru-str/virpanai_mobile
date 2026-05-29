import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:newrelic_mobile/config.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:newrelic_mobile/newrelic_navigation_observer.dart';
import 'package:waioz/model/public_detail_model.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_error_reporter.dart';
import 'package:waioz/utility/app_link_helper.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/extensions_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../ui/splash_page.dart';
import 'package:flutter/material.dart';

import 'api/api_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppErrorReporter.instance.installGlobalHandlers();

    // Lock orientation to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set Stripe publishable key
    Stripe.publishableKey = AppConfig.publishableKeyStripe;

    final prefs = SharedPreferencesUtil();
    final String currencySymbol =
        await prefs.getString('currency_symbol') ?? '₹';

    // Initialize the currency symbol cache
    await CurrencyUtil.initializeCurrencySymbol(currencySymbol);

    await Firebase.initializeApp();

    // Render immediately using cached config (if present), then refresh in background.
    final PublicDetailsResponse? cachedPublicDetails =
        await SharedPreferencesUtil().getPublicDetails();
    await ExtensionsUtil.refresh();
    _applyThemeFromPublicDetails(cachedPublicDetails);
    final bool skipLogin = await prefs.getBool('skip_login') ??
        (cachedPublicDetails?.storeDetails?.storeMetadata?.skipLogin ?? false);

    final homeScreen = HomeScreen(
      skipLogin: skipLogin,
      publicDetailsResponse: cachedPublicDetails,
    );

    await _runAppWithOptionalNewRelic(homeScreen);
    await AppErrorReporter.instance.initialize();

    unawaited(_bootstrapPublicDetails());
    Future.delayed(Duration.zero, () {
      AppLinkHelper.init();
    });
  }, (Object error, StackTrace stackTrace) {
    AppErrorReporter.instance.recordFatal(
      error,
      stackTrace,
      reason: 'runZonedGuarded uncaught error',
    );
  });
}

Future<void> _runAppWithOptionalNewRelic(HomeScreen homeScreen) async {
  if (!AppConfig.isNewRelicEnabled) {
    runApp(homeScreen);
    return;
  }

  final config = Config(
    accessToken: AppConfig.newRelicAppToken,
    analyticsEventEnabled: true,
    networkErrorRequestEnabled: true,
    networkRequestEnabled: true,
    crashReportingEnabled: true,
    interactionTracingEnabled: true,
    httpResponseBodyCaptureEnabled: true,
    loggingEnabled: kDebugMode,
    webViewInstrumentation: true,
    printStatementAsEventsEnabled: kDebugMode,
    httpInstrumentationEnabled: true,
    offlineStorageEnabled: true,
    backgroundReportingEnabled: false,
    newEventSystemEnabled: false,
    distributedTracingEnabled: true,
  );

  await NewrelicMobile.instance.start(config, () {
    runApp(homeScreen);
  });
}

Future<void> _bootstrapPublicDetails() async {
  try {
    final PublicDetailsResponse publicDetailsResponse =
        await ApiService().getPublicDetails();
    await _savePublicDetailsToPrefs(publicDetailsResponse);
    await ExtensionsUtil.refresh();
    _applyThemeFromPublicDetails(publicDetailsResponse);
  } catch (e) {
    AppErrorReporter.instance.recordHandled(
      e,
      StackTrace.current,
      reason: 'public/details bootstrap failed',
    );
    debugPrint('public/details bootstrap failed: $e');
  }
}

Future<void> _savePublicDetailsToPrefs(PublicDetailsResponse details) async {
  final prefs = SharedPreferencesUtil();
  await prefs.saveMap('public_details', details.toJson());
  await prefs.saveString('publishable_key', details.token ?? '');
  await prefs.saveBool('google_map_usage', details.googleMapUsage ?? false);
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
      theme: theme,
      navigatorObservers: AppConfig.isNewRelicEnabled
          ? [NewRelicNavigationObserver()]
          : const <NavigatorObserver>[],
      home: SplashPage(
        skipLogin: skipLogin,
        publicDetailsResponse: publicDetailsResponse,
      ),
    );
  }

  final ThemeData theme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    splashFactory: InkRipple.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
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
