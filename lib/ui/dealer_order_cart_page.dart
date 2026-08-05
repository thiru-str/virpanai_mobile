import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class DealerOrderCartPage extends StatefulWidget {
  final Map<String, dynamic> initialCart;

  const DealerOrderCartPage({super.key, required this.initialCart});

  @override
  State<DealerOrderCartPage> createState() => _DealerOrderCartPageState();
}

class _DealerOrderCartPageState extends State<DealerOrderCartPage> {
  final ApiService _api = ApiService();
  late Map<String, dynamic> _cart;
  String? _updatingVariantId;
  List<Map<String, dynamic>> _shippingOptions = [];
  String? _selectedShippingOptionId;
  String? _selectingShippingOptionId;
  bool _shippingLoading = true;
  String? _shippingError;
  List<Map<String, dynamic>> _paymentMethods = [];
  String? _selectedPaymentMethodId;
  String? _selectingPaymentMethodId;
  bool _paymentMethodsLoading = true;
  String? _paymentMethodsError;

  @override
  void initState() {
    super.initState();
    _cart = widget.initialCart;
    _loadCartPage();
  }

  Future<void> _loadCartPage() async {
    // Retain the settled cart read for promotion/pricing correctness, but run
    // independent method requests alongside it instead of serially afterward.
    await Future.wait([
      _refreshCart(),
      _loadShippingOptions(),
      _loadPaymentMethods(),
    ]);
  }

  Future<void> _refreshCart() async {
    final cartId = _cart['id']?.toString();
    if (cartId == null) return;
    try {
      final response = await _api.getDealerOrderCart(context, cartId);
      if (mounted) {
        setState(
            () => _cart = Map<String, dynamic>.from(response['cart'] ?? _cart));
      }
    } catch (_) {
      // Shared API layer displays the backend error.
    }
  }

  Future<bool> _updateQuantity(String variantId, int quantity) async {
    final cartId = _cart['id']?.toString();
    if (cartId == null || !mounted) return false;
    setState(() => _updatingVariantId = variantId);
    try {
      final response = await _api.updateDealerOrderItemQuantity(
          context, cartId, variantId, quantity);
      if (!mounted) return false;
      setState(() {
        final updatedCart = response['cart'];
        if (updatedCart is Map) {
          _cart = Map<String, dynamic>.from(updatedCart);
        }
        final rawOptions = response['shipping_options'];
        if (rawOptions is List) {
          _shippingOptions = rawOptions
              .whereType<Map>()
              .map((option) => Map<String, dynamic>.from(option))
              .toList();
          _selectedShippingOptionId =
              response['selected_shipping_option_id']?.toString();
        }
      });
      if (response['shipping_options'] is! List) {
        await _loadShippingOptions();
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      if (mounted) setState(() => _updatingVariantId = null);
    }
  }

  Future<void> _loadShippingOptions() async {
    final cartId = _cart['id']?.toString();
    if (cartId == null || !mounted) return;
    setState(() {
      _shippingLoading = true;
      _shippingError = null;
    });
    try {
      final response =
          await _api.getDealerOrderShippingOptions(context, cartId);
      final rawOptions = response['shipping_options'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _shippingOptions = rawOptions
            .whereType<Map>()
            .map((option) => Map<String, dynamic>.from(option))
            .toList();
        _selectedShippingOptionId =
            response['selected_shipping_option_id']?.toString();
      });
    } catch (_) {
      if (mounted) {
        setState(() => _shippingError = 'Could not load delivery methods');
      }
    } finally {
      if (mounted) setState(() => _shippingLoading = false);
    }
  }

  Future<void> _selectShippingMethod(String optionId) async {
    final cartId = _cart['id']?.toString();
    if (cartId == null || _selectingShippingOptionId != null) return;
    setState(() => _selectingShippingOptionId = optionId);
    try {
      final response =
          await _api.selectDealerOrderShippingMethod(context, cartId, optionId);
      if (mounted) {
        setState(() {
          final updatedCart = response['cart'];
          if (updatedCart is Map) {
            _cart = Map<String, dynamic>.from(updatedCart);
          }
          _selectedShippingOptionId = optionId;
        });
      }
    } catch (_) {
      // The shared API layer displays the backend error.
    } finally {
      if (mounted) setState(() => _selectingShippingOptionId = null);
    }
  }

