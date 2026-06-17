import 'dart:developer' as developer;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 200,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.none,
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
    developer.log(message, name: 'AppLogger.warning');
    if (_isDebugMode) _logger.w(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'AppLogger.error',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    if (_isDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  static void logApiResult({
    required String title,
    required String method,
    required String url,
    int? statusCode,
    dynamic requestBody,
    dynamic responseBody,
  }) {
    if (!_isDebugMode) return;

    final payload = <String, dynamic>{
      'title': title,
      'method': method,
      'url': url,
      if (statusCode != null) 'status_code': statusCode,
      if (requestBody != null) 'request_body': _normalizeLogValue(requestBody),
      if (responseBody != null)
        'response_body': _normalizeLogValue(responseBody),
    };

    logFullJson(payload);
  }

  static void logFullJson(dynamic data) {
    if (!_isDebugMode) return;

    try {
      if (data is Map || data is List) {
        final pretty = const JsonEncoder.withIndent('  ').convert(data);
        _logger.i(pretty);
        return;
      }

      if (data is String) {
        final parsed = _tryParseJson(data);
        if (parsed != null) {
          final pretty = const JsonEncoder.withIndent('  ').convert(parsed);
          _logger.i(pretty);
          return;
        }
      }

      _logger.i(data.toString());
    } catch (_) {
      _logger.i(data.toString());
    }
  }

  static dynamic _normalizeLogValue(dynamic value) {
    if (value is String) {
      return _tryParseJson(value) ?? value;
    }

    return value;
  }

  static dynamic _tryParseJson(String input) {
    try {
      return jsonDecode(input);
    } catch (_) {
      return null;
    }
  }
}
