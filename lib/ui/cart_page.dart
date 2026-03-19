import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/ui/widgets/calculation_bottom_sheet.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/ui/widgets/cart_calculation.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/checkout_footer.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
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

class _CartPageState extends State<CartPage> {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
    super.dispose();
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
      /*body: Center(child: NoOrdersWidget(message: 'Your Cart is Empty', buttonText: 'Explore Categories', iconPath: AppAssets.ic_cart_empty, onButtonTap: (){})),);*/
      body: apiLoading
          ? const CartPageSkeleton()
          : cartResponse?.cart?.items?.isNotEmpty ?? false
              ? Scaffold(
                  backgroundColor: Colors.white,
                  body: Column(
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
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
                        ),
                      ),
                      AppReveal(
                        index: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  setState(() {
                                    showPriceBreakdown = !showPriceBreakdown;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Price breakdown',
                                        style: FontUtils.primaryFontStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        showPriceBreakdown
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: AppColors.textColor50,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Column(
                                  children: [
                                    CartCalculation(
                                      keyText: '${AppStrings.subTotal}:',
                                      valueText: CurrencyUtil.appendCurrency(
                                        (_numOrZero(cartResponse?.cart?.itemSubtotal) -
                                            _numOrZero(cartResponse?.cart?.items
                                                ?.where((item) => item.isPlatformFee)
                                                .fold<num>(0, (sum, item) => sum + (item.total ?? 0))))
                                            .toStringAsFixed(2),
                                      ),
                                    ),
                                    Visibility(
                                      visible: _numOrZero(cartResponse
                                              ?.cart?.discountSubtotal) >
                                          0,
                                      child: CartCalculation(
                                        keyText: '${AppStrings.discount}:',
                                        valueText:
                                            '- ${CurrencyUtil.appendCurrency(_numOrZero(cartResponse?.cart?.discountSubtotal).toStringAsFixed(2))}',
                                      ),
                                    ),
                                    CartCalculation(
                                      keyText: '${AppStrings.shipping}:',
                                      valueText: CurrencyUtil.appendCurrency(
                                        _numOrZero(cartResponse
                                                ?.cart?.shippingSubtotal)
                                            .toStringAsFixed(2),
                                      ),
                                    ),
                                    if ((cartResponse?.cart?.items?.any((item) => item.isPlatformFee) ?? false) &&
                                        (cartResponse!.cart!.items!.firstWhere((item) => item.isPlatformFee).total ?? 0) > 0)
                                      CartCalculation(
                                        keyText: '${AppStrings.platform_fee}:',
                                        valueText: CurrencyUtil.appendCurrency(
                                          (cartResponse!.cart!.items!
                                              .firstWhere((item) => item.isPlatformFee)
                                              .total ?? 0)
                                              .toStringAsFixed(2),
                                        ),
                                      ),
                                    CartCalculation(
                                      keyText: '${AppStrings.tax}:',
                                      valueText: CurrencyUtil.appendCurrency(
                                        _numOrZero(cartResponse?.cart?.taxTotal)
                                            .toStringAsFixed(2),
                                      ),
                                    ),
                                    CartCalculation(
                                      keyText: '${AppStrings.total}:',
                                      keyStyle: FontUtils.primaryFontStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      valueStyle: FontUtils.primaryFontStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      valueText: CurrencyUtil.appendCurrency(
                                        _numOrZero(cartResponse?.cart?.total)
                                            .toStringAsFixed(2),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                                crossFadeState: showPriceBreakdown
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 180),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if ((cartResponse?.cart?.promotions ?? [])
                                      .isEmpty) {
                                    showPromoCodeBottomSheet(context);
                                  } else {
                                    List<String> promotionCodes = cartResponse
                                            ?.cart?.promotions
                                            ?.map((promotion) => promotion.code)
                                            .where((code) => code != null)
                                            .cast<String>()
                                            .toList() ??
                                        [];
                                    removePromoCode(promotionCodes);
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const ImageIcon(
                                        AssetImage(AppAssets.ic_discount),
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          (cartResponse?.cart?.promotions ?? [])
                                                  .isEmpty
                                              ? AppStrings.enter_promo_code
                                              : cartResponse?.cart?.promotions
                                                      ?.firstOrNull?.code ??
                                                  '',
                                          style: FontUtils.primaryFontStyle(
                                              color: AppColors.textColor),
                                        ),
                                      ),
                                      Text(
                                        (cartResponse?.cart?.promotions ?? [])
                                                .isEmpty
                                            ? AppStrings.apply
                                            : AppStrings.remove,
                                        style: FontUtils.secondaryFontStyle(
                                            color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: SafeArea(
                    child: SizedBox(
                      height: 80,
                      child: CheckoutFooter(
                        svgPath: AppAssets.ic_payment_cash,
                        paymentMethod:
                            _getProviderName(pp_id, paymentProviders),
                        isLoading: cartLoading,
                        onPaymentTap: () {
                          showPaymentMethodsBottomSheet(
                              context, paymentProviders);
                        },
                        onInfoTap: () {
                          showCalculationBottomSheet(context, cartResponse!);
                        },
                        amount: CurrencyUtil.appendCurrency(
                            cartResponse!.cart!.total!.toStringAsFixed(2)),
                        onPlaceOrder: () {
                          if (cartResponse?.cart?.error == true) {
                            AppUtils.showToast(
                                AppStrings.remove_unavailable_stock_items);
                            return;
                          }
                          // Add checkout logic here
                          if ((cartResponse?.cart?.shippingAddress?.address1 ??
                                  '')
                              .isEmpty) {
                            AppUtils.showToast(
                                AppStrings.add_address_to_proceed);
                            return;
                          }
                          if (!addressLoading) {
                            placeOrder(pp_id!);
                            //PageRouteUtils.push(context, CheckOutPage(cartResponse: cartResponse));
                          }
                        },
                      ),
                    ),
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
    TextEditingController promoCodeController = TextEditingController();

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom Sheet Handle
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Promo Code Input
              Text(
                AppStrings.enter_promo_code,
                style: FontUtils.primaryFontStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: promoCodeController,
                decoration: InputDecoration(
                  hintText: AppStrings.promo_code,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Apply Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  String promoCode = promoCodeController.text.trim();
                  if (promoCode.isNotEmpty) {
                    Navigator.pop(context); // Close the bottom sheet
                    addPromoCode(promoCode); // Call API to apply promo code
                  }
                },
                child: Text(
                  (cartResponse?.cart?.promotions ?? []).isEmpty
                      ? AppStrings.apply
                      : AppStrings.remove,
                  style: FontUtils.primaryFontStyle(
                      fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
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
    var options = {
      'key': _getProviderKey(pp_id, paymentProviders),
      'amount': ((cartResponse?.cart?.total ?? 1) * 100).round(),
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
}
