import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:waioz/model/customer_detail_response.dart';
import 'package:waioz/model/customer_meta_data_response.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/model/register_response.dart' as RegisterResponse;
import 'package:waioz/model/shipping_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/address_list_page.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/order_placed_page.dart';
import 'package:waioz/ui/widgets/cart_button.dart';
import 'package:waioz/ui/widgets/cart_calculation.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/check_out_item_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/custom_popup_widget.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/payment_method_bottom_sheet.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/ui/widgets/shipping_method_bottom_sheet.dart';
import 'package:waioz/ui/widgets/show_create_customer_bottom_sheet.dart';
import 'package:waioz/ui/widgets/show_phone_bottom_sheet.dart';
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
  bool checkOutLoading = false;
  bool addAddress = true;
  bool addPaymentMethod = true;
  bool addShippingOption = true;
  bool addCustomerDetails = false;
  RegisterResponse.Address? selectedAddress;
  String? pp_id = 'pp_system_default';
  String? pp_title;
  String? customerData;
  bool placeOrderApiLoading = false;
  ShippingOption? shippingOption;

  Razorpay razorpay = Razorpay();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cartResponse = widget.cartResponse;
    String customerDetailsString = cartResponse?.cart?.metadata?.customerDetails??'';
    if (customerDetailsString.isNotEmpty)
    {
      Map<String, dynamic> customerDetails = json.decode(customerDetailsString);

      String firstName = customerDetails['first_name'] ?? '';
      String email = customerDetails['email'] ?? '';

      print('First Name: $firstName');
      print('Email: $email');

      setState(() {
        addCustomerDetails = true;
        customerData = '$firstName | $email';
      });
    }

    getShippingInfo();
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
        /*body: Center(child: NoOrdersWidget(message: 'Your Cart is Empty', buttonText: 'Explore Categories', iconPath: AppAssets.ic_cart_empty, onButtonTap: (){})),);*/
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
                              // CheckoutItemCard(
                              //     title: AppStrings.payemnt_method,
                              //     subtitle: addPaymentMethod
                              //         ? pp_title!
                              //         : AppStrings.add_payment_method,
                              //     onTap: () async {
                              //       if (!addAddress) {
                              //         AppUtils.showToast(
                              //             AppStrings.choose_shipping_address);
                              //         return;
                              //       } else if (!addShippingOption) {
                              //         AppUtils.showToast(
                              //             AppStrings.choose_shipping_address);
                              //         return;
                              //       }
                              //       Global? global = await getGlobal();
                              //       if (global != null) {
                              //         print(jsonEncode(global
                              //             .toJson())); // Convert and print JSON
                              //         showPaymentMethodsBottomSheet(
                              //             context, global.paymentProvider!);
                              //       }
                              //     }),
                              CheckoutItemCard(
                                  title: 'Customer Details',
                                  subtitle: addCustomerDetails
                                      ? customerData??''
                                      : 'Add Customer Details',
                                  onTap: () async {
                                    showPhoneBottomSheet(
                                      context: context,
                                      onSubmit: (phoneNumber) {
                                        debugPrint("Entered phone number: $phoneNumber");
                                        getCustomerApi(phoneNumber);
                                      },
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CartCalculation(
                            keyText: '${AppStrings.subTotal}:',
                            valueText: CurrencyUtil.appendCurrency(cartResponse!
                                .cart!.itemSubtotal!
                                .toStringAsFixed(2)),
                          ),
                          Visibility(
                              visible:
                                  cartResponse!.cart!.discountSubtotal! > 0,
                              child: CartCalculation(
                                keyText: '${AppStrings.discount}:',
                                valueText:
                                    '- ${CurrencyUtil.appendCurrency(cartResponse!.cart!.discountSubtotal!.toStringAsFixed(2))}',
                              )),
                          Visibility(
                              visible:
                                  cartResponse!.cart!.shippingSubtotal! > 0,
                              child: CartCalculation(
                                keyText: '${AppStrings.shipping}:',
                                valueText: CurrencyUtil.appendCurrency(
                                    cartResponse!.cart!.shippingSubtotal!
                                        .toStringAsFixed(2)),
                              )),
                          CartCalculation(
                            keyText: '${AppStrings.tax}:',
                            valueText: CurrencyUtil.appendCurrency(cartResponse!
                                .cart!.taxTotal!
                                .toStringAsFixed(2)),
                          ),
                          CartCalculation(
                            keyText: '${AppStrings.total}:',
                            valueText: CurrencyUtil.appendCurrency(
                                cartResponse!.cart!.total!.toStringAsFixed(2)),
                          ),
                        ],
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
                : checkOutLoading? Center(child: CircularProgressIndicator(color: AppColors.primary,),):CartButton(
                    amount: CurrencyUtil.appendCurrency(
                        (cartResponse?.cart?.total ?? 0).toStringAsFixed(2)),
                    title: AppStrings.place_order,
                    onPressed: () {
                      if (!addAddress) {
                        AppUtils.showToast(AppStrings.add_shipping_address);
                      } else if (!addShippingOption) {
                        AppUtils.showToast(AppStrings.add_shipping_method);
                      } else if (!addPaymentMethod) {
                        AppUtils.showToast(AppStrings.add_payment_method);
                      }  else if (!addCustomerDetails) {
                        AppUtils.showToast('Enter Customer Details');
                      } else {
                        // validations done proceed to place order
                        updatePaymentMethod(pp_id!);
                      }
                    }),
          ),
        ));
  }

  void makeRazorPayCall(String orderId) {
    var options = {
      'key': AppConfig.razorPayKey,
      'amount': cartResponse!.cart!.total!.toStringAsFixed(2),
      'name': AppConfig.appName,
      'description': 'Payment to ${AppConfig.appName}',
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

  void getCartApi() async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      setState(() {
        apiLoading = false;
      });

      String customerDetailsString = cartResponse?.cart?.metadata?.customerDetails??'';
      if (customerDetailsString.isNotEmpty) {
        Map<String, dynamic> customerDetails = json.decode(customerDetailsString);

        String firstName = customerDetails['first_name'] ?? '';
        String email = customerDetails['email'] ?? '';

        print('First Name: $firstName');
        print('Email: $email');

        setState(() {
          addCustomerDetails = true;
          customerData = '$firstName | $email';
        });
      }
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void getCustomerApi(String phoneNo) async {
    try {
      setState(() => checkOutLoading = true);

      final ApiService apiService = ApiService();
      final response = await apiService.getCustomerDetails(context, phoneNo);

      if (response.status ?? false) {
        await _handleExistingCustomer(response, apiService);
      } else {
        await _handleNewCustomer(phoneNo, apiService);
      }
    } catch (e) {
      print('Error in getCustomerApi: $e');
    } finally {
      setState(() => checkOutLoading = false);
    }
  }

  Future<void> _handleExistingCustomer(CustomerDetailResponse response, ApiService apiService) async {
    setState(() {
      addCustomerDetails = true;
      customerData = '${response.data?.firstName} | ${response.data?.email}';
    });

    eventBus.fire(ReloadEvent(true));
  }

  Future<void> _handleNewCustomer(String phoneNo, ApiService apiService) async {
    showCreateCustomerBottomSheet(
      context: context,
      phone: phoneNo,
      onSubmit: (name, phone, email) async {
        setState(() => checkOutLoading = true);

        final response = await apiService.createCustomerMetaData(context, name, phone, email!);

        if (response.status ?? false) {
          await _parseAndUpdateCustomerDetails(response);
        }

        setState(() => checkOutLoading = false);
      },
    );
  }

  Future<void> _parseAndUpdateCustomerDetails(CustomerMetaDataResponse response) async {
    try {
      final customerDetails = _parseCustomerDetails(response.metadata?.customerDetails);

      if (customerDetails != null) {
        setState(() {
          addCustomerDetails = true;
          customerData = '${customerDetails['first_name']} | ${customerDetails['email']}';
        });

        print('First Name: ${customerDetails['first_name']}');
        print('Email: ${customerDetails['email']}');
        eventBus.fire(ReloadEvent(true));
      } else {
        print('Customer details are empty or invalid');
      }
    } catch (e) {
      print('Error parsing customer details: $e');
    }
  }

  Map<String, dynamic>? _parseCustomerDetails(String? customerDetailsString) {
    if (customerDetailsString == null || customerDetailsString.isEmpty) {
      return null;
    }

    try {
      return json.decode(customerDetailsString) as Map<String, dynamic>;
    } catch (e) {
      print('JSON parsing error: $e');
      return null;
    }
  }

  void getShippingInfo() async {
    try {
      final ApiService apiService = ApiService();
      var response = await apiService.getShippingInfo(context);
      if (mounted) {
        setState(() {
          apiLoading = false;
          shippingResponse = response;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiLoading = false;
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
          onPaymentSelected: (PaymentProvider paymentProvider) {
            setState(() {
              addPaymentMethod = true;
              pp_id = paymentProvider.id;
              pp_title = paymentProvider.name;
            });
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
      PageRouteUtils.pushAndRemoveUntil(context,  OrderPlacedPage(orderId: '',));
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
      PageRouteUtils.pushAndRemoveUntil(context, OrderPlacedPage(orderId: response.order?.id??'',));
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
    }
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
}
