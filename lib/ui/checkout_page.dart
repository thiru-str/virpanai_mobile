import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/address_list_page.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/order_placed_page.dart';
import 'package:waioz/ui/widgets/cart_button.dart';
import 'package:waioz/ui/widgets/cart_calculation.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/check_out_item_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/payment_method_bottom_sheet.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/font_utils.dart';

import 'package:lottie/lottie.dart';

import '../api/api_service.dart';
import '../model/home_page_response.dart';
import '../utility/app_utils.dart';
import '../utility/currency_util.dart';
import '../utility/page_route_utils.dart';
import '../utility/shared_preferences_util.dart';
import 'package:waioz/model/check_out_shipping_address_model.dart' as CheckOut;

class CheckOutPage extends StatefulWidget {
  final CartResponse? cartResponse;

  const CheckOutPage({super.key, required this.cartResponse});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  CartResponse? cartResponse;
  bool apiLoading = true;
  bool addAddress = false;
  bool addPaymentMethod = false;
  Address? selectedAddress;
  String? pp_id;
  String? pp_title;
  bool placeOrderApiLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cartResponse = widget.cartResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeaderAppBar(
          title: 'Checkout',
          onBackTap: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        /*body: Center(child: NoOrdersWidget(message: 'Your Cart is Empty', buttonText: 'Explore Categories', iconPath: AppAssets.ic_cart_empty, onButtonTap: (){})),);*/
        body: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckoutItemCard(
                            title: 'Shipping Address',
                            subtitle: addAddress? selectedAddress!.address1!: 'Add Shipping Address',
                            onTap: () {
                              PageRouteUtils.pushWithSlide(context, AddressListPage(isFromCheckout: true,onSelectedAddress: (address){
                              setState(() {
                                addAddress = true;
                                selectedAddress = address;
                              });
                              },));
                            }),
                        CheckoutItemCard(
                            title: 'Payment Method',
                            subtitle: addPaymentMethod? pp_title!: 'Add Payment Method',
                            onTap: () async {
                              Global? global  = await getGlobal();
                              if (global != null) {
                                showPaymentMethodsBottomSheet(
                                    context, global.paymentProvider!);
                              }
                            })
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
                      keyText: 'Subtotal:',
                      valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.subtotal!.toStringAsFixed(2)),
                    ),
                    CartCalculation(
                      keyText: 'Tax:',
                      valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.taxTotal!.toStringAsFixed(2)),
                    ),
                    CartCalculation(
                      keyText: 'Total:',
                      valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.total!.toStringAsFixed(2)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: placeOrderApiLoading?  Center(child: Lottie.asset(AppAssets.place_order_lottie,fit: BoxFit.cover)): CartButton(
                amount: CurrencyUtil.appendCurrency(cartResponse!.cart!.total!.toStringAsFixed(2)),
                title: 'Place Order',
                onPressed: () {
                  if (!addAddress) {
                    AppUtils.showToast('Add Shipping Address');
                  } else if (!addPaymentMethod) {
                    AppUtils.showToast('Add Payment Method');
                  }
                  else{ // validations done proceed to place order
                    setState(() {
                      placeOrderApiLoading = true;
                    });
                    updateCart(selectedAddress!);
                  }
                }),
          ),
        ));
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

  void updateCart(Address address) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.updateAddress(context,convertToShippingAddress(address));
      placeOrder();
    } catch (e) {
      setState(() {
        placeOrderApiLoading = false;
      });
      print(e);
    }
  }

  void placeOrder() async {
    try {
      final ApiService apiService = ApiService();
      await apiService.placeOrder(context,pp_id!);
      setState(() {
        placeOrderApiLoading = false;
      });
      PageRouteUtils.pushAndRemoveUntil(context, const OrderPlacedPage());
    } catch (e) {
      setState(() {
        placeOrderApiLoading = false;
      });
      print(e);
    }
  }

  CheckOut.ShippingAddress convertToShippingAddress(Address address) {
    return CheckOut.ShippingAddress(
      // Map the fields from Address to ShippingAddress
      address1: address.address1 ?? '',
      address2: address.address2 ?? '',
      firstName: address.firstName ??'',
      lastName: address.lastName ?? '',
      phone: address.phone ?? '',
      company: address.company ?? '',
      postalCode: address.postalCode ?? '',
      countryCode: address.countryCode ?? '',
      province: address.province ?? '',
      city: address.city ?? '',
    );
  }
}
