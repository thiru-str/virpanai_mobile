import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'GoWelMart';
  //static const String baseUrl = 'https://dev.api.ecommerce.gowelmart.com/';
  static const String baseUrl = 'https://apiecommerce.gowelmart.com/';
  static const String googleApiKey = 'AIzaSyBYqO1N5Rr6fnLeOz4fxSPcPwHy77CNe_c';
  static const String publishableKeyStripe =
      'pk_test_51QjKGFC5ZYai6Al85lKNzizk9i1E4ViPFg98dC4VECB9cEYPidOj6Pig2orwg1SKVGDndepP8McSJ4jPhnxhEIKj00aaPJefmb';
  static const String razorPayKey = 'rzp_test_TWZQg4tf6e1Tqs';
  static const String newRelicAndroidAppToken = '';
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