  Future<void> _loadPaymentMethods() async {
    final cartId = _cart['id']?.toString();
    if (cartId == null || !mounted) return;
    setState(() {
      _paymentMethodsLoading = true;
      _paymentMethodsError = null;
    });
    try {
      final response = await _api.getDealerOrderPaymentMethods(context, cartId);
      final rawMethods = response['payment_methods'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _paymentMethods = rawMethods
            .whereType<Map>()
            .map((method) => Map<String, dynamic>.from(method))
            .toList();
        _selectedPaymentMethodId =
            response['selected_payment_method_id']?.toString();
      });
    } catch (_) {
      if (mounted) {
        setState(() => _paymentMethodsError = 'Could not load payment methods');
      }
    } finally {
      if (mounted) setState(() => _paymentMethodsLoading = false);
    }
  }

  Future<void> _selectPaymentMethod(String providerId) async {
    final cartId = _cart['id']?.toString();
    if (cartId == null || _selectingPaymentMethodId != null) return;
    setState(() => _selectingPaymentMethodId = providerId);
    try {
      final response = await _api.selectDealerOrderPaymentMethod(
          context, cartId, providerId);
      if (mounted) {
        setState(() {
          final updatedCart = response['cart'];
          if (updatedCart is Map) {
            _cart = Map<String, dynamic>.from(updatedCart);
          }
          _selectedPaymentMethodId = providerId;
        });
      }
    } catch (_) {
      // The shared API layer displays the backend error.
    } finally {
      if (mounted) setState(() => _selectingPaymentMethodId = null);
    }
  }

  Future<bool> _addShippingAddress(Map<String, dynamic> address) async {
    final cartId = _cart['id']?.toString();
    if (cartId == null) return false;
    try {
      final response =
          await _api.addDealerOrderShippingAddress(context, cartId, address);
      if (!mounted) return false;
      final updatedCart = response['cart'];
      if (updatedCart is Map) {
        setState(() => _cart = Map<String, dynamic>.from(updatedCart));
      }
      await _loadShippingOptions();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showAddressEditor() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DealerAddressDialog(onSave: _addShippingAddress),
    );
  }

  Future<void> _showPaymentMethods() async {
    if (_paymentMethodsLoading || _paymentMethods.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (_, refresh) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffd1d5db),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Select payment method',
                  style: FontUtils.primaryFontStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  )),
              const SizedBox(height: 12),
              ..._paymentMethods.map((method) {
                final id = method['id']?.toString() ?? '';
                final selected = _selectedPaymentMethodId == id;
                final selecting = _selectingPaymentMethodId == id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_paymentIcon(id),
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text((method['name'] ?? 'Payment method').toString(),
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      )),
                  subtitle:
                      (method['description']?.toString().isNotEmpty ?? false)
                          ? Text(method['description'].toString(),
                              style: FontUtils.primaryFontStyle(
                                fontSize: 11,
                                color: AppColors.textColor50,
                              ))
                          : null,
                  trailing: selecting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        )
                      : Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textColor50,
                        ),
                  onTap: _selectingPaymentMethodId != null
                      ? null
                      : () async {
                          await _selectPaymentMethod(id);
                          refresh(() {});
                          if (mounted &&
                              _selectedPaymentMethodId == id &&
                              sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuantityEditor(Map item) async {
    final variantId = item['variant_id']?.toString();
    if (variantId == null || variantId.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _DealerQuantityDialog(
        productTitle:
            (item['product_title'] ?? item['title'] ?? 'Cart item').toString(),
        initialQuantity: _integer(item['quantity']),
        onUpdate: (quantity) => _updateQuantity(variantId, quantity),
      ),
    );
  }

  double _amount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _integer(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _money(dynamic value) => '₹${_amount(value).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final allItems = _cart['items'] as List<dynamic>? ?? [];
    final products = allItems
        .where((item) => (item as Map)['metadata']?['type'] != 'platform_fee')
        .toList();
    final platformFee = allItems
        .where((item) => (item as Map)['metadata']?['type'] == 'platform_fee')
        .fold<double>(
          0,
          (sum, item) =>
              sum +
              _amount((item as Map)['total'] ??
                  item['subtotal'] ??
                  item['unit_price']),
        );
    final metadata = _cart['metadata'] as Map? ?? {};
    final wallet =
        _amount((metadata['wallet_split'] as Map?)?['wallet_amount']);
    final loyalty = _amount(
        (metadata['loyalty_checkout_apply'] as Map?)?['discount_amount']);

    return Scaffold(
      backgroundColor: const Color(0xfff5faf5),
      appBar: AppBar(
        backgroundColor: const Color(0xfff5faf5),
        elevation: 0,
        centerTitle: true,
        title: Text('Cart',
            style: FontUtils.primaryFontStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            )),
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 52, color: AppColors.textColor50),
                  const SizedBox(height: 12),
                  Text('Your cart is empty',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      )),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                _deliveryAddressCard(),
                const SizedBox(height: 12),
                ...products.map((raw) {
                  final item = raw as Map;
                  final variantId = item['variant_id']?.toString();
                  final updating = _updatingVariantId == variantId;
                  final quantity = _integer(item['quantity']);
                  final variantTitle = item['variant_title']?.toString() ?? '';
                  final isDefault =
                      variantTitle.toLowerCase() == 'default variant';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0d000000), blurRadius: 10)
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: item['thumbnail'] == null
                              ? const Icon(Icons.inventory_2_outlined)
                              : Image.network(
                                  item['thumbnail'].toString(),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.inventory_2_outlined),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (item['product_title'] ??
                                        item['title'] ??
                                        'Product')
                                    .toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              if (!isDefault) ...[
                                const SizedBox(height: 3),
                                Text(variantTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: FontUtils.primaryFontStyle(
                                      fontSize: 11,
                                      color: AppColors.textColor50,
                                    )),
                              ],
                              const SizedBox(height: 9),
                              InkWell(
                                onTap: updating
                                    ? null
                                    : () => _showQuantityEditor(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11, vertical: 7),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: updating
                                      ? const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : Text('Qty $quantity',
                                          style: FontUtils.primaryFontStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _money(item['total'] ??
                                  item['subtotal'] ??
                                  _amount(item['unit_price']) * quantity),
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            IconButton(
                              onPressed: updating || variantId == null
                                  ? null
                                  : () => _updateQuantity(variantId, 0),
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent, size: 21),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                _optionCard(Icons.local_offer_outlined, 'Coupon',
                    'Automatic eligible promotions apply'),
                _paymentMethodCard(),
                _shippingMethodCard(),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price details',
                          style: FontUtils.primaryFontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          )),
                      const SizedBox(height: 14),
                      _priceRow(
                          'Subtotal', _cart['subtotal'] ?? _cart['item_total']),
                      if (_amount(_cart['shipping_total']) > 0)
                        _priceRow('Shipping', _cart['shipping_total']),
                      if (_amount(_cart['tax_total']) > 0)
                        _priceRow('Tax', _cart['tax_total']),
                      if (_amount(_cart['discount_total']) > 0)
                        _priceRow('Promotion discount',
                            -_amount(_cart['discount_total'])),
                      if (platformFee > 0)
                        _priceRow('Platform fee', platformFee),
                      if (wallet > 0) _priceRow('Wallet', -wallet),
                      if (loyalty > 0) _priceRow('Loyalty', -loyalty),
                      const Divider(height: 26),
                      _priceRow('Total amount', _cart['total'], bold: true),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: products.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Color(0x16000000), blurRadius: 12)
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_money(_cart['total']),
                              style: FontUtils.primaryFontStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              )),
                          Text('Total amount',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 11,
                                color: AppColors.textColor50,
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Proceed to checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _optionCard(IconData icon, String title, String subtitle) => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      )),
                  Text(subtitle,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 11,
                        color: AppColors.textColor50,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textColor50),
          ],
        ),
      );

  IconData _paymentIcon(String providerId) {
    if (providerId == 'pp_system_default') return Icons.payments_outlined;
    if (providerId.contains('neft') || providerId.contains('icici')) {
      return Icons.account_balance_outlined;
    }
    return Icons.credit_card_outlined;
  }

  Widget _deliveryAddressCard() {
    final address = _cart['shipping_address'];
    final shippingAddress = address is Map ? address : const {};
    final hasAddress = [
      shippingAddress['address_1'],
      shippingAddress['city'],
      shippingAddress['postal_code'],
    ].any((value) => value?.toString().trim().isNotEmpty == true);
    final name = [
      shippingAddress['first_name'],
      shippingAddress['last_name'],
    ].where((value) => value?.toString().trim().isNotEmpty == true).join(' ');
    final addressLine = [
      shippingAddress['address_1'],
      shippingAddress['address_2'],
      shippingAddress['city'],
      shippingAddress['province'],
      shippingAddress['postal_code'],
    ].where((value) => value?.toString().trim().isNotEmpty == true).join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: hasAddress
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery address',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    )),
                if (name.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(name,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      )),
                ],
                const SizedBox(height: 2),
                Text(addressLine,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 11,
                      color: AppColors.textColor,
                    )),
              ],
            )
          : Row(
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Add a delivery address to continue',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      )),
                ),
                TextButton.icon(
                  onPressed: _showAddressEditor,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add address'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
    );
  }

  Widget _paymentMethodCard() => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          onTap: _showPaymentMethods,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xffe9f3ff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment method',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        )),
                    Text(
                      _paymentMethodsLoading
                          ? 'Loading methods...'
                          : _paymentMethodsError != null
                              ? _paymentMethodsError!
                              : (_paymentMethods.firstWhere(
                                        (method) =>
                                            method['id']?.toString() ==
                                            _selectedPaymentMethodId,
                                        orElse: () => const <String, dynamic>{},
                                      )['name'] ??
                                      'Select payment method')
                                  .toString(),
                      style: FontUtils.primaryFontStyle(
                        fontSize: 11,
                        color: _paymentMethodsError == null
                            ? AppColors.textColor50
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              if (_paymentMethodsLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                )
              else
                Icon(Icons.chevron_right, color: AppColors.textColor50),
            ],
          ),
        ),
      );

  Widget _shippingMethodCard() => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text('Delivery method',
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                )),
            const SizedBox(width: 12),
            if (_shippingLoading)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                ),
              )
            else if (_shippingError != null)
              Expanded(
                child: TextButton(
                  onPressed: _loadShippingOptions,
                  child: const Text('Retry'),
                ),
              )
            else if (_shippingOptions.isEmpty)
              Expanded(
                child: Text('No methods available',
                    textAlign: TextAlign.end,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 11,
                      color: AppColors.textColor50,
                    )),
              )
            else
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: _shippingOptions.map((option) {
                      final id = option['id']?.toString() ?? '';
                      final selecting = _selectingShippingOptionId == id;
                      final selected = _selectedShippingOptionId == id;
                      return InkWell(
                        onTap: _selectingShippingOptionId == null
                            ? () => _selectShippingMethod(id)
                            : null,
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.secondary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: selecting
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  (option['name'] ?? 'Delivery').toString(),
                                  style: FontUtils.primaryFontStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textColor,
                                  ),
                                ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _priceRow(String label, dynamic value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textColor,
                )),
            Text(_money(value),
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: AppColors.textColor,
                )),
          ],
        ),
      );
}

