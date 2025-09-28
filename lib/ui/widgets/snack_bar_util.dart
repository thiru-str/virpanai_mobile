import 'package:flutter/material.dart';

class SnackBarUtil {
  static GlobalKey<ScaffoldMessengerState>? messengerKey;

  static void init(GlobalKey<ScaffoldMessengerState> key) {
    messengerKey = key;
  }

  static void showGlobal(
      String message, {
        Color backgroundColor = Colors.black87,
        Color textColor = Colors.white,
        int durationSeconds = 1,
      }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: durationSeconds),
    );

    messengerKey?.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
