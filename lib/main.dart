
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
import 'package:waioz/utility/shared_preferences_util.dart';

import '../ui/splash_page.dart';
import 'package:flutter/material.dart';

import 'api/api_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  String? currencySymbol = await SharedPreferencesUtil().getString('currency_symbol') ?? '₹';

  // Initialize the currency symbol cache
  await CurrencyUtil.initializeCurrencySymbol(currencySymbol);

  await Firebase.initializeApp();

  PublicDetailsResponse publicDetailsResponse = await ApiService().getPublicDetails();
  await SharedPreferencesUtil().saveMap('public_details', publicDetailsResponse.toJson());
  await SharedPreferencesUtil().saveString('publishable_key', publicDetailsResponse.token!);
  await SharedPreferencesUtil().saveBool('google_map_usage', publicDetailsResponse.googleMapUsage!);
  await SharedPreferencesUtil().saveString('app_header', publicDetailsResponse.theme!.header!);
  await SharedPreferencesUtil().saveString('invoice_url', publicDetailsResponse.storeDetails?.storeMetadata?.invoiceUrl??'');
  await SharedPreferencesUtil().saveString('customer_support', publicDetailsResponse.storeDetails?.storeMetadata?.customerSupport??'');
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
  runApp(HomeScreen(skipLogin: false,publicDetailsResponse: publicDetailsResponse,));
  Future.delayed(Duration.zero, () {
    AppLinkHelper.init();
  });
}

class HomeScreen extends StatelessWidget {
   final bool skipLogin;
   final PublicDetailsResponse? publicDetailsResponse;
   HomeScreen({super.key,this.skipLogin = false,this.publicDetailsResponse});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: navigatorKey, // if you're using it for global navigation
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'MyCustomFont',textTheme: const TextTheme()),
      home: SplashPage(skipLogin: skipLogin,publicDetailsResponse: publicDetailsResponse,),
    );
  }



}


