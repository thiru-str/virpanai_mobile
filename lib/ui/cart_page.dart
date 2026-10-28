import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:waioz/model/cross_sell_products_response.dart';
import 'package:waioz/model/shipping_response.dart' as PaymentSessionData;
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/paytm_payment_page.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/ui/widgets/calculation_bottom_sheet.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/coupon_bottom_sheet.dart';
import 'package:waioz/ui/widgets/free_delivery_banner_widget.dart';
import 'package:waioz/ui/widgets/custom_popup_widget.dart';
import 'package:waioz/ui/widgets/delivery_address_widget.dart';
import 'package:waioz/ui/widgets/login_prompt.dart';
import 'package:waioz/ui/widgets/loyalty_earn_preview.dart';
import 'package:waioz/ui/widgets/loyalty_checkout_widget.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/payment_method_bottom_sheet.dart';
import 'package:waioz/ui/icici_payment_page.dart';
import 'package:waioz/ui/widgets/product_recommendation_section.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/cart_store.dart';
import 'package:waioz/utility/checkout_completion.dart';
import 'package:waioz/utility/coupon_removed.dart';
import 'package:waioz/utility/payment_provider_selection.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../api/api_service.dart';
import '../model/home_page_response.dart';
import '../model/register_response.dart' as RegisterResponse;
import 'package:waioz/model/check_out_shipping_address_model.dart' as CheckOut;
import '../model/wallet_response.dart';
import '../utility/app_config.dart';
import '../utility/currency_util.dart';
import '../utility/shared_preferences_util.dart';
import 'address_list_page.dart';
import 'bottom_nav_page.dart';
import 'order_failed_page.dart';
import 'order_placed_page.dart';

class CartPage extends StatefulWidget {
  final bool isFromBottomNav;

  const CartPage({super.key, this.isFromBottomNav = false});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  CartResponse? cartResponse;
  CrossSellProductsResponse? crossSellProductsResponse;
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
  PaymentSessionData.Data? paytmData;
  Razorpay razorpay = Razorpay();
  bool showPriceBreakdown = false;

  // Optimistic cart: totals are stale and checkout waits while this is true.
  bool cartSyncing = false;
  Set<String> pendingLineIds = const {};
  StreamSubscription<CartStateEvent>? _cartStateSubscription;
  bool _completing = false;
  // A choice the backend has not stored on the cart yet (ICICI's session is
  // only created when the order is placed).
  String? _selectedProviderId;
  String? _dismissedCouponKey;

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
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
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
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    AppUtils.isLoggedIn().then((value) {
      setState(() {
        isLoggedIn = value;
      });
    });

