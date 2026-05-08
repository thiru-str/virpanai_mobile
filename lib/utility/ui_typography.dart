import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class UiTypography {
  UiTypography._();

  static TextStyle cardTitle({Color color = AppColors.textColor}) {
    return FontUtils.primaryFontStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.1,
    );
  }

  static TextStyle cardSubtitle({Color color = AppColors.textColor50}) {
    return FontUtils.secondaryFontStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 0.1,
    );
  }

  static TextStyle cardPrice({Color color = Colors.black}) {
    return FontUtils.primaryFontStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle cardMeta({Color color = Colors.grey}) {
    return FontUtils.secondaryFontStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle cardAction({Color color = Colors.black}) {
    return FontUtils.primaryFontStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.2,
    );
  }

  static TextStyle searchHint() {
    return FontUtils.secondaryFontStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade600,
    );
  }
}
