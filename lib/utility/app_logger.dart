import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 200,
      colors: true,
      printEmojis: false,
      printTime: false,
    ),
  );

  static const bool _isDebugMode = kDebugMode;

  static void print(String title, dynamic message) {
    if (!_isDebugMode) return;
    _logger.d("$title: $message");
  }

  static void printInt(String title, int message) {
    if (_isDebugMode) _logger.d("$title: $message");
  }

  static void printBool(String title, bool message) {
    if (_isDebugMode) _logger.d("$title: $message");
  }

  static void info(String title, String message) {
    if (_isDebugMode) _logger.i("$title: $message");
  }

  static void warning(String message) {
    if (_isDebugMode) _logger.w(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_isDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  static void logFullJson(dynamic data) {
    if (!_isDebugMode) return;

    try {
      if (data is Map || data is List) {
        // Compact-encode first to gauge size. Pretty-printing large responses
        // blocks the main isolate for seconds/minutes; skip those entirely.
        final compact = jsonEncode(data);
        if (compact.length > 8000) {
          _logger.i('[body ~${compact.length} chars — skipped to avoid UI block]');
          return;
        }
        final pretty = JsonEncoder.withIndent('  ').convert(data);
        _logger.i(pretty);
        return;
      }

      if (data is String) {
        final parsed = _tryParseJson(data);
        if (parsed != null) {
          final pretty = JsonEncoder.withIndent('  ').convert(parsed);
          _logger.i(pretty);
          return;
        }
      }

      _logger.i(data.toString());
    } catch (_) {
      _logger.i(data.toString());
    }
  }

  static dynamic _tryParseJson(String input) {
    try {
      return jsonDecode(input);
    } catch (_) {
      return null;
    }
  }
}