    _cartStateSubscription =
        eventBus.on<CartStateEvent>().listen(_onCartState);
    _loadDismissedCouponKey();
    _showCachedCart();
    initGlobal();
    getCartApi();
  }

  // Paint the cart the store already holds while it is re-read, unless it
  // belongs to another session's cart.
  Future<void> _showCachedCart() async {
    final store = CartStore.instance;
    final cartId = await SharedPreferencesUtil().getString('cart_id');
    if (!mounted || cartId == null || store.cart.cart?.id != cartId) return;
    _onCartState(
        CartStateEvent(store.cart, store.isSyncing, store.pendingLineIds));
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
    final name = match.name;
    if (name != null && name.isNotEmpty) return name;

    // Fallback display names for providers with empty/null names
    switch (providerId) {
      case 'pp_wallet_wallet':
        return 'Wallet';
      case 'pp_razorpay_razorpay':
        return 'Razorpay';
      case 'pp_payu_payu':
        return 'PayU';
      case 'pp_paytm_paytm':
        return 'Paytm';
      case 'pp_icici_icici':
        return 'ICICI Bank';
      case 'pp_system_default':
        return 'Cash on Delivery';
      case 'pp_neft_neft':
        return 'Bank Transfer (NEFT)';
      case 'pp_stripe_stripe':
        return 'Credit / Debit Card';
      default:
        return AppStrings.cash_on_delivery;
    }
  }

  IconData _providerIcon(String? id) {
    switch (id) {
      case 'pp_razorpay_razorpay':
        return Icons.bolt_rounded;
      case 'pp_payu_payu':
        return Icons.credit_card_rounded;
      case 'pp_paytm_paytm':
        return Icons.account_balance_wallet_rounded;
      case 'pp_icici_icici':
        return Icons.account_balance_rounded;
      case 'pp_neft_neft':
        return Icons.swap_horiz_rounded;
      case 'pp_wallet_wallet':
        return Icons.account_balance_wallet_rounded;
      case 'pp_stripe_stripe':
        return Icons.credit_card_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  Color _providerColor(String? id) {
    switch (id) {
      case 'pp_razorpay_razorpay':
        return const Color(0xFF2D81F7);
      case 'pp_payu_payu':
        return const Color(0xFF6CB33F);
      case 'pp_paytm_paytm':
        return const Color(0xFF00BAF2);
      case 'pp_icici_icici':
        return const Color(0xFFE87722);
      case 'pp_neft_neft':
        return const Color(0xFF1565C0);
      case 'pp_wallet_wallet':
        return const Color(0xFF2E7D32);
      case 'pp_stripe_stripe':
        return const Color(0xFF635BFF);
      default:
        return const Color(0xFF795548);
    }
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
    _cartStateSubscription?.cancel();
    razorpay.clear();
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
      backgroundColor: const Color(0xFFF9F9FB),
      body: Stack(
        children: [
          apiLoading
              ? const CartPageSkeleton()
              : cartResponse?.cart?.items?.isNotEmpty ?? false
                  ? Scaffold(
                      backgroundColor: const Color(0xFFF9F9FB),
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: cartResponse!.cart!.items!
                                        .where((item) => !item.isVirtualItem)
                                        .length,
                                    itemBuilder: (context, index) {
                                      final productItems = cartResponse!
                                          .cart!.items!
                                          .where((item) => !item.isVirtualItem)
                                          .toList();
                                      final cartItem = productItems[index];
                                      return AppReveal(
                                        index: index,
                                        child: CartItemCard(
                                          imageUrl: cartItem.thumbnail ?? '',
                                          productName:
                                              cartItem.productTitle ?? '',
                                          error: cartItem.error ?? '',
                                          size: (cartItem.variantTitle ??
                                                      "Default variant") ==
                                                  "Default variant"
                                              ? ""
                                              : cartItem.variantTitle!,
                                          color: 'color',
                                          // A provisional line has no server
                                          // price yet.
                                          price: cartItem.unitPrice == null
                                              ? ''
                                              : CurrencyUtil.appendCurrency(
                                                  (cartItem.unitPrice! *
                                                          cartItem.quantity!)
                                                      .toStringAsFixed(2)),
                                          quantity: cartItem.quantity!,
                                          isUpdating: cartItem.isUpdating!,
                                          priceUpdating: pendingLineIds
                                              .contains(cartItem.id),
                                          onRemoveAll: () =>
                                              removeCart(cartItem.id!),
                                          onIncrease: () => updateCart(
                                              cartItem.quantity! + 1,
                                              cartItem.id!),
                                          onDecrease: () =>
                                              _decreaseQuantity(cartItem),
                                        ),
                                      );
                                    },
                                  ),
                                  if ((crossSellProductsResponse
                                          ?.products?.isNotEmpty ??
                                      false))
                                    ProductRecommendationSection(
                                      title: crossSellProductsResponse?.label ??
                                          'Cross Selling Products',
                                      products:
                                          crossSellProductsResponse?.products ??
                                              const [],
                                      onReturnFromProductDetail: (_) async {
                                        if (!mounted) return;
                                        getCartApi();
                                      },
                                    ),
                                ],
                              ),
                            ),
                            // Wallet Card (Myntra style)
                            if (isSplitPaymentMode &&
                                isLoggedIn &&
                                walletBalance > 0)
                              _buildWalletCard(),

                            // Loyalty Points Card (matches wallet card design,
                            // sits right under it so wallet + loyalty are visually
                            // grouped in the same "balance to redeem" section).
                            if (cartResponse?.cart?.id != null)
                              LoyaltyCheckoutWidget(
                                cartId: cartResponse!.cart!.id!,
                                loyaltyApply: _loyaltyApplyMetadata(),
                                cartTotal: cartResponse?.cart?.total ?? 0,
                                walletAmount: _walletAmountFromMetadata(),
                                walletApplied: _walletAmountFromMetadata() > 0,
                                hasActiveCoupon:
                                    (cartResponse?.cart?.promotions ?? [])
                                        .isNotEmpty,
                                onApplied: () {
                                  getCartApi();
                                },
                                onRemoved: () {
                                  getCartApi();
                                },
                              ),

                            _buildCouponRemovedNotice(),

                            // Coupon Card (Ajio style)
                            _buildCouponCard(),

                            // Payment Method Card
                            _buildPaymentMethodCard(),

                            // Free delivery progress banner — hides itself when
                            // no shipping address or no slabs configured.
                            if ((cartResponse?.cart?.id ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: FreeDeliveryBannerWidget(
                                  cartId: cartResponse!.cart!.id!,
                                  cartTotal: cartResponse?.cart?.itemSubtotal ??
                                      cartResponse?.cart?.subtotal ??
                                      0,
                                ),
                              ),

                            // Price Details (view only)
                            AppReveal(
                              index: 3,
                              child: AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) =>
                                    Transform.translate(
                                  offset: Offset(_shakeAnimation.value, 0),
                                  child: child,
                                ),
                                child: Container(
                                  key: _priceDetailsSectionKey,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  padding: const EdgeInsets.all(18.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EC)),
                                  ),
                                  child: AnimatedOpacity(
                                    // Totals are the last server values until
                                    // queued cart changes are confirmed.
                                    opacity: cartSyncing ? 0.6 : 1,
                                    duration:
                                        const Duration(milliseconds: 150),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Price Details',
                                                style: UiTypography.cardTitle()
                                                    .copyWith(
                                                  fontSize: 16,
                                                  height: 1.25,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              if (cartSyncing) ...[
                                                const SizedBox(width: 8),
                                                _syncingIndicator(),
                                              ],
                                            ],
                                          ),
                                        ),
                                        _priceRow(
                                            AppStrings.subTotal,
                                            CurrencyUtil.appendCurrency(
                                                (_numOrZero(cartResponse?.cart
                                                            ?.itemSubtotal) -
                                                        _numOrZero(cartResponse
                                                            ?.cart?.items
                                                            ?.where((item) => item
                                                                .isVirtualItem)
                                                            .fold<num>(
                                                                0,
                                                                (sum, item) =>
                                                                    sum +
                                                                    (item.total ??
                                                                        0))))
                                                    .toStringAsFixed(2))),
                                        _priceRow(
                                            AppStrings.shipping,
                                            _numOrZero(cartResponse?.cart
                                                        ?.shippingSubtotal) >
                                                    0
                                                ? CurrencyUtil.appendCurrency(
                                                    _numOrZero(cartResponse?.cart
                                                            ?.shippingSubtotal)
                                                        .toStringAsFixed(2))
                                                : 'FREE'),
                                        if ((cartResponse?.cart?.items?.any(
                                                    (item) =>
                                                        item.isPlatformFee) ??
                                                false) &&
                                            _platformFeeTotal() > 0)
                                          _priceRow(
                                              AppStrings.platform_fee,
                                              CurrencyUtil.appendCurrency(
                                                  _platformFeeTotal()
                                                      .toStringAsFixed(2))),
                                        if (_numOrZero(
                                                cartResponse?.cart?.taxTotal) >
                                            0)
                                          _priceRow(
                                              AppStrings.tax,
                                              CurrencyUtil.appendCurrency(
                                                  _numOrZero(cartResponse
                                                          ?.cart?.taxTotal)
                                                      .toStringAsFixed(2))),
                                        if ((cartResponse?.cart?.promotions ?? [])
                                                .isNotEmpty &&
                                            _numOrZero(cartResponse
                                                    ?.cart?.discountSubtotal) >
                                                0)
                                          _priceRow(
                                            'Coupon Savings',
                                            '- ${CurrencyUtil.appendCurrency(_numOrZero(cartResponse?.cart?.discountSubtotal).toStringAsFixed(2))}',
                                            valueColor: const Color(0xFF1FA971),
                                          ),
                                        // Loyalty points discount (negative line item added by API)
                                        if ((cartResponse?.cart?.items?.any(
                                                (item) =>
                                                    item.isLoyaltyDiscount) ??
                                            false))
                                          Builder(builder: (_) {
                                            final li = cartResponse!.cart!.items!
                                                .firstWhere((item) =>
                                                    item.isLoyaltyDiscount);
                                            final amt = (li.total ?? 0).abs();
                                            final pts =
                                                li.metadata?.pointsApplied ?? 0;
                                            return _priceRow(
                                              'Loyalty Points ($pts pts)',
                                              '- ${CurrencyUtil.appendCurrency(amt.toStringAsFixed(2))}',
                                              valueColor: AppColors.primary,
                                            );
                                          }),
                                        if (_loyaltyDiscount > 0)
                                          _priceRow(
                                            'Loyalty Points ($_loyaltyPointsApplied pts)',
                                            '- ${CurrencyUtil.appendCurrency(_loyaltyDiscount.toStringAsFixed(2))}',
                                            valueColor: AppColors.primary,
                                          ),
                                        if (splitActive && splitWalletAmount > 0)
                                          _priceRow(
                                            'Wallet',
                                            '- ${CurrencyUtil.appendCurrency(splitWalletAmount.toStringAsFixed(2))}',
                                            valueColor: AppColors.primary,
                                          ),
                                        const Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 10),
                                          child: Divider(
                                              color: Color(0xFFE5E7EC),
                                              height: 1),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Total Amount',
                                              style: UiTypography.cardTitle()
                                                  .copyWith(
                                                fontSize: 16,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Flexible(
                                              child: Text(
                                                CurrencyUtil.appendCurrency(
                                                    _displayTotalAmount()
                                                        .toStringAsFixed(2)),
                                                maxLines: 1,
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: UiTypography.cardPrice(
                                                        color: AppColors.primary)
                                                    .copyWith(fontSize: 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Loyalty earn preview — based on actual paid amount (item subtotal minus loyalty discount)
                            if ((cartResponse?.cart?.itemSubtotal ??
                                    cartResponse?.cart?.total ??
                                    0) >
                                0)
                              LoyaltyEarnPreview(
                                cartId: cartResponse!.cart!.id,
                                orderTotal: cartResponse?.cart?.itemSubtotal ??
                                    cartResponse?.cart?.subtotal ??
                                    cartResponse?.cart?.total ??
                                    0,
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
                                // Signing in from checkout returns to the cart tab.
                                PageRouteUtils.push(
                                    context,
                                    const PhoneNumberPage(
                                        redirectPage:
                                            BottomNavPage(initialIndex: 2)));
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

      final isDismissed = (cartResponse?.cart?.metadata
              as Map?)?['wallet_auto_apply_dismissed'] ==
          true;
      final existingSplit =
          (cartResponse?.cart?.metadata as Map?)?['wallet_split'];
      final existingWalletAmount = (existingSplit is Map)
          ? (existingSplit['wallet_amount'] ?? 0).toDouble()
          : 0.0;

      if (isSplitPaymentMode && !isDismissed) {
        if (existingWalletAmount > 0) {
          _syncPricingStateFromCart();
        } else if (autoApply &&
            balance > 0 &&
            cartResponse?.cart?.id != null &&
            !splitActive) {
          // First-time auto-apply
          await _applyWalletSplit(silent: true);
        }
      }
    } catch (e) {
      debugPrint('Wallet load error: $e');
    }
  }

  Future<void> _applyWalletSplit({bool silent = false}) async {
    if (cartResponse?.cart?.id == null) return;
    setState(() => walletToggling = true);
    try {
      final wasAlreadyActive = splitActive;
      final result =
          await ApiService().applyWalletSplit(context, cartResponse!.cart!.id!);
      if (!mounted) return;
      if (result.walletApplied) {
        await getCartApi();
        // Only play confetti on first apply, not on recalculation
        if (!wasAlreadyActive && !silent) {
          _confettiController.play();
        }
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
      await getCartApi();
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

  Future<void> getCartApi() async {
    final previousCartId = cartResponse?.cart?.id;
    await CartStore.instance.refresh(context);
    if (!mounted) return;
    setState(() => apiLoading = false);
    final cartId = cartResponse?.cart?.id;
    if (cartId != null && cartId.isNotEmpty) {
      unawaited(getCrossSellingProductsApi(cartId));
    } else if (previousCartId != null) {
      crossSellProductsResponse = null;
    }
    // Load wallet info after cart is ready
    await _loadWalletInfo();
  }

  /// Every cart change, optimistic or confirmed, from any screen.
  void _onCartState(CartStateEvent event) {
    if (!mounted) return;
    setState(() {
      cartResponse = event.cart;
      cartSyncing = event.syncing;
      pendingLineIds = event.pendingLineIds;
      if (event.cart.cart?.id != null) apiLoading = false;
      _applyPaymentState(event.cart.cart);
    });
    if (!event.syncing) _syncPricingStateFromCart();
  }

  List<String> get _availableProviderIds =>
      paymentProviders.map((p) => p.id).whereType<String>().toList();

  // The shopper's selection stored on the cart (or their last order's
  // provider) wins over a session left from an earlier selection.
  void _applyPaymentState(Cart? cart) {
    if (cart == null) return;
    pp_id = _selectedProviderId ??
        preferredPaymentProviderId(cart,
            availableProviderIds: _availableProviderIds);
    final session = sessionForProvider(cart, pp_id);
    orderId = session?.data?.id ?? '';
    clientSecret = session?.data?.clientSecret ?? '';
    paytmData = pp_id == 'pp_paytm_paytm' ? session?.data : null;
  }

  Future<void> getCrossSellingProductsApi(String cartId) async {
    try {
      final response = await ApiService().crossSellingProducts(context, cartId);
      if (!mounted) return;
      setState(() {
        crossSellProductsResponse = response;
      });
    } catch (e) {
      debugPrint('cross selling error: $e');
    }
  }

  void addPromoCode(String promoCode, {List<String>? removeCodes}) async {
    try {
      setState(() {
        cartLoading = true;
      });
      final ApiService apiService = ApiService();
      final response = await apiService.addPromoCode(context, promoCode,
          removeCodes: removeCodes);
      if ((response.cart?.promotions?.firstOrNull?.code ?? '').isNotEmpty) {
        AppUtils.showToast(
            '${response.cart?.promotions?.firstOrNull?.code ?? ''} ${AppStrings.promo_code_applied_success}');
        _confettiController.play();
      } else {
        AppUtils.showToast(AppStrings.promo_code_not_applied);
      }
      await getCartApi();
      if (!mounted) return;
      setState(() {
        cartLoading = false;
      });
    } catch (e) {
      setState(() {
        cartLoading = false;
      });
      // Refresh cart to ensure UI matches backend state after failure
      getCartApi();
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
      await getCartApi();
      if (!mounted) return;
      setState(() {
        cartLoading = false;
      });
    } catch (e) {
      setState(() {
        cartLoading = false;
      });
      print(e);
    }
  }

  // The row, totals and badge repaint on tap; the request (coalesced per
  // line) and any rollback with the server's message run in the background.
  void updateCart(int qty, String cartItemId) {
    CartStore.instance.setLineQuantity(context, cartItemId, qty);
  }

  void removeCart(String cartItemId) {
    CartStore.instance.removeLine(context, cartItemId);
  }

  Future<void> _decreaseQuantity(Item item) async {
    final currentQty = item.quantity ?? 0;
    final stockQty = item.inventoryQuantity ?? 0;
    final lineId = item.id;
    if (lineId == null) return;

    if (currentQty <= 1 || (!(item.inStock ?? false) && stockQty == 0)) {
      removeCart(lineId);
      return;
    }

    if (!(item.inStock ?? false) && currentQty > stockQty) {
      final confirmed = await _confirmReduceToStock(stockQty);
      if (confirmed == true) updateCart(stockQty, lineId);
      return;
    }

    updateCart(currentQty - 1, lineId);
  }

  Future<bool?> _confirmReduceToStock(int stockQty) {
    final actionStyle = FontUtils.primaryFontStyle(
        color: AppColors.primary, fontWeight: FontWeight.bold);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.stock_update, style: actionStyle),
        content: Text(
          '${AppStrings.stock_update_message_prefix} $stockQty in stock. '
          '${AppStrings.stock_update_message_suffix} $stockQty?',
          style: FontUtils.secondaryFontStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppStrings.cancel, style: actionStyle),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppStrings.yes_update, style: actionStyle),
          ),
        ],
      ),
    );
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
          // Atomic swap: remove old + apply new in single backend call
          final existing = cartResponse?.cart?.promotions
                  ?.map((p) => p.code ?? '')
                  .where((c) => c.isNotEmpty && c != code)
                  .toList() ??
              [];
          await Future(() => addPromoCode(code,
              removeCodes: existing.isNotEmpty ? existing : null));
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
      await apiService.updateAddress(
          context, convertToShippingAddress(address));
      // Pull fresh cart from /store/custom-carts/{id} so the platform fee,
      // qty_tiered adjustments and wallet split land on the response.
      // Medusa's native POST /store/carts/{id} (used by updateAddress) does
      // NOT trigger our recompute pipeline — using its response directly
      // would leave the price summary stale until the next page load.
      await getCartApi();
      setState(() {
        addressLoading = false;
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

  /// Switching back and forth works: the backend stores the choice on the
  /// cart and replaces the previous provider's session, and the cart read
  /// afterwards (success or failure) carries the session to pay with.
  Future<void> updatePaymentMethod(String paymentProviderId) async {
    setState(() {
      _selectedProviderId = paymentProviderId;
      pp_id = paymentProviderId;
    });
    // ICICI is redirect-based — session created at place-order time, not here.
    if (paymentProviderId == 'pp_icici_icici') return;

    setState(() => cartLoading = true);
    try {
      final response =
          await ApiService().updatePaymentMethod(context, paymentProviderId);
      final session = response.paymentCollection?.paymentSessions
          ?.where((session) => session.providerId == paymentProviderId)
          .firstOrNull;
      paytmData =
          paymentProviderId == 'pp_paytm_paytm' ? session?.data : null;
    } on ApiException catch (error) {
      AppUtils.showToast(error.message);
    } catch (e) {
      debugPrint('update payment method failed: $e');
    } finally {
      final keepPaytmData = paytmData;
      await getCartApi();
      if (mounted) {
        setState(() {
          _selectedProviderId =
              paymentProviderId == 'pp_icici_icici' ? paymentProviderId : null;
          _applyPaymentState(cartResponse?.cart);
          paytmData = keepPaytmData ?? paytmData;
          cartLoading = false;
        });
      }
    }
  }

  void showPaymentMethodsBottomSheet(
      BuildContext context, List<PaymentProvider> paymentProviders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PaymentMethodsBottomSheet(
          paymentProviders: paymentProviders,
          providerId: pp_id,
          walletBalance: walletBalance > 0 ? walletBalance : null,
          onPaymentSelected: (PaymentProvider paymentProvider) {
            // When wallet + loyalty already cover the full order, the gateway
            // payable is 0. Real gateways reject 0-amount sessions, so the
            // customer's selection would silently flip back to COD. Tell them
            // why instead of letting the UI pretend the change took.
            if (_displayTotalAmount() <= 0 &&
                paymentProvider.id != 'pp_system_default') {
              AppUtils.showToast(
                'Your order is fully covered. Free orders can be placed only via Cash on Delivery.',
              );
              return;
            }
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
    // Ensure cart has a shipping method attached before placing the order.
    // Some backends rely on a subscriber to auto-attach (distance-based etc.),
    // but if it fails the cart stays without one and complete-cart rejects
    // with "No shipping method selected but the cart contains items that
    // require shipping". Fetch options here and attach the first as fallback.
    final hasShipping =
        (cartResponse?.cart?.shippingMethods?.isNotEmpty ?? false);
    if (!hasShipping) {
      try {
        setState(() => cartLoading = true);
        final api = ApiService();
        final shipping = await api.getShippingInfo(context);
        final first = shipping.shippingOptions?.isNotEmpty == true
            ? shipping.shippingOptions!.first
            : null;
        if (first?.id != null) {
          await api.updateShippingMethod(context, first!.id!);
          await getCartApi();
        } else {
          setState(() => cartLoading = false);
          AppUtils.showToast('No shipping method available for this address.');
          return;
        }
      } catch (e) {
        setState(() => cartLoading = false);
        AppUtils.showToast(
            'Could not attach shipping method. Please try again.');
        return;
      } finally {
        setState(() => cartLoading = false);
      }
    }

    // A provider preselected from the cart (or the shopper's last order) may
    // not have a session yet, or only a leftover from an earlier selection.
    if (paymentProviderId != 'pp_icici_icici' &&
        sessionForProvider(cartResponse?.cart, paymentProviderId) == null) {
      await updatePaymentMethod(paymentProviderId);
      if (!mounted) return;
      if (sessionForProvider(cartResponse?.cart, paymentProviderId) == null) {
        AppUtils.showToast(
            'Could not start this payment method. Please try again or choose another.');
        return;
      }
    }

    if (paymentProviderId == 'pp_icici_icici') {
      _makeIciciPayment();
      return;
    }
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
      case 'pp_paytm_paytm':
        makePaytmCall();
        break;
    }
  }

  void makePaytmCall() {
    final data = paytmData ??
        cartResponse?.cart?.paymentCollection?.paymentSessions
            ?.where((session) => session.providerId == 'pp_paytm_paytm')
            .firstOrNull
            ?.data;
    if (data == null ||
        data.host == null ||
        data.mid == null ||
        (data.orderId ?? data.id) == null ||
        (data.txnToken ?? data.token) == null ||
        data.amount == null) {
      AppUtils.showToast(
          'Paytm payment session is incomplete. Please try again.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaytmPaymentPage(
          data: data,
          onSuccess: () {
            Navigator.pop(context);
            completeCart();
          },
          onFailure: (message, failure) {
            Navigator.pop(context);
            _showCompletionFailure(
                failure ?? CompletionFailure.fromBody({'message': message}));
          },
        ),
      ),
    );
  }

  Future<void> _makeIciciPayment() async {
    setState(() => cartLoading = true);
    try {
      final redirectUrl = await ApiService().initiateIciciPayment(context);
      debugPrint('ICICI redirect URL: $redirectUrl');
      if (!mounted) return;
      setState(() => cartLoading = false);

      if (redirectUrl == null || redirectUrl.isEmpty) {
        AppUtils.showToast(
            'Failed to initiate ICICI payment. Please try again.');
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IciciPaymentPage(
            redirectUrl: redirectUrl,
            onSuccess: (orderId) {
              Navigator.pop(context);
              _showOrderPlaced(orderId);
            },
            onFailure: (failure) {
              Navigator.pop(context);
              _showCompletionFailure(failure ??
                  const CompletionFailure(
                    code: paymentFailedCode,
                    message: 'ICICI payment failed or was cancelled.',
                  ));
            },
          ),
        ),
      );
    } catch (e) {
      setState(() => cartLoading = false);
      AppUtils.showToast('Failed to initiate ICICI payment. Please try again.');
      debugPrint('ICICI payment error: $e');
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
            const Expanded(
              child: Text(
                'Insufficient Balance',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16),
              ),
            ),
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
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade800),
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
            await ApiService()
                .confirmWalletTopUp(context, response.paymentId!, amount);
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

  /// Completes the cart once; a second tap or a duplicate gateway callback
  /// while it runs is ignored. No order exists unless the backend says so.
  Future<void> completeCart() async {
    if (_completing) return;
    _completing = true;
    setState(() => cartLoading = true);
    try {
      final result = await ApiService().completeCart(context);
      if (!mounted) return;
      final orderId = result.orderId;
      if (orderId != null) {
        _showOrderPlaced(orderId);
        return;
      }
      _showCompletionFailure(result.failure!);
    } finally {
      _completing = false;
      if (mounted) setState(() => cartLoading = false);
    }
  }

  void _showOrderPlaced(String orderId) {
    CartStore.instance.clear();
    PageRouteUtils.pushAndRemoveUntil(context, OrderPlacedPage(orderId: orderId));
  }

  /// Stock that ran out, or a charged payment that was refunded, gets the
  /// failure screen; anything else is a message on the cart.
  void _showCompletionFailure(CompletionFailure failure) {
    getCartApi();
    if (failure.showsFailureScreen) {
      PageRouteUtils.push(context, OrderFailedPage(failure: failure));
      return;
    }
    AppUtils.showToast(failure.message);
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
    // Re-opening checkout must not stack a second set of handlers.
    razorpay.clear();
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    final message = response.message;
    AppUtils.showToast(message != null && message.isNotEmpty
        ? message
        : 'Payment was not completed. You have not been charged.');
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

  Map<String, dynamic> _cartMetadataMap() {
    final metadata = cartResponse?.cart?.metadata;
    if (metadata is Map<String, dynamic>) {
      return metadata;
    }
    if (metadata is Map) {
      return Map<String, dynamic>.from(metadata);
    }
    return const {};
  }

  double _doubleFromDynamic(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  double _platformFeeTotal() {
    return (cartResponse?.cart?.items ?? [])
        .where((item) => item.isPlatformFee)
        .fold<double>(0, (sum, item) => sum + _doubleFromDynamic(item.total));
  }

  double _loyaltyDiscountAmount() {
    return _loyaltyDiscount.toDouble();
  }

  /// Pass-through of cart.metadata.loyalty_checkout_apply for the
  /// LoyaltyCheckoutWidget so it stays in sync with backend recalcs.
  Map<String, dynamic>? _loyaltyApplyMetadata() {
    final meta = cartResponse?.cart?.metadata;
    if (meta is Map && meta['loyalty_checkout_apply'] is Map) {
      return Map<String, dynamic>.from(meta['loyalty_checkout_apply'] as Map);
    }
    return null;
  }

  /// Loyalty discount from cart metadata (same pattern as wallet_split)
  num get _loyaltyDiscount {
    final meta = cartResponse?.cart?.metadata;
    if (meta is Map && meta['loyalty_checkout_apply'] is Map) {
      final apply = meta['loyalty_checkout_apply'];
      // Field is "points_to_apply" (deferred debit) or "points_applied" (legacy)
      final pts = apply['points_to_apply'] ?? apply['points_applied'] ?? 0;
      if ((pts as num) > 0) return (apply['discount_amount'] ?? 0) as num;
    }
    return 0;
  }

  double _walletAmountFromMetadata() {
    final metadata = _cartMetadataMap();
    if (metadata['wallet_auto_apply_dismissed'] == true) {
      return 0;
    }
    final walletSplit = metadata['wallet_split'];
    if (walletSplit is Map) {
      return _doubleFromDynamic(walletSplit['wallet_amount']);
    }
    return 0;
  }

  int get _loyaltyPointsApplied {
    final meta = cartResponse?.cart?.metadata;
    if (meta is Map && meta['loyalty_checkout_apply'] is Map) {
      final apply = meta['loyalty_checkout_apply'];
      final pts = apply['points_to_apply'] ?? apply['points_applied'] ?? 0;
      if ((pts as num) > 0) return pts.toInt();
    }
    return 0;
  }

  double _displayTotalAmount() {
    final total = _doubleFromDynamic(cartResponse?.cart?.total);
    final walletAmount =
        splitActive ? splitWalletAmount : _walletAmountFromMetadata();
    final loyaltyAmount = _loyaltyDiscountAmount();
    return (total - walletAmount - loyaltyAmount).clamp(0, double.infinity);
  }

  void _syncPricingStateFromCart() {
    final metadata = _cartMetadataMap();
    final walletSplit = metadata['wallet_split'];
    final isDismissed = metadata['wallet_auto_apply_dismissed'] == true;
    final walletAmount = walletSplit is Map
        ? _doubleFromDynamic(walletSplit['wallet_amount'])
        : 0.0;
    final gatewayAmount = walletSplit is Map
        ? _doubleFromDynamic(walletSplit['gateway_amount'])
        : 0.0;

    if (!mounted) return;
    setState(() {
      splitActive = !isDismissed && walletAmount > 0;
      splitWalletAmount = splitActive ? walletAmount : 0;
      splitGatewayAmount = splitActive ? gatewayAmount : 0;
      splitFullCoverage = splitActive && gatewayAmount <= 0;
    });
  }

  // ===== Payment Method Card =====
  Widget _buildPaymentMethodCard() {
    final providerName = _getProviderName(pp_id, paymentProviders);
    final providers = isSplitPaymentMode
        ? paymentProviders.where((p) => p.id != 'pp_wallet_wallet').toList()
        : paymentProviders;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EC)),
      ),
      child: InkWell(
        onTap: () => showPaymentMethodsBottomSheet(context, providers),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _providerColor(pp_id).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_providerIcon(pp_id),
                    color: _providerColor(pp_id), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: UiTypography.cardTitle().copyWith(
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      providerName,
                      style: UiTypography.cardMeta(),
                    ),
                  ],
                ),
              ),
              Text(
                'Change',
                style: UiTypography.cardAction(color: AppColors.primary),
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Ajio-style Bottom Bar =====
  Widget _buildAjioBottomBar() {
    final amount = CurrencyUtil.appendCurrency(
      _displayTotalAmount().toStringAsFixed(2),
    );
    final providerName = _getProviderName(pp_id, paymentProviders);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EC))),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, -4),
            blurRadius: 18,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Total amount + View details
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cartSyncing ? 'Updating total' : 'Total',
                      style: UiTypography.cardMeta(),
                    ),
                    if (cartSyncing) ...[
                      const SizedBox(width: 6),
                      _syncingIndicator(),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                AnimatedOpacity(
                  opacity: cartSyncing ? 0.5 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UiTypography.cardPrice(color: AppColors.textColor)
                        .copyWith(fontSize: 22, letterSpacing: -0.3),
                  ),
                ),
                GestureDetector(
                  onTap: _scrollToPriceDetails,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View details',
                          style: UiTypography.cardMeta(color: AppColors.primary)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Icon(Icons.keyboard_arrow_up_rounded,
                            color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Right: dominant Checkout CTA with payment method
          Expanded(
            flex: 3,
            child: ElevatedButton(
              // Checkout waits until queued cart changes are confirmed.
              onPressed: cartLoading || cartSyncing
                  ? null
                  : () {
                      if (cartResponse?.cart?.error == true) {
                        AppUtils.showToast(
                            AppStrings.remove_unavailable_stock_items);
                        return;
                      }
                      if ((cartResponse?.cart?.shippingAddress?.address1 ?? '')
                          .isEmpty) {
                        AppUtils.showToast(AppStrings.add_address_to_proceed);
                        return;
                      }
                      if (!addressLoading) {
                        placeOrder(pp_id ?? 'pp_system_default');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                elevation: 0,
                minimumSize: const Size(double.infinity, 54),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: cartLoading
                    ? const SizedBox(
                        key: ValueKey('loader'),
                        height: 38,
                        child: Center(
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        key: const ValueKey('text'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Checkout',
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            providerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
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

  Widget _priceRow(String label, String value,
      {Color? valueColor, bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.secondaryFontStyle(
                  fontSize: fontSize,
                  color: AppColors.textColor.withOpacity(0.65),
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                ).copyWith(height: 1.5)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                maxLines: 2,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: fontSize,
                  color: valueColor ?? AppColors.textColor,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }

  Widget _syncingIndicator() => SizedBox(
        height: 12,
        width: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.6,
          color: AppColors.primary,
          semanticsLabel: 'Updating totals',
        ),
      );

  static const String _dismissedCouponPrefsKey = 'coupon_removed_dismissed';

  Future<void> _loadDismissedCouponKey() async {
    final key =
        await SharedPreferencesUtil().getString(_dismissedCouponPrefsKey);
    if (mounted) setState(() => _dismissedCouponKey = key);
  }

  void _dismissCouponRemoved(CouponRemoved notice) {
    setState(() => _dismissedCouponKey = notice.key);
    SharedPreferencesUtil().saveString(_dismissedCouponPrefsKey, notice.key);
  }

  // The backend removed a coupon that stopped qualifying; say why.
  Widget _buildCouponRemovedNotice() {
    final notice =
        CouponRemoved.fromCartMetadata(cartResponse?.cart?.metadata);
    if (notice == null || notice.key == _dismissedCouponKey) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5C451)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFF8A5A00), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                notice.message,
                style: UiTypography.cardMeta(color: const Color(0xFF8A5A00)),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _dismissCouponRemoved(notice),
            tooltip: 'Dismiss coupon removed message',
            icon: const Icon(Icons.close_rounded,
                color: Color(0xFF8A5A00), size: 18),
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EC)),
      ),
      child: InkWell(
        onTap: canUseCoupon ? () => showPromoCodeBottomSheet(context) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isApplied
                      ? const Color(0xFFE7F7F0)
                      : AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  color:
                      isApplied ? const Color(0xFF1FA971) : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isApplied ? 'Coupon Applied' : 'Apply Coupon',
                      style: UiTypography.cardTitle().copyWith(
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    isApplied
                        ? Text(
                            '${coupon!.code} · Save ${CurrencyUtil.appendCurrency(discount.toStringAsFixed(2))}',
                            style: UiTypography.cardMeta(
                                color: const Color(0xFF1FA971)),
                          )
                        : Text(
                            canUseCoupon
                                ? 'Have a code? Tap to add and save'
                                : 'Remove wallet to apply coupon',
                            style: UiTypography.cardMeta(),
                          ),
                  ],
                ),
              ),
              Text(
                isApplied ? 'Change' : 'Add',
                style: UiTypography.cardAction(color: AppColors.primary),
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.primary, size: 20),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: splitActive ? AppColors.primary : const Color(0xFFE5E7EC),
          width: splitActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: canUseWallet
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: canUseWallet ? AppColors.primary : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use Wallet Balance',
                        style: UiTypography.cardTitle(
                          color:
                              canUseWallet ? AppColors.textColor : Colors.grey,
                        ).copyWith(fontSize: 15, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Available: ${CurrencyUtil.appendCurrency(walletBalance.toStringAsFixed(2))}',
                        style: UiTypography.cardMeta(),
                      ),
                      if (walletUsageLimit != null &&
                          walletUsageLimit!.enabled &&
                          walletUsageLimit!.displayText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Max usable: ${walletUsageLimit!.displayText}',
                            style: TextStyle(
                                fontSize: 11, color: Colors.orange.shade700),
                          ),
                        ),
                      if (!canUseWallet)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Remove coupon to use wallet',
                            style: TextStyle(
                                fontSize: 11, color: Colors.orange.shade700),
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
                        onChanged:
                            canUseWallet ? (_) => _toggleWalletSplit() : null,
                        activeColor: AppColors.primary,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade200,
                      ),
              ],
            ),
          ),
          if (splitActive && splitWalletAmount > 0) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EC)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFE7F7F0),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF1FA971), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${CurrencyUtil.appendCurrency(splitWalletAmount.toStringAsFixed(2))} will be deducted from your wallet',
                      style:
                          UiTypography.cardMeta(color: const Color(0xFF1FA971))
                              .copyWith(fontWeight: FontWeight.w600),
                    ),
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
