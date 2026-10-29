import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_logger.dart';

class AppErrorReporter {
  AppErrorReporter._();

  static final AppErrorReporter instance = AppErrorReporter._();

  bool get _isEnabled => AppConfig.isNewRelicEnabled;

  Future<void> initialize() async {
    if (!_isEnabled) return;

    await _runGuarded(
      () => NewrelicMobile.instance.setAttribute('app_name', AppConfig.appName),
      operation: 'initialize',
    );
  }

  void installGlobalHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      recordFatal(
        details.exception,
        details.stack ?? StackTrace.current,
        reason: details.context?.toDescription(),
        attributes: <String, dynamic>{
          if (details.library != null) 'library': details.library!,
        },
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
      recordFatal(
        error,
        stackTrace,
        reason: 'PlatformDispatcher.onError',
      );
      return true;
    };
  }

  void recordFatal(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, dynamic>? attributes,
  }) {
    _recordError(
      error,
      stackTrace,
      isFatal: true,
      reason: reason,
      attributes: attributes,
    );
  }

  void recordHandled(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? attributes,
  }) {
    _recordError(
      error,
      stackTrace ?? StackTrace.current,
      isFatal: false,
      reason: reason,
      attributes: attributes,
    );
  }

  Future<void> addBreadcrumb(
    String name, {
    Map<String, dynamic>? attributes,
  }) async {
    if (!_isEnabled) return;

    await _runGuarded(
      () => NewrelicMobile.instance.recordBreadcrumb(
        name,
        eventAttributes: _sanitizeAttributes(attributes),
      ),
      operation: 'addBreadcrumb',
    );
  }

  Future<void> trackEvent(
    String eventType, {
    String? eventName,
    Map<String, dynamic>? attributes,
  }) async {
    if (!_isEnabled) return;

    await _runGuarded(
      () => NewrelicMobile.instance.recordCustomEvent(
        eventType,
        eventName: eventName ?? '',
        eventAttributes: _sanitizeAttributes(attributes),
      ),
      operation: 'trackEvent',
    );
  }

  Future<void> syncCustomer(Customer? customer) async {
    if (customer == null) return;

    await setUser(
      id: customer.id,
      email: customer.email,
      phone: customer.phone,
      firstName: customer.firstName,
      lastName: customer.lastName,
      companyName: customer.companyName,
    );
  }

  Future<void> setUser({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? companyName,
  }) async {
    if (!_isEnabled) return;

    final userId = (id ?? '').trim();
    if (userId.isNotEmpty) {
      await _runGuarded(
        () => NewrelicMobile.instance.setUserId(userId),
        operation: 'setUserId',
      );
    }

    final fullName = [firstName, lastName]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');

    await _setAttributeIfPresent('user_email', email);
    await _setAttributeIfPresent('user_phone', phone);
    await _setAttributeIfPresent('user_name', fullName);
    await _setAttributeIfPresent('user_company', companyName);
  }

  Future<void> clearUser() async {
    if (!_isEnabled) return;

    await _runGuarded(
      () => NewrelicMobile.instance.setUserId(''),
      operation: 'clearUserId',
    );
    await _removeAttribute('user_email');
    await _removeAttribute('user_phone');
    await _removeAttribute('user_name');
    await _removeAttribute('user_company');
  }

  Future<void> setAttribute(String key, Object value) async {
    if (!_isEnabled) return;

    await _runGuarded(
      () => NewrelicMobile.instance.setAttribute(key, value),
      operation: 'setAttribute:$key',
    );
  }

  Future<void> removeAttribute(String key) async {
    if (!_isEnabled) return;

    await _removeAttribute(key);
  }

  void _recordError(
    Object error,
    StackTrace stackTrace, {
    required bool isFatal,
    String? reason,
    Map<String, dynamic>? attributes,
  }) {
    AppLogger.error(reason ?? 'Captured application error', error, stackTrace);

    if (!_isEnabled) return;

    unawaited(
      _runGuarded(
        () => Future<void>.sync(
          () => NewrelicMobile.instance.recordError(
            error,
            stackTrace,
            isFatal: isFatal,
            attributes: _sanitizeAttributes(<String, dynamic>{
              if (reason != null && reason.isNotEmpty) 'reason': reason,
              ...?attributes,
            }),
          ),
        ),
        operation: isFatal ? 'recordFatal' : 'recordHandled',
      ),
    );
  }

  Future<void> _setAttributeIfPresent(String key, String? value) async {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return;
    await setAttribute(key, normalized);
  }

  Future<void> _removeAttribute(String key) async {
    await _runGuarded(
      () => NewrelicMobile.instance.removeAttribute(key),
      operation: 'removeAttribute:$key',
    );
  }

  Map<String, dynamic>? _sanitizeAttributes(Map<String, dynamic>? attributes) {
    if (attributes == null || attributes.isEmpty) return null;

    final sanitized = <String, dynamic>{};
    attributes.forEach((key, value) {
      if (value == null) return;
      if (value is String || value is num || value is bool) {
        sanitized[key] = value;
      } else {
        sanitized[key] = value.toString();
      }
    });

    return sanitized.isEmpty ? null : sanitized;
  }

  Future<void> _runGuarded(
    FutureOr<dynamic> Function() action, {
    required String operation,
  }) async {
    try {
      await Future<dynamic>.sync(action);
    } catch (error, stackTrace) {
      AppLogger.error(
        'New Relic reporter error during $operation',
        error,
        stackTrace,
      );
    }
  }
}
