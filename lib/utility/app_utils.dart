import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

class AppUtils {
  // Private constructor to prevent instantiation
  AppUtils._();

  // Static method to show a toast message
  static void showToast(String message, {Color backgroundColor = Colors.white}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
    );
  }

  static String timeAgo(String dateString) {
    // Parse the input date string to a DateTime object
    DateTime inputDate = DateTime.parse(dateString);
    // Get the current date and time
    DateTime now = DateTime.now();

    // Calculate the difference in days
    int differenceInDays = now.difference(inputDate).inDays;

    if (differenceInDays == 0) {
      return AppStrings.Today;
    } else if (differenceInDays == 1) {
      return AppStrings.Yesterday;
    } else {
      return "$differenceInDays days ago";
    }
  }

  // Convert Hex String to Color
  static Color? parseHexColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;

    hexColor = hexColor.replaceAll("#", ""); // Remove "#" if present

    if (hexColor.length == 6) {
      return Color(int.parse("0xFF$hexColor"));
    } else if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }

    return null; // Invalid format
  }

  // Convert Color to Hex String
  static String colorToHex(Color color, {bool includeAlpha = false}) {
    String alpha = includeAlpha ? color.alpha.toRadixString(16).padLeft(2, '0') : "";
    String red = color.red.toRadixString(16).padLeft(2, '0');
    String green = color.green.toRadixString(16).padLeft(2, '0');
    String blue = color.blue.toRadixString(16).padLeft(2, '0');

    return "#$alpha$red$green$blue".toUpperCase();
  }

  static Color rgbStringToColor(String rgbString) {
    try {
      // Match both rgb(...) and rgba(...) formats
      final regex = RegExp(
        r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([0-9.]+))?\)',
        caseSensitive: false,
      );

      final match = regex.firstMatch(rgbString);
      if (match != null) {
        final r = int.parse(match.group(1)!);
        final g = int.parse(match.group(2)!);
        final b = int.parse(match.group(3)!);
        final a = match.group(4) != null ? double.parse(match.group(4)!) : 1.0;

        return Color.fromRGBO(r, g, b, a);
      }
    } catch (e) {
      debugPrint('Error parsing color string: $e');
    }

    // Default fallback color
    return Colors.black;
  }

  static Gradient? parseGradient(String gradientString) {
    try {
      final regex = RegExp(
        r'linear-gradient\(([^,]+),\s*(.+)\)',
        caseSensitive: false,
      );

      final match = regex.firstMatch(gradientString);
      if (match != null) {
        final angleStr = match.group(1)!.trim();
        final colorStopsStr = match.group(2)!;

        // Parse angle
        double angle = 0;
        if (angleStr.contains('deg')) {
          angle = double.tryParse(angleStr.replaceAll('deg', '').trim()) ?? 0;
        }

        // Extract all rgb/rgba() colors
        final colorMatches =
        RegExp(r'rgba?\([^)]+\)', caseSensitive: false).allMatches(colorStopsStr);

        final colors = <Color>[];
        for (final match in colorMatches) {
          colors.add(rgbStringToColor(match.group(0)!));
        }

        // Fallback if colors not parsed
        if (colors.isEmpty) return null;

        return LinearGradient(
          begin: _alignmentFromAngle(angle + 180),
          end: _alignmentFromAngle(angle),
          colors: colors,
        );
      }
    } catch (e) {
      debugPrint('Error parsing gradient: $e');
    }

    return null;
  }

  static Alignment _alignmentFromAngle(double angle) {
    final rad = angle * pi / 180;
    return Alignment(cos(rad), sin(rad));
  }


  static Future<bool> isLoggedIn() async {
    // final skipLogin = await SharedPreferencesUtil().getBool('skip_login');
    // if (skipLogin == false) {
    //   return true;
    // }

    final token = await SharedPreferencesUtil().getString('token');
    return token != null && token.isNotEmpty;
  }

  static BoxDecoration? buildLayoutBackground(Content content) {
    final type = content.layoutBgType;
    final color = content.layoutBgColor;
    final image = content.layoutBgImage;

    if (type == 'image' && image?.isNotEmpty == true) {
      return BoxDecoration(
        image: DecorationImage(
          image: image!.startsWith('assets/')
              ? AssetImage(image) as ImageProvider
              : NetworkImage(image),
          fit: BoxFit.fill,
        ),
      );
    }

    // 🎨 Handle both color and gradient inside type=color
    if (type == 'color' && color?.isNotEmpty == true) {
      if (color!.toLowerCase().startsWith('linear-gradient')) {
        final gradient = AppUtils.parseGradient(color);
        if (gradient != null) {
          return BoxDecoration(gradient: gradient);
        }
      } else {
        return BoxDecoration(color: AppUtils.rgbStringToColor(color));
      }
    }

    return null; // No background
  }



}
