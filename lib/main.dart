
import 'package:firebase_core/firebase_core.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/public_detail_model.dart';
import 'package:waioz/ui/ApprovalPage.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/push_notification_service.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../ui/splash_page.dart';
import 'package:flutter/material.dart';

import 'api/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? currencySymbol = await SharedPreferencesUtil().getString('currency_symbol') ?? '₹';

  // Initialize the currency symbol cache
  await CurrencyUtil.initializeCurrencySymbol(currencySymbol);

  await Firebase.initializeApp();

  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initializeFCM();

  PublicDetailsResponse publicDetailsResponse = await ApiService().getPublicDetails();
  await SharedPreferencesUtil().saveMap('public_details', publicDetailsResponse.toJson());
  await SharedPreferencesUtil().saveString('publishable_key', publicDetailsResponse.token!);
  await SharedPreferencesUtil().saveBool('google_map_usage', publicDetailsResponse.googleMapUsage!);
  await SharedPreferencesUtil().saveString('app_header', publicDetailsResponse.theme!.header!);
  await SharedPreferencesUtil().saveBool('skip_login', false);


  FontUtils.updateFonts(
    primaryFont: publicDetailsResponse.theme!.titleFont!,
    secondaryFont: publicDetailsResponse.theme!.contentFont!,
  );

  // Color? apiPrimaryColor = AppUtils.parseHexColor(publicDetailsResponse.theme!.primaryColor!) ?? AppColors.primary;
  // Color? apiSecondaryColor = AppUtils.parseHexColor(publicDetailsResponse.theme!.secondaryColor) ?? AppColors.secondary;
  //
  //
  // AppColors.updateColors(newPrimary: apiPrimaryColor, newSecondary: apiSecondaryColor);


  runApp(HomeScreen(skipLogin: false,));
}

class HomeScreen extends StatelessWidget {
   final bool skipLogin;
   HomeScreen({super.key,this.skipLogin = false});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(skipLogin: skipLogin),
    );
  }

   ThemeData theme = ThemeData(
     textTheme: const TextTheme(
       displayLarge: TextStyle(fontFamily: 'MyCustomFont', fontSize: 57),
       displayMedium: TextStyle(fontFamily: 'MyCustomFont', fontSize: 45),
       displaySmall: TextStyle(fontFamily: 'MyCustomFont', fontSize: 36),
       headlineLarge: TextStyle(fontFamily: 'MyCustomFont', fontSize: 32),
       headlineMedium: TextStyle(fontFamily: 'MyCustomFont', fontSize: 28),
       headlineSmall: TextStyle(fontFamily: 'MyCustomFont', fontSize: 24),
       titleLarge: TextStyle(fontFamily: 'MyCustomFont', fontSize: 22),
       titleMedium: TextStyle(fontFamily: 'MyCustomFont', fontSize: 16),
       titleSmall: TextStyle(fontFamily: 'MyCustomFont', fontSize: 14),
       bodyLarge: TextStyle(fontFamily: 'MyCustomFont', fontSize: 16),
       bodyMedium: TextStyle(fontFamily: 'MyCustomFont', fontSize: 14),
       bodySmall: TextStyle(fontFamily: 'MyCustomFont', fontSize: 12),
       labelLarge: TextStyle(fontFamily: 'MyCustomFont', fontSize: 14),
       labelMedium: TextStyle(fontFamily: 'MyCustomFont', fontSize: 12),
       labelSmall: TextStyle(fontFamily: 'MyCustomFont', fontSize: 11),
     ),
   );


}


