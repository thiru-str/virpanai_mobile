import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/model/register_response.dart' as RegisterResponse;
import 'package:waioz/model/shipping_response.dart';
import 'package:waioz/ui/address_list_page.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/order_placed_page.dart';
import 'package:waioz/ui/icici_payment_page.dart';
import 'package:waioz/ui/widgets/cart_button.dart';
import 'package:waioz/ui/widgets/cart_calculation.dart';
import 'package:waioz/ui/widgets/loyalty_checkout_widget.dart';
import 'package:waioz/ui/widgets/loyalty_earn_preview.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/check_out_item_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/custom_popup_widget.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/payment_method_bottom_sheet.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/ui/widgets/shipping_method_bottom_sheet.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import 'package:lottie/lottie.dart';

import '../api/api_service.dart';
import '../model/home_page_response.dart';
import '../utility/app_utils.dart';
import '../utility/currency_util.dart';
import '../utility/page_route_utils.dart';
import '../utility/shared_preferences_util.dart';
import 'package:waioz/model/check_out_shipping_address_model.dart' as CheckOut;

import '../model/payment_method_response.dart';
import '../model/wallet_response.dart';
import '../utility/stripe_service.dart';

class CheckOutPage extends StatefulWidget {
  final CartResponse? cartResponse;

  const CheckOutPage({super.key, required this.cartResponse});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  CartResponse? cartResponse;
  ShippingResponse? shippingResponse;
  bool apiLoading = true;
  bool addAddress = true;
  bool addPaymentMethod = false;
  bool addShippingOption = true;
  RegisterResponse.Address? selectedAddress;
  String? pp_id;
  String? pp_title;
  bool placeOrderApiLoading = false;
  ShippingOption? shippingOption;

  Razorpay razorpay = Razorpay();

  // Split payment state
  bool splitActive = false;
  double splitWalletAmount = 0;
  double splitGatewayAmount = 0;
  bool splitFullCoverage = false;
  bool isSplitPaymentMode =
      false; // true when wallet extension is enabled with split_payment mode

  // Wallet state
  double walletBalance = 0;
  bool walletLoading = false;
  TopUpConfig? walletTopupConfig;

