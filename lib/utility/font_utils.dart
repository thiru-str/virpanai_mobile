import 'package:flutter/material.dart';

class FontUtils {
  /// The only font family used across the app
  static const String defaultFont = 'MyCustomFont';

  /// Common TextStyle builder
  static TextStyle baseStyle({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 14.0,
    Color color = Colors.black,
    double letterSpacing = 0.0,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
      fontFamily: defaultFont,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontVariations: [FontVariation('wght', fontWeight.index * 100 + 100)],
    );
  }

  /// Primary font style (same as base)
  static TextStyle primaryFontStyle({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 14.0,
    Color color = Colors.black,
    double letterSpacing = 0.0,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return baseStyle(
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Secondary font style (same as base)
  static TextStyle secondaryFontStyle({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 14.0,
    Color color = Colors.black,
    double letterSpacing = 0.0,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return baseStyle(
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
