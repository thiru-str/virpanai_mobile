import 'package:dio/dio.dart';
import 'package:waioz/model/place_order_response.dart' as place_order;
import 'package:waioz/model/register_response.dart' as register;
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

class StoreesService {
  StoreesService._internal();

  static final StoreesService instance = StoreesService._internal();

  static const String _identityCustomerIdKey = 'storees_customer_id';
  static const String _identityEmailKey = 'storees_customer_email';
  static const String _identityPhoneKey = 'storees_customer_phone';
  static const String _identityNameKey = 'storees_customer_name';
  static const String _lastTrackedCartIdKey = 'storees_last_cart_created_id';
  static const String _lastSyncedFcmTokenKey = 'storees_last_synced_fcm_token';
  static const String _lastSyncedFcmCustomerIdKey =
      'storees_last_synced_fcm_customer_id';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.storeesBaseUrl,
      headers: {
        'X-API-Key': AppConfig.storeesApiKey,
        'X-API-Secret': AppConfig.storeesApiSecret,
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  bool _isInitialized = false;
  String? _customerId;
  String? _customerEmail;
  String? _customerPhone;
  String? _customerName;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    _customerId =
        await SharedPreferencesUtil().getString(_identityCustomerIdKey);
    _customerEmail = await SharedPreferencesUtil().getString(_identityEmailKey);
    _customerPhone = await SharedPreferencesUtil().getString(_identityPhoneKey);
    _customerName = await SharedPreferencesUtil().getString(_identityNameKey);
    _isInitialized = true;
  }

  Future<void> identify(
    String customerId, {
    String? email,
    String? phone,
    String? name,
  }) async {
    await init();

    _customerId = _normalizedValue(customerId);
    _customerEmail = _normalizedValue(email) ?? _customerEmail;
    _customerPhone = _normalizedValue(phone) ?? _customerPhone;
    _customerName = _normalizedValue(name) ?? _customerName;

    await _persistIdentity();

    await track(
      'customer_identified',
      customerId: _customerId,
      customerEmail: _customerEmail,
      customerPhone: _customerPhone,
      properties: {
        if (_customerEmail != null) 'email': _customerEmail,
        if (_customerPhone != null) 'phone': _customerPhone,
        if (_customerName != null) 'name': _customerName,
      },
    );

    await syncCurrentFcmTokenIfNeeded();
  }

  Future<void> reset() async {
    await init();

    _customerId = null;
    _customerEmail = null;
    _customerPhone = null;
    _customerName = null;

    await SharedPreferencesUtil().remove(_identityCustomerIdKey);
    await SharedPreferencesUtil().remove(_identityEmailKey);
    await SharedPreferencesUtil().remove(_identityPhoneKey);
    await SharedPreferencesUtil().remove(_identityNameKey);
    await SharedPreferencesUtil().remove(_lastTrackedCartIdKey);
    await SharedPreferencesUtil().remove(_lastSyncedFcmTokenKey);
    await SharedPreferencesUtil().remove(_lastSyncedFcmCustomerIdKey);
  }

  Future<void> syncCurrentFcmTokenIfNeeded() async {
    await init();

    final customerId = _normalizedValue(_customerId);
    final fcmToken = _normalizedValue(
      await SharedPreferencesUtil().getString('fcm_token'),
    );

    if (!_isConfigured() || customerId == null || fcmToken == null) {
      return;
    }

    final lastSyncedToken =
        await SharedPreferencesUtil().getString(_lastSyncedFcmTokenKey);
    final lastSyncedCustomerId =
        await SharedPreferencesUtil().getString(_lastSyncedFcmCustomerIdKey);

    if (lastSyncedToken == fcmToken && lastSyncedCustomerId == customerId) {
      AppLogger.print(
        'Storees FCM Sync',
        'Skipped because token already synced for customer $customerId',
      );
      return;
    }

    await _upsertCustomer(
      customerId: customerId,
      attributes: {
        'fcm_token': fcmToken,
        'push_subscribed': true,
      },
    );

    await SharedPreferencesUtil().saveString(_lastSyncedFcmTokenKey, fcmToken);
    await SharedPreferencesUtil()
        .saveString(_lastSyncedFcmCustomerIdKey, customerId);
  }

