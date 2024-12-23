import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
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

}