class _DealerAddressDialog extends StatefulWidget {
  final Future<bool> Function(Map<String, dynamic> address) onSave;

  const _DealerAddressDialog({required this.onSave});

  @override
  State<_DealerAddressDialog> createState() => _DealerAddressDialogState();
}

class _DealerAddressDialogState extends State<_DealerAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _company = TextEditingController();
  final _address = TextEditingController();
  final _address2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postalCode = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _company.dispose();
    _address.dispose();
    _address2.dispose();
    _city.dispose();
    _state.dispose();
    _postalCode.dispose();
    _phone.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value?.trim().isEmpty == false ? null : 'This field is required';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final saved = await widget.onSave({
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'company': _company.text.trim(),
      'address_1': _address.text.trim(),
      'address_2': _address2.text.trim(),
      'city': _city.text.trim(),
      'province': _state.text.trim(),
      'postal_code': _postalCode.text.trim(),
      'country_code': 'in',
      'phone': _phone.text.trim(),
    });
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xfff7faf8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: AppColors.primary,
          decoration: _decoration(label),
          validator: validator ?? (required ? _required : null),
        ),
      );

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add delivery address',
            style: FontUtils.primaryFontStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            )),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: _field(_firstName, 'First name')),
                      const SizedBox(width: 10),
                      Expanded(child: _field(_lastName, 'Last name')),
                    ],
                  ),
                  _field(_company, 'Company (optional)', required: false),
                  _field(_address, 'Address'),
                  _field(_address2, 'Address line 2 (optional)',
                      required: false),
                  Row(
                    children: [
                      Expanded(child: _field(_city, 'City')),
                      const SizedBox(width: 10),
                      Expanded(child: _field(_state, 'State', required: false)),
                    ],
                  ),
                  _field(
                    _postalCode,
                    'Postal code',
                    keyboardType: TextInputType.number,
                    validator: (value) => RegExp(r'^\d+$').hasMatch(value ?? '')
                        ? null
                        : 'Enter a valid postal code',
                  ),
                  _field(
                    _phone,
                    'Phone number',
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        RegExp(r'^\d{10}$').hasMatch(value ?? '')
                            ? null
                            : 'Enter a 10 digit phone number',
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save address'),
          ),
        ],
      );
}

