import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/ui/widgets/calculation_bottom_sheet.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/coupon_bottom_sheet.dart';
import 'package:waioz/ui/widgets/custom_popup_widget.dart';
import 'package:waioz/ui/widgets/delivery_address_widget.dart';
import 'package:waioz/ui/widgets/login_prompt.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/payment_method_bottom_sheet.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../model/home_page_response.dart';
import '../model/register_response.dart' as RegisterResponse;
import 'package:waioz/model/check_out_shipping_address_model.dart' as CheckOut;
import '../model/wallet_response.dart';
import '../utility/app_config.dart';
import '../utility/currency_util.dart';
import '../utility/shared_preferences_util.dart';
import 'address_list_page.dart';
import 'order_placed_page.dart';

class CartPage extends StatefulWidget {
  final bool isFromBottomNav;

  const CartPage({super.key, this.isFromBottomNav = false});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  CartResponse? cartResponse;
  bool apiLoading = true;
  bool cartLoading = false;
  bool addressLoading = false;
  bool isAnimating = false;

  bool isLoggedIn = false;

  Global? global;
  List<PaymentProvider> paymentProviders = [];
  String? pp_id;
  String? orderId;
  String? clientSecret;
  Razorpay razorpay = Razorpay();
  bool showPriceBreakdown = false;

  // Wallet split state
  bool splitActive = false;
  double splitWalletAmount = 0;
  double splitGatewayAmount = 0;
  bool splitFullCoverage = false;
  bool isSplitPaymentMode = false;
  double walletBalance = 0;
  bool walletToggling = false;
  bool walletAutoApply = true;
  bool allowCouponWithWallet = true;
  WalletUsageLimit? walletUsageLimit;

  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final GlobalKey _priceDetailsSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    AppUtils.isLoggedIn().then((value) {
      setState(() {
        isLoggedIn = value;
      });
    });

