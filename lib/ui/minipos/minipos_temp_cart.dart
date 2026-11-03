import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

/// MiniPOS basket for this app process only. Nothing here is written to disk.
class MiniPosTempCart with WidgetsBindingObserver {
  MiniPosTempCart._() {
    WidgetsBinding.instance.addObserver(this);
  }
  static final MiniPosTempCart instance = MiniPosTempCart._();

  String? _accountToken;
  String _checkoutToken = _newCheckoutToken();
  int _platformFee = 0;
  final Map<String, Map<String, dynamic>> _items = {};

  static final _random = Random.secure();
  static String _newCheckoutToken() =>
      base64UrlEncode(List<int>.generate(24, (_) => _random.nextInt(256)));
  String get checkoutToken => _checkoutToken;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) clear();
  }

  Future<void> bindToCurrentAccount() async {
    final token = await SharedPreferencesUtil().getString('token');
    if (token != _accountToken) {
      clear();
      _accountToken = token;
    }
  }

  void setPlatformFee(int paise) {
    _platformFee = paise < 0 ? 0 : paise;
  }

  int get itemCount => _items.values.fold<int>(
      0, (total, item) => total + (item['imeis'] as List<String>).length);

  bool containsImei(String imei) => _items.values
      .any((item) => (item['imeis'] as List<String>).contains(imei));

  int? priceForVariant(String variantId) =>
      _items[variantId]?['unit_price'] as int?;

  void add(Map<String, dynamic> product) {
    final imei = '${product['imei'] ?? ''}'.trim();
    final variantId = '${product['variant_id'] ?? ''}'.trim();
    final price = int.tryParse('${product['selling_price'] ?? ''}');
    if (!RegExp(r'^\d{15}$').hasMatch(imei) ||
        variantId.isEmpty ||
        price == null ||
        price <= 0) {
      throw const FormatException(
          'This phone cannot be added to the cart. Scan it again.');
    }
    if (containsImei(imei)) {
      throw const FormatException('This IMEI is already in your cart.');
    }
    final item = _items.putIfAbsent(
        variantId,
        () => {
              'id': variantId,
              'product_id': product['product_id'],
              'variant_id': variantId,
              'product_title': product['product_title'],
              'variant_title': product['variant_title'],
              'thumbnail': product['thumbnail'],
              'unit_price': price,
              'imeis': <String>[],
            });
    (item['imeis'] as List<String>).add(imei);
  }

  void remove(String variantId) => _items.remove(variantId);

  void setPrice(String variantId, int paise) {
    if (paise <= 0 || !_items.containsKey(variantId)) {
      throw const FormatException('Invalid cart price.');
    }
    _items[variantId]!['unit_price'] = paise;
  }

  List<Map<String, dynamic>> checkoutItems() => [
        for (final item in _items.values)
          for (final imei in item['imeis'] as List<String>)
            {'imei': imei, 'unit_price': item['unit_price']},
      ];

  Map<String, dynamic> snapshot() {
    final items = [
      for (final item in _items.values)
        {
          ...item,
          'imeis': List<String>.from(item['imeis'] as List<String>),
          'quantity': (item['imeis'] as List<String>).length,
          'line_total': (item['unit_price'] as int) *
              (item['imeis'] as List<String>).length,
        },
    ];
    final subtotal =
        items.fold<int>(0, (sum, item) => sum + item['line_total'] as int);
    final fee = items.isEmpty ? 0 : _platformFee;
    return {
      'items': items,
      'item_count': itemCount,
      'subtotal': subtotal,
      'platform_fee': fee,
      'total': subtotal + fee,
    };
  }

  void clear() {
    _items.clear();
    _platformFee = 0;
    _checkoutToken = _newCheckoutToken();
  }
}
