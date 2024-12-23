
import '../ui/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF3848C5), // Set the status bar color here
    statusBarIconBrightness: Brightness.light, // For Android, controls the status bar icon color
    statusBarBrightness: Brightness.dark, // For iOS, controls the status bar text color
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(const HomeScreen());
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // Define the default font family.
          fontFamily: 'MyCustomFont',
          // Define the default text theme to apply the custom font to all text.
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
        ),
      home: const SplashScreen(),
    );
  }
}


void showToast(String value) {
  Fluttertoast.showToast(
    msg: value,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.white,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

