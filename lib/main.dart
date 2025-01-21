
import 'package:firebase_core/firebase_core.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/push_notification_service.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../ui/splash_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? currencySymbol = await SharedPreferencesUtil().getString('currency_symbol') ?? '₹';

  // Initialize the currency symbol cache
  await CurrencyUtil.initializeCurrencySymbol(currencySymbol);

  await Firebase.initializeApp();

  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initializeFCM();

  runApp( HomeScreen());
}

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }

   ThemeData theme = ThemeData(
     textTheme: TextTheme(
       displayLarge: FontUtils.circularStdStyle(fontWeight: FontWeight.w800, fontSize: 14.0),
       displayMedium: FontUtils.gabaritoStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
       displaySmall: FontUtils.circularStdStyle(fontWeight: FontWeight.w400, fontSize: 24.0),
     ),
   );


}


