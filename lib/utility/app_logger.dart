import 'package:flutter/foundation.dart';

class AppLogger {
  static const bool _isDebugMode = kDebugMode; // Enables logging only in debug mode

  /// Logs a debug message
  static void print(String title,String message) {
    if (_isDebugMode) {
      debugPrint('$title: $message');
    }
  }

  /// Logs an info message
  static void info(String title,String message) {
    if (_isDebugMode) {
      debugPrint('$title: $message');
    }
  }

  /// Logs a warning message
  static void warning(String message) {
    if (_isDebugMode) {
      debugPrint('WARNING: $message');
    }
  }

  /// Logs an error message
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_isDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) {
        debugPrint('Error Details: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }
}