  Future<void> track(
    String eventName, {
    Map<String, dynamic>? properties,
    String? customerId,
    String? customerEmail,
    String? customerPhone,
  }) async {
    await init();

    if (!_isConfigured()) {
      AppLogger.warning(
        'Storees skipped "$eventName" because API credentials are not configured.',
      );
      return;
    }

    final effectiveCustomerId = _normalizedValue(customerId) ?? _customerId;
    final effectiveCustomerEmail =
        _normalizedValue(customerEmail) ?? _customerEmail;
    final effectiveCustomerPhone =
        _normalizedValue(customerPhone) ?? _customerPhone;

    if (effectiveCustomerId == null &&
        effectiveCustomerEmail == null &&
        effectiveCustomerPhone == null) {
      AppLogger.warning(
        'Storees skipped "$eventName" because no customer identity is available.',
      );
      return;
    }

    final sanitizedProperties = _sanitizeMap(properties);
    final payload = <String, dynamic>{
      'event_name': eventName,
      if (effectiveCustomerId != null) 'customer_id': effectiveCustomerId,
      if (effectiveCustomerEmail != null)
        'customer_email': effectiveCustomerEmail,
      if (effectiveCustomerPhone != null)
        'customer_phone': effectiveCustomerPhone,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'platform': 'mobile',
      'source': 'flutter_app',
      if (sanitizedProperties.isNotEmpty) 'properties': sanitizedProperties,
    };

    try {
      AppLogger.print('Storees Event', eventName);
      AppLogger.logFullJson(payload);

      final response = await _dio.post(
        '/events',
        data: payload,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.logFullJson(response.data);
        return;
      }

      AppLogger.warning(
        'Storees event "$eventName" failed with status ${response.statusCode}.',
      );
      if (response.data != null) {
        AppLogger.logFullJson(response.data);
      }
    } catch (error, stackTrace) {
      AppLogger.error('Storees event "$eventName" failed', error, stackTrace);
    }
  }

  Future<void> trackCustomerCreated(register.Customer customer) async {
    final name = _buildCustomerName(
      firstName: customer.firstName,
      lastName: customer.lastName,
    );

    await track(
      'customer_created',
      customerId: customer.id,
      customerEmail: customer.email,
      customerPhone: customer.phone,
      properties: {
        'name': name,
        'email': customer.email,
        'phone': customer.phone,
        'company_name': customer.companyName,
        'shop_name': customer.metadata?.shopName,
      },
    );
  }

  Future<void> trackCartCreatedIfNeeded(CartResponse cartResponse) async {
    final cart = cartResponse.cart;
    final cartId = _normalizedValue(cart?.id);
    if (cart == null || cartId == null || (cart.items ?? []).isEmpty) {
      return;
    }

    final lastTrackedCartId =
        await SharedPreferencesUtil().getString(_lastTrackedCartIdKey);
    if (lastTrackedCartId == cartId) {
      return;
    }

    await track(
      'cart_created',
      customerId: cart.customerId,
      customerEmail: cart.email,
      properties: {
        'cart_id': cartId,
        'total': '${cart.total}',
        'currency': cart.currencyCode,
        'item_count': _cartItemCount(cart),
        'line_items': _cartLineItems(cart.items),
      },
    );

    await SharedPreferencesUtil().saveString(_lastTrackedCartIdKey, cartId);
  }

  Future<void> trackCheckoutStarted(
    CartResponse cartResponse, {
    String? paymentProviderId,
  }) async {
    final cart = cartResponse.cart;
    if (cart == null) {
      return;
    }

    await track(
      'checkout_started',
      customerId: cart.customerId,
      customerEmail: cart.email,
      properties: {
        'cart_id': cart.id,
        'total': cart.total,
        'currency': cart.currencyCode,
        'item_count': _cartItemCount(cart),
        'payment_provider_id': paymentProviderId,
        'line_items': _cartLineItems(cart.items),
      },
    );
  }

