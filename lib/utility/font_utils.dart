import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontUtils {
  // Default Custom Fonts
  static const String defaultCircularStd = 'CircularStd';
  static const String defaultGabarito = 'Gabarito';

  static String? apiPrimaryFont;
  static String? apiSecondaryFont;

  /// Update fonts from API
  static void updateFonts({String? primaryFont, String? secondaryFont}) {
    apiPrimaryFont = primaryFont;
    apiSecondaryFont = secondaryFont;
  }

  /// Get TextStyle for Primary Font (Google Font if available, else default)
  static TextStyle primaryFontStyle({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14.0,
    Color color = Colors.black,
    double letterSpacing = 0.0,
    TextDecoration decoration = TextDecoration.none,
  }) {
    if (apiPrimaryFont != null && GoogleFonts.asMap().containsKey(apiPrimaryFont)) {
      return GoogleFonts.getFont(
        apiPrimaryFont!,
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );
    }
    return TextStyle(
      fontFamily: defaultCircularStd,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Get TextStyle for Secondary Font (Google Font if available, else default)
  static TextStyle secondaryFontStyle1({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14.0,
    Color color = Colors.black,
    double letterSpacing = 0.0,
    TextDecoration decoration = TextDecoration.none,
  }) {
    if (apiSecondaryFont != null && GoogleFonts.asMap().containsKey(apiSecondaryFont)) {
      return GoogleFonts.getFont(
        apiSecondaryFont!,
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );
    }
    return TextStyle(
      fontFamily: defaultGabarito,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