class _DealerQuantityDialog extends StatefulWidget {
  final String productTitle;
  final int initialQuantity;
  final Future<bool> Function(int quantity) onUpdate;

  const _DealerQuantityDialog({
    required this.productTitle,
    required this.initialQuantity,
    required this.onUpdate,
  });

  @override
  State<_DealerQuantityDialog> createState() => _DealerQuantityDialogState();
}

class _DealerQuantityDialogState extends State<_DealerQuantityDialog> {
  late final TextEditingController _controller;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialQuantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final quantity = int.tryParse(_controller.text.trim());
    if (quantity == null || quantity < 0) {
      setState(() => _error = 'Enter a valid whole quantity (0 or more)');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final updated = await widget.onUpdate(quantity);
    if (!mounted) return;
    if (updated) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        contentPadding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
        actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Text(
          'Update quantity',
          style: FontUtils.primaryFontStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.productTitle,
              style: FontUtils.primaryFontStyle(
                fontSize: 14,
                color: AppColors.textColor50,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              cursorColor: AppColors.primary,
              style: FontUtils.primaryFontStyle(
                fontSize: 15,
                color: AppColors.textColor,
              ),
              decoration: InputDecoration(
                labelText: 'Quantity',
                helperText: 'Enter 0 to remove this item',
                errorText: _error,
                labelStyle: FontUtils.primaryFontStyle(
                  color: AppColors.textColor50,
                ),
                helperStyle: FontUtils.primaryFontStyle(
                  fontSize: 12,
                  color: AppColors.textColor50,
                ),
                filled: true,
                fillColor: const Color(0xfff7faf8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xffdfe7e2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xffdfe7e2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(
              'Cancel',
              style: FontUtils.primaryFontStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: .55),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Update',
                    style: FontUtils.primaryFontStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      );
}