    initGlobal();
    getCartApi();
  }

  Future<void> initGlobal() async {
    var global = await getGlobal();

    if (global?.paymentProvider != null) {
      setState(() {
        paymentProviders = global!.paymentProvider!;
      });
    }
    getCustomerInfo();
  }

  Future<Global?> getGlobal() async {
    dynamic global = await SharedPreferencesUtil().getMap('global');
    if (global != null) {
      return Global.fromJson(global);
    }
    return null;
  }

  RegisterResponse.Customer? customer;
  Future<void> getCustomerInfo() async {
    customer = await getCustomerResponse();
    if (customer != null) {
      setState(() {
        customer;
      });
    }
  }

  Future<RegisterResponse.Customer?> getCustomerResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('customer');
    if (userData != null) {
      return RegisterResponse.Customer.fromJson(userData);
    }
    return null;
  }

  String _getProviderName(String? providerId, List<PaymentProvider> providers) {
    if (providerId == null) return AppStrings.cash_on_delivery;

    final match = providers.firstWhere(
      (p) => p.id == providerId,
      orElse: () =>
          PaymentProvider(id: providerId, name: AppStrings.cash_on_delivery),
    );
    return match.name ?? AppStrings.cash_on_delivery;
  }

  String _getProviderKey(String? providerId, List<PaymentProvider> providers) {
    if (providerId == null) return AppConfig.razorPayKey;

    final match = providers.firstWhere(
      (p) => p.id == providerId,
      orElse: () =>
          PaymentProvider(id: providerId, apiKey: AppConfig.razorPayKey),
    );
    return match.apiKey ?? AppConfig.razorPayKey;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _scrollToPriceDetails() {
    final ctx = _priceDetailsSectionKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    final isVisible = pos.dy >= 0 && pos.dy + box.size.height <= screenH - 80;
    if (isVisible) {
      _shakeController.forward(from: 0.0);
    } else {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeaderAppBar(
        title: AppStrings.cart,
        leading: widget.isFromBottomNav ? false : true,
        onBackTap: () {
          Navigator.pop(context, true);
        },
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          apiLoading
          ? const CartPageSkeleton()
          : cartResponse?.cart?.items?.isNotEmpty ?? false
              ? Scaffold(
                  backgroundColor: Colors.white,
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                      Visibility(
                        visible: cartResponse!.cart!.items!.isNotEmpty,
                        child: AppReveal(
                          child: DeliveryAddressWidget(
                            address: _buildShippingAddress(cartResponse),
                            label: null,
                            isLoading: addressLoading,
                            onAddAddress: () {
                              PageRouteUtils.pushWithSlide(
                                  context,
                                  AddressListPage(
                                    isFromCheckout: true,
                                    onSelectedAddress: (address) {
                                      setState(() {
                                        addressLoading = true;
                                      });
                                      updateAddress(address);
                                    },
                                  ));
                            },
                            onChangeAddress: () {
                              PageRouteUtils.pushWithSlide(
                                  context,
                                  AddressListPage(
                                    isFromCheckout: true,
                                    onSelectedAddress: (address) {
                                      setState(() {
                                        addressLoading = true;
                                      });
                                      updateAddress(address);
                                    },
                                  ));
                            },
                          ),
                        ),
                      ),
                      Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: cartResponse!.cart!.items!.where((item) => !item.isPlatformFee).length,
                                  itemBuilder: (context, index) {
                                    final productItems = cartResponse!.cart!.items!.where((item) => !item.isPlatformFee).toList();
                                    final cartItem = productItems[index];
                                    final originalIndex = cartResponse!.cart!.items!.indexOf(cartItem);
                                    return AppReveal(
                                      index: index,
                                      child: CartItemCard(
                                        imageUrl: cartItem.thumbnail ?? '',
                                        productName: cartItem.productTitle!,
                                        error: cartItem.error ?? '',
                                        size: cartItem.variantTitle! ==
                                                "Default variant"
                                            ? ""
                                            : cartItem.variantTitle!,
                                        color: 'color',
                                        price: CurrencyUtil.appendCurrency(
                                            (cartItem.unitPrice! *
                                                    cartItem.quantity!)
                                                .toStringAsFixed(2)),
                                        quantity: cartItem.quantity!,
                                        isUpdating: cartItem.isUpdating!,
                                        onRemoveAll: () {
                                          setState(() {
                                            cartResponse!.cart!.items![originalIndex]
                                                .isUpdating = true;
                                          });
                                          removeCart(cartItem.id!, originalIndex);
                                        },
                                        onIncrease: () {
                                          setState(() {
                                            cartResponse!.cart!.items![originalIndex]
                                                .isUpdating = true;
                                          });
                                          updateCart(cartItem.quantity! + 1,
                                              cartItem.id!, originalIndex);
                                        },
                                        onDecrease: () async {
                                          final item =
                                              cartResponse!.cart!.items![originalIndex];
                                          final currentQty = item.quantity ?? 0;
                                          final stockQty =
                                              item.inventoryQuantity ?? 0;

                                          setState(
                                              () => item.isUpdating = true);

                                          if (currentQty <= 1) {
                                            removeCart(item.id!, originalIndex);
                                            return;
                                          }

                                          if (!(item.inStock ?? false)) {
                                            if (stockQty == 0) {
                                              removeCart(item.id!, originalIndex);
                                              return;
                                            }

                                            if (currentQty > stockQty) {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: Text(
                                                    AppStrings.stock_update,
                                                    style: FontUtils
                                                        .primaryFontStyle(
                                                            color: AppColors
                                                                .primary,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  content: Text(
                                                    '${AppStrings.stock_update_message_prefix} $stockQty in stock. '
                                                    '${AppStrings.stock_update_message_suffix} $stockQty?',
                                                    style: FontUtils
                                                        .secondaryFontStyle(),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child: Text(
                                                        AppStrings.cancel,
                                                        style: FontUtils
                                                            .primaryFontStyle(
                                                                color: AppColors
                                                                    .primary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: Text(
                                                        AppStrings.yes_update,
                                                        style: FontUtils
                                                            .primaryFontStyle(
                                                                color: AppColors
                                                                    .primary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmed == true) {
                                                updateCart(
                                                    stockQty, item.id!, originalIndex);
                                              } else {
                                                setState(() =>
                                                    item.isUpdating = false);
                                              }
                                              return;
                                            }
                                          }

                                          updateCart(
                                              currentQty - 1, item.id!, originalIndex);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                      // Wallet Card (Myntra style)
                      if (isSplitPaymentMode && isLoggedIn && walletBalance > 0)
                        _buildWalletCard(),

                      // Coupon Card (Ajio style)
                      _buildCouponCard(),

                      // Payment Method Card
                      _buildPaymentMethodCard(),

                      // Price Details (view only)
                      AppReveal(
                        index: 3,
                        child: AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          ),
                          child: Container(
                          key: _priceDetailsSectionKey,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Price Details',
                                  style: FontUtils.primaryFontStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              _priceRow(AppStrings.subTotal, CurrencyUtil.appendCurrency(
                                (_numOrZero(cartResponse?.cart?.itemSubtotal) -
                                    _numOrZero(cartResponse?.cart?.items
                                        ?.where((item) => item.isPlatformFee)
                                        .fold<num>(0, (sum, item) => sum + (item.total ?? 0))))
                                    .toStringAsFixed(2))),
                              _priceRow(AppStrings.shipping,
                                  _numOrZero(cartResponse?.cart?.shippingSubtotal) > 0
                                      ? CurrencyUtil.appendCurrency(_numOrZero(cartResponse?.cart?.shippingSubtotal).toStringAsFixed(2))
                                      : 'FREE'),
                              if ((cartResponse?.cart?.items?.any((item) => item.isPlatformFee) ?? false) &&
                                  (cartResponse!.cart!.items!.firstWhere((item) => item.isPlatformFee).total ?? 0) > 0)
                                _priceRow(AppStrings.platform_fee, CurrencyUtil.appendCurrency(
                                    (cartResponse!.cart!.items!.firstWhere((item) => item.isPlatformFee).total ?? 0).toStringAsFixed(2))),
                              if (_numOrZero(cartResponse?.cart?.taxTotal) > 0)
                                _priceRow(AppStrings.tax, CurrencyUtil.appendCurrency(
                                    _numOrZero(cartResponse?.cart?.taxTotal).toStringAsFixed(2))),
                              if ((cartResponse?.cart?.promotions ?? []).isNotEmpty &&
                                  _numOrZero(cartResponse?.cart?.discountSubtotal) > 0)
                                _priceRow(
                                  'Coupon Savings',
                                  '- ${CurrencyUtil.appendCurrency(_numOrZero(cartResponse?.cart?.discountSubtotal).toStringAsFixed(2))}',
                                  valueColor: Colors.green.shade700,
                                ),
                              if (splitActive && splitWalletAmount > 0)
                                _priceRow(
                                  'Wallet',
                                  '- ${CurrencyUtil.appendCurrency(splitWalletAmount.toStringAsFixed(2))}',
                                  valueColor: Colors.blue.shade700,
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Divider(color: Colors.grey.shade300, height: 1),
                              ),
                              _priceRow('Total Amount', CurrencyUtil.appendCurrency(
                                (splitActive
                                    ? (_numOrZero(cartResponse?.cart?.total) - splitWalletAmount).clamp(0, double.infinity)
                                    : _numOrZero(cartResponse?.cart?.total))
                                    .toStringAsFixed(2)),
                                isBold: true, fontSize: 13),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                        ),
                      ),
                      const SizedBox(height: 80),
                      ],
                    ),
                  ),
                  bottomNavigationBar: SafeArea(
                    child: _buildAjioBottomBar(),
                  ),
                )
              : Center(
                  child: isLoggedIn
                      ? NoOrdersWidget(
                          message: AppStrings.cart_empty,
                          buttonText: AppStrings.explore_categories,
                          iconPath: AppAssets.ic_cart_empty,
                          showExplore: (widget.isFromBottomNav),
                          onButtonTap: () {
                            eventBus.fire(TabSwitchEvent(1));
                          })
                      : LoginPrompt(
                          onButtonPressed: () {
                            PageRouteUtils.push(
                                context, const PhoneNumberPage());
                          },
                        )),
          // Confetti overlay — full width spread
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.08,
              numberOfParticles: 30,
              gravity: 0.15,
              shouldLoop: false,
              minimumSize: const Size(3, 3),
              maximumSize: const Size(8, 8),
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.red,
                Colors.yellow,
                Colors.teal,
                Colors.amber,
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: apiLoading
          ? const SafeArea(
              child: SizedBox(
                height: 80,
                child: CartFooterSkeleton(),
              ),
            )
          : null,
    );
  }

  // ===== Wallet Methods =====

  Future<void> _loadWalletInfo() async {
    final loggedIn = await AppUtils.isLoggedIn();
    if (!loggedIn) return;
    try {
      final walletData = await ApiService().getWalletBalance(context);
      if (!mounted) return;
      final balance = walletData.wallet?.balance ?? 0;
      final mode = walletData.walletMode ?? 'full_payment';
      final autoApply = walletData.autoApplyWallet;

      setState(() {
        walletBalance = balance;
        isSplitPaymentMode = mode == 'split_payment';
        walletAutoApply = autoApply;
        allowCouponWithWallet = walletData.allowCouponWithWallet;
        walletUsageLimit = walletData.walletUsageLimit;
      });

      // Auto-apply if enabled, cart exists, and customer hasn't dismissed
      final isDismissed = (cartResponse?.cart?.metadata as Map?)
          ?['wallet_auto_apply_dismissed'] == true;
      if (isSplitPaymentMode && autoApply && balance > 0 &&
          cartResponse?.cart?.id != null && !isDismissed) {
        await _applyWalletSplit();
      }
    } catch (e) {
      debugPrint('Wallet load error: $e');
    }
  }

  Future<void> _applyWalletSplit() async {
    if (cartResponse?.cart?.id == null) return;
    setState(() => walletToggling = true);
    try {
      final result = await ApiService().applyWalletSplit(context, cartResponse!.cart!.id!);
      if (!mounted) return;
      if (result.walletApplied) {
        setState(() {
          splitActive = true;
          splitWalletAmount = result.walletAmount;
          splitGatewayAmount = result.gatewayAmount;
          splitFullCoverage = result.fullWalletCoverage;
        });
        _confettiController.play();
      }
    } catch (e) {
      debugPrint('Apply wallet split error: $e');
    } finally {
      if (mounted) setState(() => walletToggling = false);
    }
  }

  Future<void> _removeWalletSplit() async {
    if (cartResponse?.cart?.id == null) return;
    setState(() => walletToggling = true);
    try {
      await ApiService().removeWalletSplit(context, cartResponse!.cart!.id!);
      if (!mounted) return;
      setState(() {
        splitActive = false;
        splitWalletAmount = 0;
        splitGatewayAmount = 0;
        splitFullCoverage = false;
      });
    } catch (e) {
      debugPrint('Remove wallet split error: $e');
    } finally {
      if (mounted) setState(() => walletToggling = false);
    }
  }

  Future<void> _toggleWalletSplit() async {
    if (splitActive) {
      await _removeWalletSplit();
    } else {
      await _applyWalletSplit();
    }
  }

  void getCartApi() async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      emitEvent(cartResponse!);
      setState(() {
        pp_id = cartResponse?.cart?.paymentCollection?.paymentSessions
                ?.firstOrNull?.providerId ??
            'pp_system_default';
        orderId = cartResponse?.cart?.paymentCollection?.paymentSessions
                ?.firstOrNull?.data?.id ??
            '';
        clientSecret = cartResponse?.cart?.paymentCollection?.paymentSessions
                ?.firstOrNull?.data?.clientSecret ??
            '';
        apiLoading = false;
      });
      // Load wallet info after cart is ready
      _loadWalletInfo();
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      debugPrint(' error in cart $e');
    }
  }

  void emitEvent(CartResponse cartResponse) {
    final productItems = cartResponse.cart!.items!.where((item) => !item.isPlatformFee).toList();
    final totalQty = productItems
        .map((item) => item.quantity ?? 0)
        .fold<int>(0, (sum, qty) => sum + qty);
    print('total qty ${totalQty}');
    eventBus.fire(ViewCartModel(totalQty,
        productItems.map((item) => item.thumbnail!).toList()));
  }

  void addPromoCode(String promoCode) async {
    try {
      setState(() {
        cartLoading = true;
      });
      final ApiService apiService = ApiService();
      final response = await apiService.addPromoCode(context, promoCode);
      if ((response.cart?.promotions?.firstOrNull?.code ?? '').isNotEmpty) {
        AppUtils.showToast(
            '${response.cart?.promotions?.firstOrNull?.code ?? ''} ${AppStrings.promo_code_applied_success}');
        _confettiController.play();
      } else {
        AppUtils.showToast(AppStrings.promo_code_not_applied);
      }
      setState(() {
        cartResponse = response;
        cartLoading = false;
      });
    } catch (e) {
      setState(() {
        cartLoading = false;
      });
      print(e);
    }
  }

  void removePromoCode(List<String> promoCodes) async {
    try {
      setState(() {
        cartLoading = true;
      });
      final ApiService apiService = ApiService();
      final response = await apiService.removePromoCode(context, promoCodes);
      if ((response.cart?.promotions?.firstOrNull?.code ?? '').isEmpty) {
        AppUtils.showToast(AppStrings.promo_code_removed_success);
      }
      setState(() {
        cartResponse = response;
        cartLoading = false;
      });
    } catch (e) {
      setState(() {
        cartLoading = false;
      });
      print(e);
    }
  }

  // Silent remove — no toast, used internally when replacing a coupon
  Future<void> _removePromoCodeSilent(List<String> promoCodes) async {
    try {
      final ApiService apiService = ApiService();
      final response = await apiService.removePromoCode(context, promoCodes);
      if (mounted) setState(() => cartResponse = response);
    } catch (e) {
      print(e);
    }
  }

  void updateCart(int qty, String cartItemId, int index) async {
    try {
      debugPrint('calling update');
      final ApiService apiService = ApiService();
      cartResponse = await apiService.updateCart(context, qty, cartItemId);
      setState(() {
        cartResponse;
        setState(() {
          cartResponse!.cart!.items![index].isUpdating = false;
        });
      });
      emitEvent(cartResponse!);
    } catch (e) {
      setState(() {
        cartResponse!.cart!.items![index].isUpdating = false;
      });
      print(e);
    }
  }

  void removeCart(String cartItemId, int index) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.removeCart(context, cartItemId);
      getCartApi();
    } catch (e) {
      setState(() {
        setState(() {
          cartResponse!.cart!.items![index].isUpdating = false;
        });
      });
      print(e);
    }
  }

  void showPromoCodeBottomSheet(BuildContext context) {
    final cartId = cartResponse?.cart?.id;
    if (cartId == null) return;
    final appliedCodes = cartResponse?.cart?.promotions
            ?.map((p) => p.code ?? '')
            .where((c) => c.isNotEmpty)
            .toList() ??
        [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CouponBottomSheet(
        cartId: cartId,
        appliedCodes: appliedCodes,
        onApply: (code) async {
          // Silently remove existing coupon before applying new one (no toast)
          final existing = cartResponse?.cart?.promotions
                  ?.map((p) => p.code ?? '')
                  .where((c) => c.isNotEmpty)
                  .toList() ?? [];
          if (existing.isNotEmpty) {
            await _removePromoCodeSilent(existing);
          }
          await Future(() => addPromoCode(code));
        },
        onRemove: (codes) async {
          await Future(() => removePromoCode(codes));
        },
      ),
    );
  }

  String? _buildShippingAddress(CartResponse? cartResponse) {
    final address = cartResponse?.cart?.shippingAddress;
    if (address == null || address.address1 == null) return null;

    return [
      address.address1,
      address.city,
      address.postalCode,
      address.province ?? '',
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
  }

  void updateAddress(RegisterResponse.Address address) async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.updateAddress(
          context, convertToShippingAddress(address));
      setState(() {
        addressLoading = false;
        cartResponse;
      });
    } catch (e) {
      setState(() {
        addressLoading = false;
      });
      print(e);
    }
  }

  CheckOut.ShippingAddress convertToShippingAddress(
      RegisterResponse.Address address) {
    return CheckOut.ShippingAddress(
      // Map the fields from Address to ShippingAddress
      address1: address.address1 ?? '',
      address2: address.address2 ?? '',
      firstName: address.firstName ?? '',
      lastName: address.lastName ?? '',
      phone: address.phone ?? '',
      company: address.company ?? '',
      postalCode: address.postalCode ?? '',
      countryCode: address.countryCode ?? '',
      province: address.province ?? '',
      city: address.city ?? '',
    );
  }

  Future<void> updatePaymentMethod(String paymentProviderId) async {
    try {
      setState(() {
        cartLoading = true;
      });
      final ApiService apiService = ApiService();
      final response = await apiService.updatePaymentMethod(
          context, paymentProviderId, cartResponse!);
      setState(() {
        pp_id = response
                .paymentCollection?.paymentSessions?.firstOrNull?.providerId ??
            'pp_system_default';
        orderId = response.paymentCollection?.paymentSessions?.firstOrNull?.data?.id;
        clientSecret = response.paymentCollection?.paymentSessions?.firstOrNull?.data?.clientSecret;
      });
      getCartApi();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        cartLoading = false;
      });
    }
  }

  void showPaymentMethodsBottomSheet(
      BuildContext context, List<PaymentProvider> paymentProviders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return PaymentMethodsBottomSheet(
          paymentProviders: paymentProviders,
          providerId: pp_id,
          onPaymentSelected: (PaymentProvider paymentProvider) {
            if (pp_id != paymentProvider.id) {
              updatePaymentMethod(paymentProvider.id!);
            }
          },
        );
      },
    );
  }

  void showCalculationBottomSheet(
      BuildContext context, CartResponse? cartResponse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return CalculationBottomSheet(
          cartResponse: cartResponse,
        );
      },
    );
  }

  void placeOrder(String paymentProviderId) async {
    switch (paymentProviderId) {
      case 'pp_razorpay_razorpay':
        makeRazorPayCall(orderId!);
        break;
      case 'pp_stripe_stripe':
        makeStripeCall(clientSecret!);
        break;
      case 'pp_neft_neft':
        makeNEFTPayCall();
        break;
      case 'pp_system_default':
        completeCart();
        break;
      case 'pp_wallet_wallet':
        _makeWalletPayment();
        break;
    }
  }

  void _makeWalletPayment() async {
    setState(() => cartLoading = true);

    try {
      final walletData = await ApiService().getWalletBalance(context);
      final balance = walletData.wallet?.balance ?? 0;
      final cartTotal = cartResponse?.cart?.total ?? 0;

      if (balance >= cartTotal) {
        completeCart();
      } else {
        final shortfall = cartTotal - balance;
        setState(() => cartLoading = false);

        if (walletData.topupConfig?.canTopUp == true) {
          _showWalletTopUpDialog(shortfall, walletData);
        } else {
          AppUtils.showToast(
              'Insufficient wallet balance. Need ₹${shortfall.toStringAsFixed(2)} more.');
        }
      }
    } catch (e) {
      setState(() => cartLoading = false);
      AppUtils.showToast('Failed to check wallet balance');
      debugPrint('Wallet payment error: $e');
    }
  }

  void _showWalletTopUpDialog(double shortfall, WalletResponse walletData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Insufficient Balance', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance: ₹${walletData.wallet?.balance?.toStringAsFixed(2) ?? "0.00"}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Order Total: ₹${cartResponse?.cart?.total?.toStringAsFixed(2) ?? "0.00"}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'You need ₹${shortfall.toStringAsFixed(2)} more.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.orange.shade800),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _initiateWalletTopUpFromCart(shortfall);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Add ₹${shortfall.toStringAsFixed(0)}'),
          ),
        ],
      ),
    );
  }

  void _initiateWalletTopUpFromCart(double amount) async {
    setState(() => cartLoading = true);

    try {
      final result = await ApiService().initiateWalletTopUp(context, amount);

      if (result.razorpayOrderId != null && result.razorpayKey != null) {
        final topUpRazorpay = Razorpay();

        topUpRazorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
            (PaymentSuccessResponse response) async {
          try {
            await ApiService().confirmWalletTopUp(context, response.paymentId!, amount);
          } catch (e) {
            debugPrint('Failed to confirm top-up: $e');
          }
          topUpRazorpay.clear();

          // Re-initialize wallet payment session with updated balance, then complete
          try {
            await updatePaymentMethod('pp_wallet_wallet');
            completeCart();
          } catch (e) {
            setState(() => cartLoading = false);
            AppUtils.showToast('Balance added. Please tap Place Order again.');
          }
        });

        topUpRazorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
            (PaymentFailureResponse response) {
          topUpRazorpay.clear();
          setState(() => cartLoading = false);
          AppUtils.showToast('Top-up payment failed. Please try again.');
        });

        topUpRazorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
            (ExternalWalletResponse response) {});

        var options = {
          'key': result.razorpayKey,
          'amount': (amount * 100).toInt(),
          'order_id': result.razorpayOrderId,
          'name': AppConfig.appName,
          'description': 'Wallet Top-Up',
          'retry': {'enabled': true, 'max_count': 1},
          'send_sms_hash': true,
          'prefill': {
            'contact': customer?.phone ?? '',
            'email': customer?.email ?? '',
          },
          'theme': {'color': AppUtils.colorToHex(AppColors.primary)},
        };
        topUpRazorpay.open(options);
      } else {
        setState(() => cartLoading = false);
        AppUtils.showToast('Wallet top-up is not available');
      }
    } catch (e) {
      setState(() => cartLoading = false);
      AppUtils.showToast('Failed to initiate top-up');
      debugPrint('Top-up error: $e');
    }
  }

  void completeCart() async {
    try {
      setState(() {
        cartLoading = true;
      });
      final ApiService apiService = ApiService();
      final response = await apiService.completeCart(context);
      setState(() {
        cartLoading = false;
      });
      if (response.order?.id?.isEmpty == true) {
        getCartApi();
        return;
      }
      PageRouteUtils.pushAndRemoveUntil(
          context,
          OrderPlacedPage(
            orderId: response.order?.id ?? '',
          ));
    } catch (e) {
      getCartApi();
      setState(() {
        cartLoading = false;
      });
      print(e);
    }
  }

  void makeRazorPayCall(String orderId) {
    // Use wallet-reduced amount if split is active
    final paymentAmount = (splitActive && splitGatewayAmount > 0)
        ? splitGatewayAmount
        : (cartResponse?.cart?.total ?? 1);
    var options = {
      'key': _getProviderKey(pp_id, paymentProviders),
      'amount': (paymentAmount * 100).round(),
      'name': AppConfig.appName,
      'description': '${AppStrings.payment_to} ${AppConfig.appName}',
      'order_id': orderId,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': customer?.phone ?? '',
        'email': customer?.email ?? ''
      },
      'theme': {'color': AppUtils.colorToHex(AppColors.primary)},
      'experiments.upi_turbo': true,
      'external': {
        'wallets': ['paytm']
      }
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    print(
        "Payment Failed ,Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    print("Payment Successful Payment ID: ${response.paymentId}");
    completeCart();
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {}

  void makeStripeCall(String clientSecret) async {
    try {
      // Initialize the payment sheet with client secret
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: AppConfig.appName,
            googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: AppStrings.country_code,
              testEnv: true,
            ),
            style: ThemeMode.light,
            appearance: PaymentSheetAppearance(
                primaryButton: PaymentSheetPrimaryButtonAppearance(
                    colors: PaymentSheetPrimaryButtonTheme(
                        light: PaymentSheetPrimaryButtonThemeColors(
                            background: AppColors.primary),
                        dark: PaymentSheetPrimaryButtonThemeColors(
                            background: AppColors.primary))))),
      );

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();
      completeCart();
    } catch (e) {
      print('Payment failed: $e');
    }
  }

  void makeNEFTPayCall() {
    CustomPopupWidget.show(
      context,
      title: AppStrings.neft_payment_instruct,
      description: AppStrings.neft_payment_desc,
      buttonText: AppStrings.place_your_order,
      icon: Icons.info,
      onConfirm: () {
        completeCart();
      },
    );
  }

  String? extractOrderId(dynamic response) {
    try {
      return response["payment_collection"]["payment_sessions"]?[0]["data"]
          ["id"];
    } catch (e) {
      print("Error extracting order ID: $e");
      return null;
    }
  }

  String? extractClientSecret(dynamic response) {
    try {
      return response["payment_collection"]["payment_sessions"]?[0]["data"]
          ["client_secret"];
    } catch (e) {
      print("Error extracting order ID: $e");
      return null;
    }
  }

  num _numOrZero(num? value) => value ?? 0;

  // ===== Payment Method Card =====
  Widget _buildPaymentMethodCard() {
    final providerName = _getProviderName(pp_id, paymentProviders);
    final providers = isSplitPaymentMode
        ? paymentProviders.where((p) => p.id != 'pp_wallet_wallet').toList()
        : paymentProviders;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => showPaymentMethodsBottomSheet(context, providers),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.payment_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      providerName,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Ajio-style Bottom Bar =====
  Widget _buildAjioBottomBar() {
    final amount = CurrencyUtil.appendCurrency(
      (splitActive
          ? (cartResponse!.cart!.total! - splitWalletAmount).clamp(0, double.infinity)
          : cartResponse!.cart!.total!)
          .toStringAsFixed(2),
    );
    final providerName = _getProviderName(pp_id, paymentProviders);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Left: Amount + View details
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                GestureDetector(
                  onTap: _scrollToPriceDetails,
                  child: Text(
                    'View details',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: Place Order button with payment method
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: cartLoading
                  ? null
                  : () {
                      if (cartResponse?.cart?.error == true) {
                        AppUtils.showToast(AppStrings.remove_unavailable_stock_items);
                        return;
                      }
                      if ((cartResponse?.cart?.shippingAddress?.address1 ?? '').isEmpty) {
                        AppUtils.showToast(AppStrings.add_address_to_proceed);
                        return;
                      }
                      if (!addressLoading) {
                        placeOrder(pp_id!);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: cartLoading
                    ? const SizedBox(
                        key: ValueKey('loader'),
                        height: 36,
                        child: Center(
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        key: const ValueKey('text'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            providerName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor, bool isBold = false, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: FontUtils.primaryFontStyle(
            fontSize: fontSize,
            color: AppColors.textColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          )),
          Text(value, style: FontUtils.primaryFontStyle(
            fontSize: fontSize,
            color: valueColor ?? AppColors.textColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          )),
        ],
      ),
    );
  }

  // ===== Coupon Card =====
  Widget _buildCouponCard() {
    final coupon = cartResponse?.cart?.promotions?.firstOrNull;
    final isApplied = (coupon?.code ?? '').isNotEmpty;
    final discount = _numOrZero(cartResponse?.cart?.discountSubtotal);
    final canUseCoupon = allowCouponWithWallet || !splitActive;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: canUseCoupon ? () => showPromoCodeBottomSheet(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isApplied ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  color: isApplied ? Colors.green.shade600 : Colors.orange.shade700,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coupon',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    isApplied
                        ? Text(
                            '${coupon!.code} · Save ${CurrencyUtil.appendCurrency(discount.toStringAsFixed(2))}',
                            style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                          )
                        : Text(
                            canUseCoupon ? 'Apply coupon code' : 'Remove wallet to apply coupon',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Wallet Card (Myntra style) =====
  Widget _buildWalletCard() {
    final couponApplied = (cartResponse?.cart?.promotions ?? []).isNotEmpty;
    final canUseWallet = allowCouponWithWallet || !couponApplied;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: splitActive ? AppColors.primary.withOpacity(0.4) : Colors.grey.shade200,
          width: splitActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: canUseWallet
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: canUseWallet ? AppColors.primary : Colors.grey,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use Wallet Balance',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: canUseWallet ? AppColors.textColor : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Available: ${CurrencyUtil.appendCurrency(walletBalance.toStringAsFixed(2))}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      if (walletUsageLimit != null &&
                          walletUsageLimit!.enabled &&
                          walletUsageLimit!.displayText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Max usable: ${walletUsageLimit!.displayText}',
                            style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                          ),
                        ),
                      if (!canUseWallet)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Remove coupon to use wallet',
                            style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                          ),
                        ),
                    ],
                  ),
                ),
                walletToggling
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Switch(
                        value: splitActive,
                        onChanged: canUseWallet ? (_) => _toggleWalletSplit() : null,
                        activeColor: AppColors.primary,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade200,
                      ),
              ],
            ),
          ),
          if (splitActive && splitWalletAmount > 0) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${CurrencyUtil.appendCurrency(splitWalletAmount.toStringAsFixed(2))} will be deducted from your wallet',
                    style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

}
