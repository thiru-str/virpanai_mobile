

import 'package:flutter/material.dart';

class AppColors {
  static Color primary = Color(0xFF124B5C);
  static Color secondary = Color(0xFFF4F4F4);
  static const Color tabInActivecolor = Color(0xFFA2A2A2);
  static const Color profileItemArrowColor = Color(0xFF272727);
  static const Color textColor = Color(0xFF272727);
  static const Color textColor50 = Color(0x80272727);
  static const Color searchBarColor = Color(0xFFE1E4ED);

  // Function to update colors dynamically
  static void updateColors({Color? newPrimary, Color? newSecondary}) {
    primary = newPrimary ?? primary;
    secondary = newSecondary ?? secondary;
  }

  static const LinearGradient linearGradient = LinearGradient(
    colors: [
      Color(0xFFF5FEF2),
      Color(0xFFFEFFFE),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}