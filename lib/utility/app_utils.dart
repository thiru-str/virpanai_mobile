import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';
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

  static Future<bool> isLoggedIn() async {
    // final skipLogin = await SharedPreferencesUtil().getBool('skip_login');
    // if (skipLogin == false) {
    //   return true;
    // }

    final token = await SharedPreferencesUtil().getString('token');
    return token != null && token.isNotEmpty;
  }

}
