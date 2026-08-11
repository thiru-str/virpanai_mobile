import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';

class DealerOrderCartPage extends StatefulWidget {
  final Map<String, dynamic> initialCart;

  const DealerOrderCartPage({super.key, required this.initialCart});

  @override
  State<DealerOrderCartPage> createState() => _DealerOrderCartPageState();
}

class _DealerOrderCartPageState extends State<DealerOrderCartPage> {
  final ApiService _api = ApiService();
  final TextEditingController _inlineCouponController = TextEditingController();
  final FocusNode _inlineCouponFocus = FocusNode();
  final GlobalKey _couponCardKey = GlobalKey();
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
  bool _couponListEnabled = true;
  bool _couponVisibilityLoaded = false;
  bool _couponChecking = false;
  bool _showInlineCouponEntry = false;
  bool _inlineCouponApplying = false;
  bool _sendingOrderOtp = false;

  @override
  void initState() {
    super.initState();
    _cart = widget.initialCart;
    _loadCartPage();
  }

  @override
  void dispose() {
    _inlineCouponController.dispose();
    _inlineCouponFocus.dispose();
    super.dispose();
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
      // Item mutations now reprice only the selected shipping method on the
      // backend. Keep the already-loaded method choices instead of blocking
      // this action on a second all-options calculation.
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

  Future<bool> _selectPaymentMethod(String providerId) async {
    final cartId = _cart['id']?.toString();
    if (cartId == null || _selectingPaymentMethodId != null) return false;
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
      return true;
    } catch (_) {
      // The shared API layer displays the backend error.
      return false;
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
    final rawAddress = _cart['shipping_address'];
    final currentAddress = rawAddress is Map ? rawAddress : const {};
    final rawMetadata = _cart['metadata'];
    final metadata = rawMetadata is Map ? rawMetadata : const {};
    await showDialog<void>(
      context: context,
      builder: (_) => _DealerAddressDialog(
        initialAddress: {
          'first_name': currentAddress['first_name'],
          'last_name': currentAddress['last_name'],
          'company': currentAddress['company'],
          'address_1': currentAddress['address_1'],
          'address_2': currentAddress['address_2'],
          'city': currentAddress['city'],
          'province': currentAddress['province'],
          'postal_code': metadata['pincode'] ?? currentAddress['postal_code'],
          'phone': metadata['dealer_customer_phone'] ?? currentAddress['phone'],
        },
        onSave: _addShippingAddress,
      ),
    );
  }

  Future<void> _showPaymentMethods() async {
    if (_paymentMethodsLoading || _paymentMethods.isEmpty) return;
    String? sheetSelectingId;
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
                final selecting = sheetSelectingId == id;
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
                  onTap: sheetSelectingId != null
                      ? null
                      : () async {
                          refresh(() => sheetSelectingId = id);
                          final updated = await _selectPaymentMethod(id);
                          if (!sheetContext.mounted) return;
                          if (updated) {
                            Navigator.pop(sheetContext);
                          } else {
                            refresh(() => sheetSelectingId = null);
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

  Future<Map<String, dynamic>> _loadCoupons() async {
    final cartId = _cart['id']?.toString();
    if (cartId == null) return const {};
    final response = await _api.getDealerOrderCoupons(context, cartId);
    if (mounted) {
      setState(() {
        _couponListEnabled = response['coupon_list_enabled'] != false;
        _couponVisibilityLoaded = true;
      });
    }
    return response;
  }

  Future<bool> _applyCoupon(String code) async {
    final cartId = _cart['id']?.toString();
    if (cartId == null) return false;
    try {
      final response = await _api.applyDealerOrderCoupon(context, cartId, code);
      if (!mounted) return false;
      final updatedCart = response['cart'];
      if (updatedCart is Map) {
        setState(() => _cart = Map<String, dynamic>.from(updatedCart));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _removeCoupon(String code) async {
    final cartId = _cart['id']?.toString();
    if (cartId == null) return false;
    try {
      final response =
          await _api.removeDealerOrderCoupon(context, cartId, code);
      if (!mounted) return false;
      final updatedCart = response['cart'];
      if (updatedCart is Map) {
        setState(() => _cart = Map<String, dynamic>.from(updatedCart));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showCoupons({Map<String, dynamic>? initialResponse}) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DealerCouponSheet(
        loadCoupons: _loadCoupons,
        applyCoupon: _applyCoupon,
        removeCoupon: _removeCoupon,
        initiallyHasAppliedCoupon: _appliedCouponCodes().isNotEmpty,
        initialResponse: initialResponse,
      ),
    );
  }

  void _openInlineCouponEntry() {
    setState(() => _showInlineCouponEntry = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _inlineCouponFocus.requestFocus();
      final cardContext = _couponCardKey.currentContext;
      if (cardContext != null) {
        Scrollable.ensureVisible(
          cardContext,
          alignment: .35,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openCouponSelector() async {
    if (_couponChecking || _inlineCouponApplying) return;
    if (_couponVisibilityLoaded &&
        !_couponListEnabled &&
        _appliedCouponCodes().isEmpty) {
      _openInlineCouponEntry();
      return;
    }

    setState(() => _couponChecking = true);
    try {
      final response = await _loadCoupons();
      if (!mounted) return;
      final hasApplied = response['has_applied_coupon'] == true;
      if (response['coupon_list_enabled'] == false && !hasApplied) {
        _openInlineCouponEntry();
      } else {
        await _showCoupons(initialResponse: response);
      }
    } catch (_) {
      // Shared API layer displays the backend error.
    } finally {
      if (mounted) setState(() => _couponChecking = false);
    }
  }

  Future<void> _submitInlineCoupon() async {
    final code = _inlineCouponController.text.trim();
    if (code.isEmpty || _inlineCouponApplying) return;
    setState(() => _inlineCouponApplying = true);
    final applied = await _applyCoupon(code);
    if (applied && mounted) {
      _inlineCouponController.clear();
      _inlineCouponFocus.unfocus();
      setState(() => _showInlineCouponEntry = false);
    }
    if (mounted) setState(() => _inlineCouponApplying = false);
  }

  List<String> _appliedCouponCodes() {
    final result = <String>[];
    final promotions = _cart['promotions'];
    if (promotions is List) {
      for (final promotion in promotions.whereType<Map>()) {
        final code = promotion['code']?.toString();
        if (code != null && code.isNotEmpty) result.add(code);
      }
    }
    final metadata = _cart['metadata'];
    final qtyTiered = metadata is Map ? metadata['qty_tiered_promo'] : null;
    if (qtyTiered is Map && qtyTiered['active'] == true) {
      final code = qtyTiered['promo_code']?.toString();
      if (code != null && code.isNotEmpty && !result.contains(code)) {
        result.add(code);
      }
    }
    return result;
  }

  Future<void> _showQuantityEditor(Map item) async {
    final variantId = item['variant_id']?.toString();
    if (variantId == null || variantId.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _DealerQuantityDialog(
        productTitle: _productTitle(item),
        initialQuantity: _integer(item['quantity']),
        onUpdate: (quantity) => _updateQuantity(variantId, quantity),
      ),
    );
  }

  Future<void> _startPlaceOrder() async {
    final cartId = _cart['id']?.toString();
    if (cartId == null || _sendingOrderOtp) return;
    setState(() => _sendingOrderOtp = true);
    try {
      final response = await _api.sendDealerOrderOtp(context, cartId);
      if (!mounted) return;
      final placed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DealerOrderOtpDialog(
          phone: response['phone']?.toString() ?? 'the customer',
          onResend: () => _api.sendDealerOrderOtp(context, cartId),
          onPlace: (otp) => _api.placeDealerOrder(context, cartId, otp),
        ),
      );
      if (placed == true && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      // Shared API layer shows the backend message.
    } finally {
      if (mounted) setState(() => _sendingOrderOtp = false);
    }
  }

  double _amount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _integer(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _productTitle(Map item) {
    final product = item['product'];
    final productMetadata = product is Map ? product['metadata'] : null;
    final displayName =
        productMetadata is Map ? productMetadata['display_name'] : null;
    return (displayName ?? item['product_title'] ?? item['title'] ?? 'Product')
        .toString();
  }

  bool _isPlatformFeeItem(dynamic rawItem) {
    if (rawItem is! Map) return false;
    final metadata = rawItem['metadata'];
    final feeType = metadata is Map
        ? (metadata['type'] ?? metadata['fee_type'])
            ?.toString()
            .trim()
            .toLowerCase()
        : null;
    if (feeType == 'platform_fee' ||
        feeType == 'platform fee' ||
        (metadata is Map && metadata['is_platform_fee'] == true)) {
      return true;
    }
    final title = (rawItem['product_title'] ?? rawItem['title'])
        ?.toString()
        .trim()
        .toLowerCase();
    return title == 'platform fee' || title == 'platform_fee';
  }

  String _money(dynamic value) => '₹${_amount(value).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final allItems = _cart['items'] as List<dynamic>? ?? [];
    final products =
        allItems.where((item) => !_isPlatformFeeItem(item)).toList();
    final platformFee = allItems.where(_isPlatformFeeItem).fold<double>(
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
    final shippingAmount = _amount(_cart['shipping_total']);
    final shippingMethods = _cart['shipping_methods'] as List<dynamic>? ?? [];
    final hasSelectedShippingMethod =
        _selectedShippingOptionId != null || shippingMethods.isNotEmpty;
    final selectedPaymentMethod =
        _paymentMethods.cast<Map<String, dynamic>?>().firstWhere(
              (method) => method?['id']?.toString() == _selectedPaymentMethodId,
              orElse: () => null,
            );
    final selectedPaymentMethodName =
        selectedPaymentMethod?['name']?.toString() ?? 'Select payment method';

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
                                _productTitle(item),
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
                _couponCard(),
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
                      if (hasSelectedShippingMethod)
                        _priceRow(
                          'Shipping',
                          shippingAmount,
                          displayValue: shippingAmount == 0 ? 'Free' : null,
                          valueColor: shippingAmount == 0
                              ? const Color(0xff059669)
                              : null,
                        ),
                      if (_amount(_cart['tax_total']) > 0)
                        _priceRow('Tax', _cart['tax_total']),
                      if (_amount(_cart['discount_total']) > 0)
                        _priceRow(
                          'Coupon',
                          -_amount(_cart['discount_total']),
                          color: const Color(0xff059669),
                        ),
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
                        onPressed: _sendingOrderOtp ||
                                !hasSelectedShippingMethod ||
                                _selectedPaymentMethodId == null
                            ? null
                            : _startPlaceOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.45),
                          disabledForegroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _sendingOrderOtp
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Place order',
                                    style: FontUtils.primaryFontStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedPaymentMethodName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FontUtils.primaryFontStyle(
                                      fontSize: 10,
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _couponCard() {
    final appliedCodes = _appliedCouponCodes();
    return Container(
      key: _couponCardKey,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _showInlineCouponEntry ? null : _openCouponSelector,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coupon',
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          )),
                      Text(
                        appliedCodes.isNotEmpty
                            ? '${appliedCodes.join(', ')} applied'
                            : _showInlineCouponEntry || !_couponListEnabled
                                ? 'Enter a coupon code'
                                : 'View available offers',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 11,
                          color: appliedCodes.isNotEmpty
                              ? const Color(0xff059669)
                              : AppColors.textColor50,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_couponChecking)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else if (_showInlineCouponEntry)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: _inlineCouponApplying
                        ? null
                        : () {
                            _inlineCouponFocus.unfocus();
                            setState(() => _showInlineCouponEntry = false);
                          },
                    icon: Icon(Icons.close,
                        size: 19, color: AppColors.textColor50),
                  )
                else
                  Icon(Icons.chevron_right, color: AppColors.textColor50),
              ],
            ),
          ),
          if (_showInlineCouponEntry) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inlineCouponController,
                    focusNode: _inlineCouponFocus,
                    cursorColor: AppColors.primary,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      color: AppColors.textColor,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    enabled: !_inlineCouponApplying,
                    onSubmitted: (_) => _submitInlineCoupon(),
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        color: AppColors.textColor50,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xfff7faf8),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 13),
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
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _inlineCouponApplying ? null : _submitInlineCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: .55),
                    disabledForegroundColor: Colors.white,
                    minimumSize: const Size(68, 46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _inlineCouponApplying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Apply',
                          style: FontUtils.primaryFontStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

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
      shippingAddress['country_code'],
      shippingAddress['phone'],
    ].every((value) => value?.toString().trim().isNotEmpty == true);
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
                ElevatedButton.icon(
                  onPressed: _showAddressEditor,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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

  Widget _priceRow(
    String label,
    dynamic value, {
    bool bold = false,
    Color? color,
    String? displayValue,
    Color? valueColor,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? AppColors.textColor,
                )),
            Text(displayValue ?? _money(value),
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? color ?? AppColors.textColor,
                )),
          ],
        ),
      );
}

class _DealerOrderOtpDialog extends StatefulWidget {
  final String phone;
  final Future<Map<String, dynamic>> Function() onResend;
  final Future<Map<String, dynamic>> Function(String otp) onPlace;

  const _DealerOrderOtpDialog({
    required this.phone,
    required this.onResend,
    required this.onPlace,
  });

  @override
  State<_DealerOrderOtpDialog> createState() => _DealerOrderOtpDialogState();
}

class _DealerOrderOtpDialogState extends State<_DealerOrderOtpDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _placing = false;
  bool _resending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    final otp = _controller.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(otp) || _placing) {
      if (!_placing) AppUtils.showToast('Enter the 6 digit OTP');
      return;
    }
    setState(() => _placing = true);
    try {
      await widget.onPlace(otp);
      if (!mounted) return;
      AppUtils.showToast('Order placed successfully');
      Navigator.of(context).pop(true);
    } catch (_) {
      // Shared API layer shows the backend message.
      if (mounted) setState(() => _placing = false);
    }
  }

  Future<void> _resend() async {
    if (_resending || _placing) return;
    setState(() => _resending = true);
    try {
      await widget.onResend();
      if (mounted) {
        _controller.clear();
        AppUtils.showToast('OTP sent to the customer');
      }
    } catch (_) {
      // Shared API layer shows the backend message.
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Verify customer OTP',
          style: FontUtils.primaryFontStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6 digit OTP sent to ${widget.phone} to place this order.',
              style: FontUtils.primaryFontStyle(
                fontSize: 12,
                color: AppColors.textColor50,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              enabled: !_placing,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ).copyWith(letterSpacing: 8),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Enter OTP',
                filled: true,
                fillColor: AppColors.secondary,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xffdce5df)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _place(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _resending || _placing ? null : _resend,
            child: _resending
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text('Resend OTP',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                    )),
          ),
          ElevatedButton(
            onPressed: _placing ? null : _place,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _placing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Verify & place order'),
          ),
        ],
      );
}

