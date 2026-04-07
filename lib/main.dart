import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/public_detail_model.dart';
import 'package:waioz/ui/ApprovalPage.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/widgets/snack_bar_util.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_link_helper.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import 'package:flutter/material.dart';

import 'api/api_service.dart';
import 'api/storees_service.dart';
import 'ui/splash_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    AppLogger.error(
        'Unhandled Flutter framework error', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Unhandled platform error', error, stack);
    return true;
  };

  // Lock orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  String? currencySymbol =
      await SharedPreferencesUtil().getString('currency_symbol') ?? '₹';

  // Initialize the currency symbol cache
  await CurrencyUtil.initializeCurrencySymbol(currencySymbol);

  await Firebase.initializeApp();
  await StoreesService.instance.init();
  final bootstrapResult = await _bootstrapApp();
  await SharedPreferencesUtil().saveBool('skip_login', false);

  // FontUtils.updateFonts(
  //   primaryFont: publicDetailsResponse.theme!.titleFont!,
  //   secondaryFont: publicDetailsResponse.theme!.contentFont!,
  // );

  // Color? apiPrimaryColor = AppUtils.parseHexColor(publicDetailsResponse.theme!.primaryColor!) ?? AppColors.primary;
  // Color? apiSecondaryColor = AppUtils.parseHexColor(publicDetailsResponse.theme!.secondaryColor) ?? AppColors.secondary;
  //
  //
  // AppColors.updateColors(newPrimary: apiPrimaryColor, newSecondary: apiSecondaryColor);

  SnackBarUtil.init(rootScaffoldMessengerKey);
  runApp(
    HomeScreen(
      skipLogin: false,
      publicDetailsResponse: bootstrapResult.publicDetailsResponse,
      startupError: bootstrapResult.startupError,
    ),
  );
  Future.delayed(Duration.zero, () {
    AppLinkHelper.init();
  });
}

Future<_AppBootstrapResult> _bootstrapApp() async {
  try {
    final publicDetailsResponse = await ApiService().getPublicDetails();
    await SharedPreferencesUtil().savePublicDetails(publicDetailsResponse);
    return _AppBootstrapResult(publicDetailsResponse: publicDetailsResponse);
  } catch (error, stackTrace) {
    AppLogger.error('Public details bootstrap failed', error, stackTrace);
    return _AppBootstrapResult(
      startupError: _formatStartupError(error),
    );
  }
}

String _formatStartupError(Object error) {
  if (error is ApiRequestException) {
    return error.displayMessage;
  }

  return error.toString();
}

class _AppBootstrapResult {
  final PublicDetailsResponse? publicDetailsResponse;
  final String? startupError;

  const _AppBootstrapResult({
    this.publicDetailsResponse,
    this.startupError,
  });
}

class HomeScreen extends StatelessWidget {
  final bool skipLogin;
  final PublicDetailsResponse? publicDetailsResponse;
  final String? startupError;
  HomeScreen({
    super.key,
    this.skipLogin = false,
    this.publicDetailsResponse,
    this.startupError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: navigatorKey, // if you're using it for global navigation
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(fontFamily: 'MyCustomFont', textTheme: const TextTheme()),
      home: SplashPage(
        skipLogin: skipLogin,
        publicDetailsResponse: publicDetailsResponse,
        startupError: startupError,
      ),
    );
  }
}
