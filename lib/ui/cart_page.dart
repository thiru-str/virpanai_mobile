import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:waioz/ui/tutorial/tutorial_coordinator.dart';
import 'package:waioz/ui/tutorial/tutorial_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:waioz/model/cross_sell_products_response.dart';
import 'package:waioz/model/shipping_response.dart' as PaymentSessionData;
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
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
import 'package:waioz/model/delivery_schedule_response.dart';
import 'package:waioz/ui/widgets/fulfillment_method_widget.dart';
import 'package:waioz/ui/widgets/loyalty_checkout_widget.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/payment_method_bottom_sheet.dart';
import 'package:waioz/ui/icici_payment_page.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/product_recommendation_section.dart';
import 'package:waioz/ui/widgets/app_loader.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
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
import 'order_placed_page.dart';

class CartPage extends StatefulWidget {
  final bool isFromBottomNav;

  const CartPage({super.key, this.isFromBottomNav = false});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin, TutorialMixin {
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

  // Fulfillment selection
  FulfillmentSelection _fulfillment = const FulfillmentSelection(type: 'standard');

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
  final GlobalKey _fulfillmentKey = GlobalKey();
  final GlobalKey _loyaltyKey = GlobalKey();
  final GlobalKey _couponKey = GlobalKey();
  final GlobalKey _checkoutBtnKey = GlobalKey();
  final GlobalKey _cartEmptyKey = GlobalKey();

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
          if (apiLoading) const AppLoader(),
          if (!apiLoading) cartResponse?.cart?.items?.isNotEmpty ?? false
                  ? Scaffold(
                      backgroundColor: const Color(0xFFF9F9FB),
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Fulfillment method — right after address (Zepto pattern)
                            Padding(
                              key: _fulfillmentKey,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: FulfillmentMethodWidget(
                                cartMetadata: cartResponse?.cart?.metadata is Map<String, dynamic>
                                    ? cartResponse!.cart!.metadata as Map<String, dynamic>
                                    : null,
                                onChanged: (sel) async {
                                  setState(() => _fulfillment = sel ?? const FulfillmentSelection(type: 'standard'));
                                  try {
                                    await ApiService().updateCartFulfillment(
                                      context,
                                      _fulfillment.toMetadata(),
                                    );
                                  } catch (_) {}
                                },
                              ),
                            ),

                            Visibility(
                              visible: cartResponse!.cart!.items!.isNotEmpty &&
                                  _fulfillment.type != 'pickup',
                              child: AppReveal(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
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
                                      final originalIndex = cartResponse!
                                          .cart!.items!
                                          .indexOf(cartItem);
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
                                          onTap: cartItem.productId != null
                                              ? () async {
                                                  await PageRouteUtils.push(
                                                    context,
                                                    ProductDetailPage(
                                                        productId:
                                                            cartItem.productId!),
                                                  );
                                                  if (mounted) getCartApi();
                                                }
                                              : null,
                                          onRemoveAll: () {
                                            setState(() {
                                              cartResponse!
                                                  .cart!
                                                  .items![originalIndex]
                                                  .isUpdating = true;
                                            });
                                            removeCart(
                                                cartItem.id!, originalIndex);
                                          },
                                          onIncrease: () {
                                            setState(() {
                                              cartResponse!
                                                  .cart!
                                                  .items![originalIndex]
                                                  .isUpdating = true;
                                            });
                                            updateCart(cartItem.quantity! + 1,
                                                cartItem.id!, originalIndex);
                                          },
                                          onDecrease: () async {
                                            final item = cartResponse!
                                                .cart!.items![originalIndex];
                                            final currentQty =
                                                item.quantity ?? 0;
                                            final stockQty =
                                                item.inventoryQuantity ?? 0;

                                            setState(
                                                () => item.isUpdating = true);

                                            if (currentQty <= 1) {
                                              removeCart(
                                                  item.id!, originalIndex);
                                              return;
                                            }

                                            if (!(item.inStock ?? false)) {
                                              if (stockQty == 0) {
                                                removeCart(
                                                    item.id!, originalIndex);
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
                                                  updateCart(stockQty, item.id!,
                                                      originalIndex);
                                                } else {
                                                  setState(() =>
                                                      item.isUpdating = false);
                                                }
                                                return;
                                              }
                                            }

                                            updateCart(currentQty - 1, item.id!,
                                                originalIndex);
                                          },
                                          onUpdateQuantity:
                                              (newQty) async {
                                            final item = cartResponse!
                                                .cart!.items![originalIndex];
                                            final stockQty =
                                                item.inventoryQuantity ?? 0;

                                            setState(
                                                () => item.isUpdating = true);

                                            if (newQty <= 0) {
                                              removeCart(
                                                  item.id!, originalIndex);
                                              return;
                                            }

                                            if (stockQty > 0 &&
                                                newQty > stockQty) {
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
                                                updateCart(stockQty, item.id!,
                                                    originalIndex);
                                              } else {
                                                setState(() =>
                                                    item.isUpdating = false);
                                              }
                                              return;
                                            }

                                            updateCart(
                                                newQty, item.id!, originalIndex);
                                          },
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
                              Container(
                                key: _loyaltyKey,
                                child: LoyaltyCheckoutWidget(
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
                              ),

                            // Coupon Card (Ajio style)
                            KeyedSubtree(key: _couponKey, child: _buildCouponCard()),

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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Text(
                                          'Price Details',
                                          style:
                                              UiTypography.cardTitle().copyWith(
                                            fontSize: 16,
                                            height: 1.25,
                                            letterSpacing: -0.2,
                                          ),
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
                      bottomNavigationBar: Builder(
                        builder: (context) {
                          final bottomPad =
                              MediaQuery.viewPaddingOf(context).bottom;
                          return ColoredBox(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: bottomPad),
                              child: _buildAjioBottomBar(),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      key: _cartEmptyKey,
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
      bottomNavigationBar: null,
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
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      final cartId = cartResponse?.cart?.id;
      if (cartResponse != null) emitEvent(cartResponse!);
      if (cartId != null && cartId.isNotEmpty) {
        unawaited(getCrossSellingProductsApi(cartId));
      } else {
        crossSellProductsResponse = null;
      }
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
      _syncPricingStateFromCart();
      // Load wallet info after cart is ready
      await _loadWalletInfo();
      _maybeStartCartTutorial();
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      debugPrint(' error in cart $e');
    }
  }

  void _maybeStartCartTutorial() => maybeStartTutorial(
        TutorialPhase.cart, _showCartTutorial,
        delay: const Duration(milliseconds: 600));

  Future<void> _scrollToKey(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
    await Future.delayed(const Duration(milliseconds: 120));
  }

  void _showCartTutorial() {
    final hasItems = cartResponse?.cart?.items?.isNotEmpty == true;
    final targets = <TargetFocus>[];

    final hasLoyalty = hasItems && _loyaltyKey.currentContext != null;
    final hasCoupon = hasItems && _couponKey.currentContext != null;
    final hasPrice = hasItems && _priceDetailsSectionKey.currentContext != null;

    // Step 1 — Fulfillment (top of page, always visible)
    if (hasItems && _fulfillmentKey.currentContext != null) {
      targets.add(TargetFocus(
        keyTarget: _fulfillmentKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        paddingFocus: 8,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (ctx, ctrl) => TutorialTooltip(
              title: 'Delivery or Pickup',
              body: 'Choose home delivery with a time slot, or collect yourself for free',
              controller: ctrl,
              onBeforeNext: () => _scrollToKey(
                hasLoyalty ? _loyaltyKey : hasCoupon ? _couponKey : _priceDetailsSectionKey,
              ),
            ),
          ),
        ],
      ));
    }

    // Step 2 — Loyalty (scroll into view)
    if (hasLoyalty) {
      targets.add(TargetFocus(
        keyTarget: _loyaltyKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        paddingFocus: 8,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (ctx, ctrl) => TutorialTooltip(
              title: 'Loyalty Points',
              body: 'Use your earned points for a discount on this order',
              controller: ctrl,
              onBeforeNext: () => _scrollToKey(
                hasCoupon ? _couponKey : _priceDetailsSectionKey,
              ),
            ),
          ),
        ],
      ));
    }

    // Step 3 — Coupon (scroll into view, just below loyalty)
    if (hasCoupon) {
      targets.add(TargetFocus(
        keyTarget: _couponKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        paddingFocus: 8,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (ctx, ctrl) => TutorialTooltip(
              title: 'Apply Coupon',
              body: 'Have a coupon code? Tap here to apply it and save on your order',
              controller: ctrl,
              onBeforeNext: hasPrice ? () => _scrollToKey(_priceDetailsSectionKey) : null,
            ),
          ),
        ],
      ));
    }

    // Step 4 — Price Breakdown (scroll into view)
    if (hasPrice) {
      targets.add(TargetFocus(
        keyTarget: _priceDetailsSectionKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        paddingFocus: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (ctx, ctrl) => TutorialTooltip(
              title: 'Price Breakdown',
              body: "See exactly what you're paying — items, delivery & any discounts",
              controller: ctrl,
            ),
          ),
        ],
      ));
    }

    // Step 5 — Checkout button (sticky footer, always visible)
    if (hasItems && _checkoutBtnKey.currentContext != null) {
      targets.add(TargetFocus(
        keyTarget: _checkoutBtnKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        paddingFocus: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (ctx, ctrl) => TutorialTooltip(
              title: 'Ready to Order?',
              body: "Tap Checkout when you're done reviewing your cart",
              controller: ctrl,
              isLast: true,
            ),
          ),
        ],
      ));
    }

    if (targets.isEmpty) {
      TutorialCoordinator().complete();
      return;
    }

    // pulseEnable: false skips the pulse-reverse phase entirely.
    // Duration.zero makes reverse+forward fire synchronously in the same frame —
    // Flutter batches the setState calls so the overlay never renders transparent.
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.80,
      hideSkip: true,
      pulseEnable: false,
      focusAnimationDuration: Duration.zero,
      unFocusAnimationDuration: Duration.zero,
      onFinish: () {
        TutorialCoordinator().advanceTo(TutorialPhase.wishlist);
        eventBus.fire(TabSwitchEvent(3));
      },
      onSkip: () {
        TutorialCoordinator().complete();
        return true;
      },
    ).show(context: context);
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

  void emitEvent(CartResponse cartResponse) {
    final productItems = (cartResponse.cart?.items ?? [])
        .where((item) => !item.isVirtualItem)
        .toList();
    final totalQty = productItems
        .map((item) => item.quantity ?? 0)
        .fold<int>(0, (sum, qty) => sum + qty);
    print('total qty ${totalQty}');
    eventBus.fire(ViewCartModel(
        totalQty, productItems.map((item) => item.thumbnail ?? '').toList()));
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

  void updateCart(int qty, String cartItemId, int index) async {
    try {
      debugPrint('calling update');
      final ApiService apiService = ApiService();
      await apiService.updateCart(context, qty, cartItemId);
      await getCartApi();
      if (!mounted) return;
      setState(() {
        if (cartResponse?.cart?.items != null &&
            index < cartResponse!.cart!.items!.length) {
          cartResponse!.cart!.items![index].isUpdating = false;
        }
      });
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
      await getCartApi();
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

  Future<void> updatePaymentMethod(String paymentProviderId) async {
    // ICICI is redirect-based — session created at place-order time, not here.
    if (paymentProviderId == 'pp_icici_icici') {
      setState(() => pp_id = 'pp_icici_icici');
      return;
    }
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
        orderId =
            response.paymentCollection?.paymentSessions?.firstOrNull?.data?.id;
        clientSecret = response.paymentCollection?.paymentSessions?.firstOrNull
            ?.data?.clientSecret;
        paytmData = paymentProviderId == 'pp_paytm_paytm'
            ? response.paymentCollection?.paymentSessions?.firstOrNull?.data
            : null;
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

  void _checkoutWithPaymentPicker() {
    final providers = isSplitPaymentMode
        ? paymentProviders.where((p) => p.id != 'pp_wallet_wallet').toList()
        : paymentProviders;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentMethodsBottomSheet(
        paymentProviders: providers,
        providerId: pp_id,
        walletBalance: walletBalance > 0 ? walletBalance : null,
        showConfirmButton: true,
        onPaymentSelected: (PaymentProvider paymentProvider) {
          if (_displayTotalAmount() <= 0 &&
              paymentProvider.id != 'pp_system_default') {
            AppUtils.showToast(
              'Your order is fully covered. Free orders can be placed only via Cash on Delivery.',
            );
            return;
          }
          () async {
            if (pp_id != paymentProvider.id) {
              await updatePaymentMethod(paymentProvider.id!);
            }
            placeOrder(paymentProvider.id!);
          }();
        },
      ),
    );
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

  /// Fetches available shipping options and attaches the first one to the cart.
  /// Retries once on failure. Returns true if a method was successfully
  /// attached (or was already present after the retry), false otherwise.
  Future<bool> _tryAttachShipping() async {
    final api = ApiService();
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final shipping = await api.getShippingInfo(context);
        final first = shipping.shippingOptions?.isNotEmpty == true
            ? shipping.shippingOptions!.first
            : null;
        if (first?.id == null) {
          AppUtils.showToast('No shipping method available for this address.');
          return false;
        }
        await api.updateShippingMethod(context, first!.id!);
        await getCartApi();
        if (cartResponse?.cart?.shippingMethods?.isNotEmpty == true) {
          return true;
        }
      } catch (e) {
        if (attempt == 1) {
          final msg = e.toString();
          if (msg.contains('DELIVERY_INVALID_ADDRESS')) {
            AppUtils.showToast(
                'We couldn\'t locate your address. Please update it or re-pick from the map.');
          } else if (msg.contains('DELIVERY_SERVICE_DOWN')) {
            AppUtils.showToast(
                'Delivery service temporarily unavailable. Please try again shortly.');
          } else {
            AppUtils.showToast('Could not attach shipping method. Please try again.');
          }
          return false;
        }
        // First attempt failed — wait briefly then retry once
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    AppUtils.showToast('Could not attach shipping method. Please try again.');
    return false;
  }

  void placeOrder(String paymentProviderId) async {
    // Refresh cart first — in-memory state may be stale; the shipping method
    // may already have been attached server-side since the last fetch.
    setState(() => cartLoading = true);
    await getCartApi();

    final hasShipping =
        (cartResponse?.cart?.shippingMethods?.isNotEmpty ?? false);
    if (!hasShipping) {
      // Attempt to fetch shipping options and attach the first available one.
      // Retries once on transient failure (network blip, Maps quota, etc.)
      // before surfacing the error to the user.
      final attached = await _tryAttachShipping();
      if (!attached) {
        setState(() => cartLoading = false);
        return;
      }
    } else {
      setState(() => cartLoading = false);
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
          onFailure: (message) {
            Navigator.pop(context);
            AppUtils.showToast(message);
            getCartApi();
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
              PageRouteUtils.pushAndRemoveUntil(
                context,
                OrderPlacedPage(orderId: orderId),
              );
            },
            onFailure: () {
              Navigator.pop(context);
              AppUtils.showToast('ICICI payment failed or was cancelled.');
              getCartApi();
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
      // Clear the completed cart so the next add-to-cart uses a fresh one
      await SharedPreferencesUtil().saveString('cart_id', '');
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => PageRouteUtils.pushAndRemoveUntil(
                context, const BottomNavPage()),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_ios_rounded,
                      color: AppColors.primary, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Continue Shopping',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
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
                Text(
                  'Total',
                  style: UiTypography.cardMeta(),
                ),
                const SizedBox(height: 1),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTypography.cardPrice(color: AppColors.textColor)
                      .copyWith(fontSize: 22, letterSpacing: -0.3),
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
              key: _checkoutBtnKey,
              onPressed: cartLoading
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
                        _checkoutWithPaymentPicker();
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
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 18),
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