  Future<void> trackOrderCompleted(
    place_order.PlaceOrderResponse placeOrderResponse,
  ) async {
    final order = placeOrderResponse.order;
    if (order == null) {
      return;
    }

    await track(
      'order_completed',
      customerEmail: order.email,
      properties: {
        'order_id': order.id,
        'order_total': order.total,
        'currency': order.currencyCode,
        'line_items': _orderLineItems(order.items),
        'city': _readAddressField(order.shippingAddress, ['city']),
        'province': _readAddressField(
          order.shippingAddress,
          ['province', 'state'],
        ),
      },
    );
  }

  Future<void> _persistIdentity() async {
    if (_customerId != null) {
      await SharedPreferencesUtil().saveString(
        _identityCustomerIdKey,
        _customerId!,
      );
    }

    if (_customerEmail != null) {
      await SharedPreferencesUtil().saveString(
        _identityEmailKey,
        _customerEmail!,
      );
    }

    if (_customerPhone != null) {
      await SharedPreferencesUtil().saveString(
        _identityPhoneKey,
        _customerPhone!,
      );
    }

    if (_customerName != null) {
      await SharedPreferencesUtil().saveString(
        _identityNameKey,
        _customerName!,
      );
    }
  }

  Future<void> _upsertCustomer({
    required String customerId,
    required Map<String, dynamic> attributes,
  }) async {
    final payload = <String, dynamic>{
      'customer_id': customerId,
      'attributes': _sanitizeMap(attributes),
    };

    try {
      AppLogger.print('Storees Customer Upsert', customerId);
      AppLogger.logFullJson(payload);

      final response = await _dio.post(
        '/customers',
        data: payload,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.logFullJson(response.data);
        return;
      }

      AppLogger.warning(
        'Storees customer upsert failed with status ${response.statusCode}.',
      );
      if (response.data != null) {
        AppLogger.logFullJson(response.data);
      }
    } catch (error, stackTrace) {
      AppLogger.error('Storees customer upsert failed', error, stackTrace);
    }
  }

  int _cartItemCount(Cart cart) {
    return (cart.items ?? [])
        .fold<int>(0, (total, item) => total + (item.quantity ?? 0));
  }

  List<Map<String, dynamic>> _cartLineItems(List<Item>? items) {
    return (items ?? [])
        .map(
          (item) => _sanitizeMap({
            'product_id': item.productId,
            'product_name': item.productTitle ?? item.title,
            'variant_id': item.variantId,
            'variant_name': item.variantTitle,
            'unit_price': item.unitPrice,
            'quantity': item.quantity,
          }),
        )
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _orderLineItems(List<place_order.Item>? items) {
    return (items ?? [])
        .map(
          (item) => _sanitizeMap({
            'product_id': item.productId,
            'product_name': item.productTitle ?? item.title,
            'variant_id': item.variantId,
            'variant_name': item.variantTitle,
            'unit_price': item.unitPrice,
            'quantity': item.quantity,
          }),
        )
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic>? value) {
    if (value == null) {
      return {};
    }

    final sanitized = <String, dynamic>{};
    value.forEach((key, rawValue) {
      final normalized = _normalizeDynamic(rawValue);
      if (normalized != null) {
        sanitized[key] = normalized;
      }
    });
    return sanitized;
  }

  dynamic _normalizeDynamic(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (value is Map<String, dynamic>) {
      final normalizedMap = _sanitizeMap(value);
      return normalizedMap.isEmpty ? null : normalizedMap;
    }

    if (value is List) {
      final normalizedList =
          value.map(_normalizeDynamic).where((item) => item != null).toList();
      return normalizedList.isEmpty ? null : normalizedList;
    }

    return value;
  }

  String? _normalizedValue(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _buildCustomerName({String? firstName, String? lastName}) {
    final name = [firstName, lastName]
        .where((part) => _normalizedValue(part) != null)
        .join(' ')
        .trim();
    return name;
  }

  String? _readAddressField(dynamic address, List<String> keys) {
    if (address is! Map) {
      return null;
    }

    for (final key in keys) {
      final value = address[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  bool _isConfigured() {
    return AppConfig.storeesApiKey.trim().isNotEmpty &&
        AppConfig.storeesApiSecret.trim().isNotEmpty;
  }
}