class _DealerAddressDialog extends StatefulWidget {
  final Map<String, dynamic> initialAddress;
  final Future<bool> Function(Map<String, dynamic> address) onSave;

  const _DealerAddressDialog({
    required this.initialAddress,
    required this.onSave,
  });

  @override
  State<_DealerAddressDialog> createState() => _DealerAddressDialogState();
}

class _DealerAddressDialogState extends State<_DealerAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _company = TextEditingController();
  final _address = TextEditingController();
  final _address2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postalCode = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstName.text = widget.initialAddress['first_name']?.toString() ?? '';
    _company.text = widget.initialAddress['company']?.toString() ?? '';
    _address.text = widget.initialAddress['address_1']?.toString() ?? '';
    _address2.text = widget.initialAddress['address_2']?.toString() ?? '';
    _city.text = widget.initialAddress['city']?.toString() ?? '';
    _state.text = widget.initialAddress['province']?.toString() ?? '';
    _postalCode.text = widget.initialAddress['postal_code']?.toString() ?? '';
    _phone.text = widget.initialAddress['phone']?.toString() ?? '';
  }

  @override
  void dispose() {
    _firstName.dispose();
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
      'last_name': '',
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
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
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
                  _field(_firstName, 'Name'),
                  _field(_company, 'Company (optional)', required: false),
                  _field(_address, 'Address'),
                  _field(_address2, 'Address line 2 (optional)',
                      required: false),
                  Row(
                    children: [
                      Expanded(child: _field(_city, 'City')),
                      const SizedBox(width: 10),
                      Expanded(child: _field(_state, 'State')),
                    ],
                  ),
                  _field(
                    _postalCode,
                    'Postal code',
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    validator: (value) => RegExp(r'^\d+$').hasMatch(value ?? '')
                        ? null
                        : 'Enter a valid postal code',
                  ),
                  _field(
                    _phone,
                    'Phone number',
                    readOnly: true,
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

class _DealerCouponSheet extends StatefulWidget {
  final Future<Map<String, dynamic>> Function() loadCoupons;
  final Future<bool> Function(String code) applyCoupon;
  final Future<bool> Function(String code) removeCoupon;
  final bool initiallyHasAppliedCoupon;
  final Map<String, dynamic>? initialResponse;

  const _DealerCouponSheet({
    required this.loadCoupons,
    required this.applyCoupon,
    required this.removeCoupon,
    required this.initiallyHasAppliedCoupon,
    this.initialResponse,
  });

  @override
  State<_DealerCouponSheet> createState() => _DealerCouponSheetState();
}

class _DealerCouponSheetState extends State<_DealerCouponSheet> {
  final TextEditingController _codeController = TextEditingController();
  List<Map<String, dynamic>> _coupons = [];
  bool _couponListEnabled = true;
  late bool _hasAppliedCoupon;
  bool _loading = true;
  String? _busyCode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _hasAppliedCoupon = widget.initiallyHasAppliedCoupon;
    if (widget.initialResponse != null) {
      _acceptResponse(widget.initialResponse!);
      _loading = false;
    } else {
      _reload();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    if (mounted) setState(() => _error = null);
    try {
      final response = await widget.loadCoupons();
      if (mounted) setState(() => _acceptResponse(response));
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load available coupons');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _acceptResponse(Map<String, dynamic> response) {
    final rawCoupons = response['promotions'];
    _coupons = rawCoupons is List
        ? rawCoupons
            .whereType<Map>()
            .map((coupon) => Map<String, dynamic>.from(coupon))
            .toList()
        : <Map<String, dynamic>>[];
    _couponListEnabled = response['coupon_list_enabled'] != false;
    _hasAppliedCoupon = response['has_applied_coupon'] == true;
  }

  Future<void> _apply(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty || _busyCode != null) return;
    setState(() => _busyCode = code);
    final applied = await widget.applyCoupon(code);
    if (applied) {
      _codeController.clear();
      await _reload();
    }
    if (mounted) setState(() => _busyCode = null);
  }

  Future<void> _remove(String code) async {
    if (_busyCode != null) return;
    setState(() => _busyCode = code);
    if (await widget.removeCoupon(code)) await _reload();
    if (mounted) setState(() => _busyCode = null);
  }

  @override
  Widget build(BuildContext context) {
    // Start compact while visibility is loading. Expand only after the API
    // confirms that offer discovery is enabled.
    final compact = _loading || !_couponListEnabled;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: compact
          ? (_hasAppliedCoupon ? 330.0 : 215.0)
              .clamp(0, screenHeight * .62)
              .toDouble()
          : screenHeight * .82,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text('Coupons & offers',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      )),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (!_hasAppliedCoupon)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      cursorColor: AppColors.primary,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          color: AppColors.textColor50,
                        ),
                        prefixIcon: Icon(Icons.local_offer_outlined,
                            color: AppColors.primary),
                        filled: true,
                        fillColor: const Color(0xfff7faf8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xffdfe7e2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xffdfe7e2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      onSubmitted: _apply,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _busyCode == null
                        ? () => _apply(_codeController.text)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: .55),
                      disabledForegroundColor: Colors.white,
                      minimumSize: const Size(72, 54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: FontUtils.primaryFontStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() => _loading = true);
                            _reload();
                          },
                          child: Text('$_error. Retry'),
                        ),
                      )
                    : !_couponListEnabled && _coupons.isEmpty
                        ? const SizedBox.shrink()
                        : _coupons.isEmpty
                            ? Center(
                                child: Text('No coupons available',
                                    style: FontUtils.primaryFontStyle(
                                      color: AppColors.textColor50,
                                    )))
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                itemCount: _coupons.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, index) {
                                  final coupon = _coupons[index];
                                  final code = coupon['code']?.toString() ?? '';
                                  final applied = coupon['is_applied'] == true;
                                  final eligible =
                                      coupon['is_eligible'] == true;
                                  final busy = _busyCode == code;
                                  final green = const Color(0xff059669);
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: applied
                                          ? green.withValues(alpha: .06)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: applied
                                            ? green.withValues(alpha: .35)
                                            : const Color(0xffe5e7eb),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(code,
                                                        style: FontUtils
                                                            .primaryFontStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: applied
                                                              ? green
                                                              : AppColors
                                                                  .textColor,
                                                        )),
                                                  ),
                                                  if (applied) ...[
                                                    const SizedBox(width: 6),
                                                    Icon(Icons.check_circle,
                                                        color: green, size: 16),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                  (coupon['title'] ?? 'Coupon')
                                                      .toString(),
                                                  style: FontUtils
                                                      .primaryFontStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textColor,
                                                  )),
                                              const SizedBox(height: 3),
                                              Text(
                                                (coupon['description'] ?? '')
                                                    .toString(),
                                                style:
                                                    FontUtils.primaryFontStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textColor50,
                                                ),
                                              ),
                                              if (!eligible &&
                                                  !applied &&
                                                  coupon['ineligibility_reason'] !=
                                                      null) ...[
                                                const SizedBox(height: 5),
                                                Text(
                                                  coupon['ineligibility_reason']
                                                      .toString(),
                                                  style: FontUtils
                                                      .primaryFontStyle(
                                                    fontSize: 11,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ],
                                              if (coupon[
                                                      'estimated_discount_display'] !=
                                                  null) ...[
                                                const SizedBox(height: 5),
                                                Text(
                                                  coupon['estimated_discount_display']
                                                      .toString(),
                                                  style: FontUtils
                                                      .primaryFontStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: green,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        busy
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primary,
                                                ),
                                              )
                                            : TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: applied
                                                      ? Colors.redAccent
                                                      : AppColors.primary,
                                                ),
                                                onPressed: applied
                                                    ? () => _remove(code)
                                                    : eligible
                                                        ? () => _apply(code)
                                                        : null,
                                                child: Text(
                                                  applied ? 'Remove' : 'Apply',
                                                  style: FontUtils
                                                      .primaryFontStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: applied
                                                        ? Colors.redAccent
                                                        : eligible
                                                            ? AppColors.primary
                                                            : AppColors
                                                                .textColor50,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
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
