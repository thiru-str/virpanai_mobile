

import 'package:flutter/material.dart';

class AppColors {
  static Color primary = Color(0xFF8E6CEF);
  static Color secondary = Color(0xFFF4F4F4);
  static const Color tabInActivecolor = Color(0xFFA2A2A2);
  static const Color profileItemArrowColor = Color(0xFF272727);
  static const Color textColor = Color(0xFF272727);
  static const Color textColor50 = Color(0x80272727);
  static const Color searchBarColor = Color(0xFFE1E4ED);

  // Function to update colors dynamically
  static void updateColors({Color? newPrimary, Color? newSecondary}) {
    primary = newPrimary ?? primary;
    secondary = _lightSurface(newSecondary ?? secondary);
  }

  /// Every screen uses [secondary] as a pale surface (icon circles, image
  /// placeholders, chips). A store may set it to its dark brand colour —
  /// then icons drawn in the primary vanish on it — so a dark value is
  /// replaced by a soft tint of the primary.
  static Color _lightSurface(Color c) => c.computeLuminance() > 0.7
      ? c
      : Color.alphaBlend(primary.withValues(alpha: 0.10), Colors.white);
}