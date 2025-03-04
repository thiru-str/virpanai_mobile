import 'package:flutter/material.dart';
import 'package:waioz/utility/app_strings.dart';

class FontUtils {
  // Font families
  static const String circularStd =AppStrings.circularStd;

  static const String gabarito =AppStrings.gabarito;


  /// Get TextStyle for CircularStd font
  static TextStyle circularStdStyle({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14.0,
    Color color = Colors.black,
    double letterSpacing = 0.0,
  }) {
    return TextStyle(
      fontFamily: circularStd,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Get TextStyle for Gabarito font
  static TextStyle gabaritoStyle({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14.0,
    Color color = Colors.black,
    double letterSpacing = 0.0,
  }) {
    return TextStyle(
      fontFamily: gabarito,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: 1
    );
  }
}
