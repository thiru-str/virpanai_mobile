import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static double borderRadiusSm = 4;
  static double borderRadiusMd = 8;
  static double borderRadiusLg = 16;
  static String buttonStyle = 'filled'; // "filled" | "outlined" | "text"
  static double buttonRadius = 8;
  static bool cardShowRating = true;
  static bool cardShowDiscountBadge = true;
  static bool cardShowWishlist = true;
  static String cardImageRatio = '1:1';

  static void updateFromThemeResponse(Map<String, dynamic> theme) {
    borderRadiusSm = (theme['border_radius_sm'] ?? 4).toDouble();
    borderRadiusMd = (theme['border_radius_md'] ?? 8).toDouble();
    borderRadiusLg = (theme['border_radius_lg'] ?? 16).toDouble();
    buttonStyle = theme['button_style'] ?? 'filled';
    buttonRadius = (theme['button_radius'] ?? 8).toDouble();
    cardShowRating = theme['card_show_rating'] ?? true;
    cardShowDiscountBadge = theme['card_show_discount_badge'] ?? true;
    cardShowWishlist = theme['card_show_wishlist'] ?? true;
    cardImageRatio = theme['card_image_ratio'] ?? '1:1';

    // Update colors
    AppColors.updateAllColors(
      newPrimary: _parseColor(theme['primary_color']),
      newSecondary: _parseColor(theme['secondary_color']),
      newAccent: _parseColor(theme['accent_color']),
      newSurface: _parseColor(theme['surface_color']),
      newBackground: _parseColor(theme['background_color']),
      newError: _parseColor(theme['error_color']),
      newToolbarBg: _parseColor(theme['toolbar_bg_color']),
      newToolbarText: _parseColor(theme['toolbar_text_color']),
    );
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static BorderRadius get smallRadius => BorderRadius.circular(borderRadiusSm);
  static BorderRadius get mediumRadius => BorderRadius.circular(borderRadiusMd);
  static BorderRadius get largeRadius => BorderRadius.circular(borderRadiusLg);
  static BorderRadius get buttonBorderRadius => BorderRadius.circular(buttonRadius);

  static ButtonStyle get primaryButtonStyle {
    switch (buttonStyle) {
      case 'outlined':
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
        );
      case 'text':
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
        );
      default: // filled
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
        );
    }
  }

  static double getImageAspectRatio() {
    switch (cardImageRatio) {
      case '3:4':
        return 3 / 4;
      case '4:3':
        return 4 / 3;
      case '16:9':
        return 16 / 9;
      default:
        return 1.0;
    }
  }
}
