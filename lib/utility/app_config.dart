import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'HAKA DTS';
  // static const String baseUrl = 'https://undeposed-tabatha-applaudably.ngrok-free.dev/';
  static const String baseUrl = 'https://api.hakadts.com/';
  // static const String baseUrl = 'http://192.168.0.19:9000/';
  // The store's website serves resized WebP at /_next/image for files on its
  // CDN. Empty = this build loads originals (still decoded at display size).
  static const String imageOptimiserBase = '';
  static const String imageCdnHost = '';

  // Stands in for a missing product or category picture. A merchant branch sets
  // its logo here (bundled in images/). Empty = the generic no-image mark.
  static const String placeholderLogo = '';

  // AppHeaderBasket1 sets the wide logo on a white plate, so any logo reads on
  // any brand colour. Turn off for a logo drawn to sit on the bar.
  static const bool headerLogoOnPlate = true;
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
