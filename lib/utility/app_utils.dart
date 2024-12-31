import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AppUtils {
  // Private constructor to prevent instantiation
  AppUtils._();

  // Static method to show a toast message
  static void showToast(String message, {Color backgroundColor = Colors.white}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.black,
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
      return "Today";
    } else if (differenceInDays == 1) {
      return "Yesterday";
    } else {
      return "$differenceInDays days ago";
    }
  }

}
