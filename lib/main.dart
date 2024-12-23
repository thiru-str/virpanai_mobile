
import 'package:waioz/utility/font_utils.dart';

import '../ui/splash_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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