  @override
  void initState() {
    super.initState();
    cartResponse = widget.cartResponse;
    getShippingInfo();
    _loadWalletBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeaderAppBar(
          title: AppStrings.check_out,
          onBackTap: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        body: Scaffold(
          backgroundColor: Colors.white,
          body: apiLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CheckoutItemCard(
                              //     title: AppStrings.shipping_address,
                              //     subtitle: addAddress
                              //         ? selectedAddress!.address1!
                              //         : AppStrings.add_shipping_address,
                              //     onTap: () {
                              //       PageRouteUtils.pushWithSlide(
                              //           context,
                              //           AddressListPage(
                              //             isFromCheckout: true,
                              //             onSelectedAddress: (address) {
                              //               setState(() {
                              //                 addAddress = true;
                              //                 selectedAddress = address;
                              //                 apiLoading = true;
                              //               });
                              //               updateAddress(address);
                              //             },
                              //           ));
                              //     }),
                              // CheckoutItemCard(
                              //     title: AppStrings.shipping_method,
                              //     subtitle: addShippingOption
                              //         ? shippingOption?.name ??
                              //             AppStrings.add_shipping_method
                              //         : AppStrings.add_shipping_method,
                              //     onTap: () async {
                              //       if (!addAddress) {
                              //         AppUtils.showToast(
                              //             AppStrings.choose_shipping_address);
                              //         return;
                              //       }
                              //       showShippingBottomSheet(context,
                              //           shippingResponse!.shippingOptions!);
                              //     }),
                              // Wallet Split Banner — shown in split_payment mode
                              // Payment method selection — hide if wallet covers full amount in split mode
                              if (!(splitActive && splitFullCoverage))
                                CheckoutItemCard(
                                    title: splitActive
                                        ? 'Pay Remaining'
                                        : AppStrings.payemnt_method,
                                    subtitle: addPaymentMethod
                                        ? pp_title!
                                        : AppStrings.add_payment_method,
                                    onTap: () async {
                                      if (!addAddress) {
                                        AppUtils.showToast(
                                            AppStrings.choose_shipping_address);
                                        return;
                                      } else if (!addShippingOption) {
                                        AppUtils.showToast(
                                            AppStrings.choose_shipping_address);
                                        return;
                                      }
                                      Global? global = await getGlobal();
                                      if (global != null) {
                                        // Filter out wallet from payment methods in split mode
                                        final providers = isSplitPaymentMode
                                            ? global.paymentProvider!
                                                .where((p) =>
                                                    p.id != 'pp_wallet_wallet')
                                                .toList()
                                            : global.paymentProvider!;
                                        showPaymentMethodsBottomSheet(
                                            context, providers);
                                      }
                                    }),

                              // Wallet Balance Info (shows when wallet is selected in full_payment mode)
                              if (pp_id == 'pp_wallet_wallet' && !splitActive)
                                _buildWalletInfoWidget(),

                              const SizedBox(height: 12),

                              // Loyalty earn preview — based on actual paid amount
                              Builder(builder: (_) {
                                final meta = cartResponse?.cart?.metadata;
                                final loyaltyOff = (meta is Map &&
                                        meta['loyalty_checkout_apply'] is Map &&
                                        ((meta['loyalty_checkout_apply']
                                                    ['points_to_apply'] ??
                                                0) as num) >
                                            0)
                                    ? (meta['loyalty_checkout_apply']
                                            ['discount_amount'] ??
                                        0) as num
                                    : 0;
                                return LoyaltyEarnPreview(
                                  orderTotal:
                                      (cartResponse!.cart!.itemSubtotal ??
                                              cartResponse!.cart!.total ??
                                              0) -
                                          loyaltyOff,
                                );
                              }),

                              const SizedBox(height: 4),

                              // Loyalty checkout apply widget
                              LoyaltyCheckoutWidget(
                                cartId: cartResponse!.cart!.id!,
                                loyaltyApply: cartResponse?.cart?.metadata?['loyalty_checkout_apply'] as Map<String, dynamic>?,
                                cartTotal: cartResponse?.cart?.total,
                                walletAmount: splitActive ? splitWalletAmount : 0,
                                walletApplied: splitActive && splitWalletAmount > 0,
                                hasActiveCoupon: (cartResponse?.cart?.promotions ?? []).isNotEmpty,
                                onApplied: () {
                                  getCartApi();
                                },
                                onRemoved: () {
                                  getCartApi();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: placeOrderApiLoading
                ? Center(
                    child: Lottie.asset(AppAssets.place_order_lottie,
                        fit: BoxFit.cover))
                : CartButton(
                    amount: CurrencyUtil.appendCurrency((splitActive
                            ? splitGatewayAmount
                            : (cartResponse?.cart?.total ?? 0))
                        .toStringAsFixed(2)),
                    title: splitActive && splitFullCoverage
                        ? 'Pay from Wallet'
                        : AppStrings.place_order,
                    onPressed: () {
                      if (!addAddress) {
                        AppUtils.showToast(AppStrings.add_shipping_address);
                      } else if (!addShippingOption) {
                        AppUtils.showToast(AppStrings.add_shipping_method);
                      } else if (splitActive && splitFullCoverage) {
                        // Split mode: wallet covers full amount — complete directly
                        setState(() => placeOrderApiLoading = true);
                        // Set wallet as payment method then complete
                        updatePaymentMethod('pp_wallet_wallet');
                      } else if (!addPaymentMethod) {
                        AppUtils.showToast(AppStrings.add_payment_method);
                      } else {
                        // validations done proceed to place order
                        updatePaymentMethod(pp_id!);
                      }
                    }),
          ),
        ));
  }

  void makeRazorPayCall(String orderId) {
    // Use wallet-reduced amount if split is active, otherwise full cart total
    final paymentAmount = (splitActive && splitGatewayAmount > 0)
        ? splitGatewayAmount
        : cartResponse!.cart!.total!;
    var options = {
      'key': AppConfig.razorPayKey,
      'amount': paymentAmount.toStringAsFixed(2),
      'name': AppConfig.appName,
      'description': '${AppStrings.payment_to} ${AppConfig.appName}',
      'order_id': orderId,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
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
    setState(() {
      placeOrderApiLoading = true;
    });
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
      setState(() {
        placeOrderApiLoading = true;
      });
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
        setState(() {
          placeOrderApiLoading = true;
        });
        completeCart();
      },
    );
  }

  Future<void> _loadWalletBalance() async {
    setState(() => walletLoading = true);
    try {
      final walletData = await ApiService().getWalletBalance(context);
      if (mounted) {
        setState(() {
          walletBalance = walletData.wallet?.balance ?? 0;
          walletTopupConfig = walletData.topupConfig;
          walletLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => walletLoading = false);
      debugPrint('Error loading wallet balance: $e');
    }
  }

  Widget _buildWalletInfoWidget() {
    if (walletLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final cartTotal = cartResponse?.cart?.total ?? 0;
    final hasSufficientBalance = walletBalance >= cartTotal;
    final shortfall = cartTotal - walletBalance;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasSufficientBalance
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
        color:
            hasSufficientBalance ? Colors.green.shade50 : Colors.orange.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Balance',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(
                          '₹${walletBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Order Total',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(
                          '₹${cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasSufficientBalance)
            Text(
              'Your wallet balance covers the full order amount.',
              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
            )
          else ...[
            Text(
              'Insufficient balance. You need ₹${shortfall.toStringAsFixed(2)} more.',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
            ),
            if (walletTopupConfig?.canTopUp == true) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _initiateWalletTopUp(shortfall),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('Add ₹${shortfall.toStringAsFixed(0)} to Wallet'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void makeWalletPayCall() async {
    setState(() => placeOrderApiLoading = true);

    try {
      // Re-check wallet balance before placing order
      final walletData = await ApiService().getWalletBalance(context);
      final balance = walletData.wallet?.balance ?? 0;
      final cartTotal = cartResponse?.cart?.total ?? 0;

      if (balance >= cartTotal) {
        // Sufficient balance — place order directly
        completeCart();
      } else {
        final shortfall = cartTotal - balance;
        setState(() {
          placeOrderApiLoading = false;
          walletBalance = balance;
          walletTopupConfig = walletData.topupConfig;
        });

        if (walletData.topupConfig?.canTopUp == true) {
          _showWalletTopUpDialog(shortfall, walletData);
        } else {
          AppUtils.showToast(
              'Insufficient wallet balance. Need ₹${shortfall.toStringAsFixed(2)} more.');
        }
      }
    } catch (e) {
      setState(() => placeOrderApiLoading = false);
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
            const Text('Insufficient Balance'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet Balance: ₹${walletData.wallet?.balance?.toStringAsFixed(2) ?? "0.00"}',
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
                color: Colors.orange.shade800,
              ),
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
              _initiateWalletTopUp(shortfall);
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

  void _initiateWalletTopUp(double amount) async {
    setState(() => placeOrderApiLoading = true);

    try {
      final result = await ApiService().initiateWalletTopUp(context, amount);

      if (result.razorpayOrderId != null && result.razorpayKey != null) {
        // Open Razorpay for top-up
        final topUpRazorpay = Razorpay();
        topUpRazorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
            (PaymentSuccessResponse response) async {
          // Confirm top-up on backend
          try {
            await ApiService().confirmWalletTopUp(
              context,
              response.paymentId!,
              amount,
            );
          } catch (e) {
            debugPrint('Failed to confirm top-up: $e');
          }

          topUpRazorpay.clear();

          // Refresh wallet balance to show updated info
          setState(() => placeOrderApiLoading = false);
          _loadWalletBalance();
          AppUtils.showToast('Balance added successfully');
        });

        topUpRazorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
            (PaymentFailureResponse response) {
          topUpRazorpay.clear();
          setState(() => placeOrderApiLoading = false);
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
          'theme': {'color': AppUtils.colorToHex(AppColors.primary)},
        };
        topUpRazorpay.open(options);
      } else {
        setState(() => placeOrderApiLoading = false);
        AppUtils.showToast('Wallet top-up is not available');
      }
    } catch (e) {
      setState(() => placeOrderApiLoading = false);
      AppUtils.showToast('Failed to initiate top-up');
      debugPrint('Top-up error: $e');
    }
  }

  void getCartApi() async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      setState(() {
        apiLoading = false;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void getShippingInfo() async {
    try {
      final ApiService apiService = ApiService();
      var response = await apiService.getShippingInfo(context);
      if (mounted) {
        final options = response.shippingOptions ?? [];
        final first = options.isNotEmpty ? options.first : null;
        setState(() {
          apiLoading = false;
          shippingResponse = response;
          if (first != null) {
            shippingOption = first;
            addShippingOption = true;
          } else {
            addShippingOption = false;
          }
        });
        if (first != null) updateShippingMethod();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiLoading = false;
          addShippingOption = false;
        });
      }
      print(e);
    }
  }

  Future<Global?> getGlobal() async {
    dynamic global = await SharedPreferencesUtil().getMap('global');
    if (global != null) {
      return Global.fromJson(global);
    }
    return null;
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
          walletBalance: walletBalance > 0 ? walletBalance : null,
          onPaymentSelected: (PaymentProvider paymentProvider) {
            setState(() {
              addPaymentMethod = true;
              pp_id = paymentProvider.id;
              pp_title = paymentProvider.name;
            });
            // Load wallet balance when wallet is selected
            if (paymentProvider.id == 'pp_wallet_wallet') {
              _loadWalletBalance();
            }
          },
        );
      },
    );
  }

  void showShippingBottomSheet(
      BuildContext context, List<ShippingOption> shippingOptions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ShippingMethodBottomSheet(
          shippingOptions: shippingOptions,
          selectedOption: shippingOption,
          onShippingSelected: (ShippingOption shippingOption) {
            setState(() {
              addShippingOption = true;
              this.shippingOption = shippingOption;
              apiLoading = true;
            });
            updateShippingMethod();
          },
        );
      },
    );
  }

  void updateAddress(RegisterResponse.Address address) async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.updateAddress(
          context, convertToShippingAddress(address));
      setState(() {
        apiLoading = false;
        cartResponse;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void placeOrder() async {
    try {
      final ApiService apiService = ApiService();
      await apiService.placeOrder(context, pp_id!);
      setState(() {
        placeOrderApiLoading = false;
      });
      PageRouteUtils.pushAndRemoveUntil(
          context,
          OrderPlacedPage(
            orderId: '',
          ));
    } catch (e) {
      setState(() {
        placeOrderApiLoading = false;
      });
      print(e);
    }
  }

  void completeCart() async {
    try {
      final ApiService apiService = ApiService();
      final response = await apiService.completeCart(context);
      setState(() {
        placeOrderApiLoading = false;
      });
      PageRouteUtils.pushAndRemoveUntil(
          context,
          OrderPlacedPage(
            orderId: response.order?.id ?? '',
          ));
    } catch (e) {
      setState(() {
        placeOrderApiLoading = false;
      });
      print(e);
    }
  }

  void updateShippingMethod() async {
    try {
      final ApiService apiService = ApiService();
      cartResponse =
          await apiService.updateShippingMethod(context, shippingOption!.id!);
      setState(() {
        apiLoading = false;
        cartResponse;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
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

  void updatePaymentMethod(String paymentProviderId) async {
    // ICICI is redirect-based — place-order handles the full session creation.
    // Skip update-payment-method to avoid duplicate payment sessions.
    if (paymentProviderId == 'pp_icici_icici') {
      _makeIciciPayment();
      return;
    }

    final ApiService apiService = ApiService();
    dynamic apiResponse = await apiService.updatePaymentMethod(
        context, paymentProviderId, cartResponse!);

    switch (paymentProviderId) {
      case 'pp_razorpay_razorpay':
        String? orderId = extractOrderId(apiResponse);
        if (orderId != null) {
          makeRazorPayCall(orderId);
        }
        break;
      case 'pp_stripe_stripe':
        String? clientSecret = extractClientSecret(apiResponse);
        if (clientSecret != null) {
          makeStripeCall(clientSecret);
        }
        break;
      case 'pp_system_default':
        setState(() {
          placeOrderApiLoading = true;
        });
        completeCart();
        break;
      case 'pp_neft_neft':
        makeNEFTPayCall();
        break;
      case 'pp_wallet_wallet':
        makeWalletPayCall();
        break;
    }
  }

  Future<void> _makeIciciPayment() async {
    setState(() => placeOrderApiLoading = true);
    try {
      final redirectUrl = await ApiService().initiateIciciPayment(context);
      debugPrint('ICICI redirect URL: $redirectUrl');
      if (!mounted) return;
      setState(() => placeOrderApiLoading = false);

      if (redirectUrl == null || redirectUrl.isEmpty) {
        AppUtils.showToast('Failed to initiate ICICI payment. Please try again.');
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
      setState(() => placeOrderApiLoading = false);
      AppUtils.showToast('Failed to initiate ICICI payment. Please try again.');
    }
  }

  String? extractOrderId(dynamic response) {
    try {
      if (response is PaymentMethodResponse) {
        return response
            .paymentCollection?.paymentSessions?.firstOrNull?.data?.id;
      }
      return response["payment_collection"]["payment_sessions"]?[0]["data"]
          ["id"];
    } catch (e) {
      print("Error extracting order ID: $e");
      return null;
    }
  }

  String? extractClientSecret(dynamic response) {
    try {
      if (response is PaymentMethodResponse) {
        return response.paymentCollection?.paymentSessions?.firstOrNull?.data
            ?.clientSecret;
      }
      return response["payment_collection"]["payment_sessions"]?[0]["data"]
          ["client_secret"];
    } catch (e) {
      debugPrint("Error extracting client secret: $e");
      return null;
    }
  }
}
