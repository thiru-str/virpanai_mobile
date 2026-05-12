import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'VirpanAi';
  static const String baseUrl = 'http://localhost:9000/';
  // iOS Simulator: http://localhost:9000/
  // Android Emulator: http://10.0.2.2:9000/
  // Physical device (same WiFi): http://192.168.0.10:9000/
  // static const String baseUrl = 'https://api.annachimaligai.com/';
  // static const String baseUrl = 'https://undeposed-tabatha-applaudably.ngrok-free.dev/';
  // static const String baseUrl = 'https://virpanai.dev.api.waioz.com/';
  // static const String baseUrl = 'https://virpanai.api.waioz.com/';
  static const String googleApiKey = 'AIzaSyBYqO1N5Rr6fnLeOz4fxSPcPwHy77CNe_c';
  static const String publishableKeyStripe =
      'pk_test_51QjKGFC5ZYai6Al85lKNzizk9i1E4ViPFg98dC4VECB9cEYPidOj6Pig2orwg1SKVGDndepP8McSJ4jPhnxhEIKj00aaPJefmb';
  static const String razorPayKey = 'rzp_test_YRkMaoYHJhpYjV';
  static const String newRelicAndroidAppToken =
      'AAfe6ba68624d91d5091778f1274d4d7db35d8eefb-NRMA';
  static const String newRelicIosAppToken = '';

  static String get newRelicAppToken {
    if (kIsWeb) {
      return '';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return newRelicAndroidAppToken.trim();
      case TargetPlatform.iOS:
        return newRelicIosAppToken.trim();
      default:
        return '';
    }
  }

  static bool get isNewRelicEnabled => newRelicAppToken.isNotEmpty;

  // store test keys here
  /*static const String publishableKeyStripe = 'pk_test_51QjKGFC5ZYai6Al85lKNzizk9i1E4ViPFg98dC4VECB9cEYPidOj6Pig2orwg1SKVGDndepP8McSJ4jPhnxhEIKj00aaPJefmb';
  static const String razorPayKey = 'rzp_test_TWZQg4tf6e1Tqs';
  */
}
