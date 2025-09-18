import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/checkout_page.dart';
import 'package:waioz/ui/widgets/cart_calculation.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/delivery_address_widget.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/payment_method_bottom_sheet.dart';
import 'package:waioz/ui/widgets/payment_method_row.dart';
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

class _CartPageState extends State<CartPage>  with SingleTickerProviderStateMixin {
  CartResponse? cartResponse;
  bool apiLoading = true;
  bool cartLoading = false;
  bool addressLoading = false;
  bool isAnimating = false;

  late AnimationController _animationController;
  late Animation<Offset> _animation;

  Global? global;
  List<PaymentProvider> paymentProviders = [];
  String? pp_id;
  String? orderId;
  Razorpay razorpay = Razorpay();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initGlobal();
    getCartApi();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Define the animation's starting and ending positions
    _animation = Tween<Offset>(
      begin: const Offset(0, 1), // Start just below the screen
      end: Offset.zero, // End at its natural position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Delay animation start by 300ms
    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });


  }

  Future<void> initGlobal() async {
    var global = await getGlobal();

    if (global?.paymentProvider != null) {
      setState(() {
        paymentProviders = global!.paymentProvider!;
      });
    }
  }

  Future<Global?> getGlobal() async {
    dynamic global = await SharedPreferencesUtil().getMap('global');
    if (global != null) {
      return Global.fromJson(global);
    }
    return null;
  }

  String _getProviderName(String? providerId, List<PaymentProvider> providers) {
    if (providerId == null) return "Cash on Delivery";

    final match = providers.firstWhere(
          (p) => p.id == providerId,
      orElse: () => PaymentProvider(id: providerId, name: "Cash on Delivery"),
    );
    return match.name ?? "Cash on Delivery";
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeaderAppBar(
              title: AppStrings.cart,
              leading: widget.isFromBottomNav ? false : true,
              onBackTap: () {
                Navigator.pop(context,true);
              },
            ),
      /*body: Center(child: NoOrdersWidget(message: 'Your Cart is Empty', buttonText: 'Explore Categories', iconPath: AppAssets.ic_cart_empty, onButtonTap: (){})),);*/
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.linearGradient),
        child: apiLoading
            ?  Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        )
            : cartResponse!.cart!.items!.isNotEmpty
            ? Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Visibility(
                visible: cartResponse!.cart!.items!.isNotEmpty,
                child: DeliveryAddressWidget(
                  address: _buildShippingAddress(cartResponse),
                  label: null,
                  isLoading: addressLoading,
                  onAddAddress: () {
                    //Navigator.push(context, AddAddressPage.route());
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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cartResponse!.cart!.items!.length,
                          itemBuilder: (context, index) {
                            final cartItem =
                            cartResponse!.cart!.items![index];
                            return CartItemCard(
                              imageUrl: cartItem.thumbnail??'',
                              productName: cartItem.productTitle!,
                              size: cartItem.variantTitle! == "Default variant" ? "":cartItem.variantTitle!,
                              color: 'color',
                              // Replace with actual color
                              price: CurrencyUtil.appendCurrency((cartItem.unitPrice! * cartItem.quantity!).toStringAsFixed(2)),
                              quantity: cartItem.quantity!,
                              isUpdating: cartItem.isUpdating!,
                              onRemoveAll: () {
                                setState(() {
                                  cartResponse!.cart!.items![index].isUpdating = true;
                                });
                                //updateCart(0,cartItem.id!,index);
                                removeCart(cartItem.id!,index);
                              },onIncrease: () {
                              setState(() {
                                cartResponse!.cart!.items![index].isUpdating = true;
                              });
                              updateCart(cartItem.quantity!+1,cartItem.id!,index);
                            },
                              onDecrease:
                                  () {
                                setState(() {
                                  cartResponse!.cart!.items![index].isUpdating = true;
                                });
                                if (cartItem.quantity! - 1 <= 0) {
                                  removeCart(cartItem.id!,index);
                                } else {
                                  updateCart(cartItem.quantity! - 1,
                                      cartItem.id!,index);
                                }
                              }, // Handle quantity decrease
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaymentMethodRow(
                      selectedMethod: _getProviderName(pp_id, paymentProviders),
                      onTap: () {
                        // open bottom sheet / payment method selector
                        showPaymentMethodsBottomSheet(
                            context, paymentProviders);
                      },
                    ),
                    CartCalculation(
                      keyText: '${AppStrings.subTotal}:',
                      valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.itemSubtotal!.toStringAsFixed(2)),
                    ),
                    Visibility(
                        visible: cartResponse!.cart!.discountSubtotal!>0,
                        child: CartCalculation(
                          keyText: '${AppStrings.discount}:',
                          valueText: '- ${CurrencyUtil.appendCurrency(cartResponse!.cart!.discountSubtotal!.toStringAsFixed(2))}',
                        )),
                    Visibility(
                        visible: cartResponse!.cart!.shippingSubtotal!>0,
                        child: CartCalculation(
                          keyText: '${AppStrings.shipping}:',
                          valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.shippingSubtotal!.toStringAsFixed(2)),
                        )),
                    CartCalculation(
                      keyText: '${AppStrings.tax}:',
                      valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.taxTotal!.toStringAsFixed(2)),
                    ),
                    CartCalculation(
                      keyText: '${AppStrings.total}:',
                      keyStyle: FontUtils.primaryFontStyle(fontSize: 14,color: AppColors.primary,fontWeight: FontWeight.bold),
                      valueStyle: FontUtils.primaryFontStyle(fontSize: 14,color: AppColors.primary,fontWeight: FontWeight.bold),
                      valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.total!.toStringAsFixed(2)),
                    ),
                    const SizedBox(height: 10,),
                    GestureDetector(
                      onTap: () {
                        if((cartResponse?.cart?.promotions??[]).isEmpty) {
                          showPromoCodeBottomSheet(context);
                        }
                        else{
                          List<String> promotionCodes = cartResponse?.cart?.promotions
                              ?.map((promotion) => promotion.code)
                              .where((code) => code != null)
                              .cast<String>()
                              .toList() ?? [];
                          removePromoCode(promotionCodes);
                        }
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withAlpha(20), width: 1),
                        ),
                        child:  Row(
                          children: [
                            const ImageIcon(AssetImage(AppAssets.ic_discount),color: Colors.green,),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (cartResponse?.cart?.promotions??[]).isEmpty? AppStrings.enter_promo_code:cartResponse?.cart?.promotions?.firstOrNull?.code??'',
                                style: FontUtils.primaryFontStyle(color: AppColors.textColor),
                              ),
                            ),
                            Text(
                              (cartResponse?.cart?.promotions??[]).isEmpty? AppStrings.apply: 'Remove',
                              style: FontUtils.secondaryFontStyle(color: AppColors.primary,fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SlideTransition(
            position: _animation,
            child: Padding(
              padding: const EdgeInsets.only(left:16.0,right:16.0,bottom: 16.0),
              child: cartLoading? SizedBox(height:100,child: Center(child: CircularProgressIndicator(color: AppColors.primary,),)):ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(
                      double.infinity, 56), // Full width button
                ),
                onPressed: () {
                  // Add checkout logic here
                  if ((cartResponse?.cart?.shippingAddress?.address1 ?? '').isEmpty) {
                    AppUtils.showToast(
                        'Please add address to proceed');
                    return;
                  }
                  if(!addressLoading) {
                    placeOrder(pp_id!);
                    //PageRouteUtils.push(context, CheckOutPage(cartResponse: cartResponse));
                  }
                },
                child:  Text(
                  'Place Order',
                  style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight:FontWeight.bold,color: Colors.white),
                ),
              ),
            ),
          ),
        )
            : Center(
            child: NoOrdersWidget(
                message: AppStrings.cart_empty,
                buttonText: AppStrings.explore_categories,
                iconPath: AppAssets.ic_cart_empty,
                showExplore: (widget.isFromBottomNav),
                onButtonTap: () {
                  eventBus.fire(TabSwitchEvent(1));
                })),
      ),
    );
  }

  void getCartApi() async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      emitEvent(cartResponse!);
      setState(() {
        pp_id = cartResponse?.cart?.paymentCollection?.paymentSessions?.firstOrNull?.providerId??'';
        orderId = cartResponse?.cart?.paymentCollection?.paymentSessions?.firstOrNull?.data?.id??'';
        apiLoading = false;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void emitEvent(CartResponse cartResponse) {
    final totalQty = cartResponse.cart!.items!
        .map((item) => item.quantity ?? 0) // pick quantity, default to 0
        .fold<int>(0, (sum, qty) => sum + qty);
    print('total qty ${totalQty}');
    eventBus.fire(ViewCartModel(totalQty,cartResponse.cart!.items!.map((item) => item.thumbnail!).toList()));
  }

  void addPromoCode(String promoCode) async {
    try {
      setState(() {
        cartLoading = true;
      });
      final ApiService apiService = ApiService();
      final response = await apiService.addPromoCode(context,promoCode);
      if ((response.cart?.promotions?.firstOrNull?.code ?? '')
          .isNotEmpty) {
        AppUtils.showToast(
            '${response.cart?.promotions?.firstOrNull?.code ?? ''} Promo code applied successfully');
      }
      else{
        AppUtils.showToast(
            'Promo code not applied.Please double check your cart items');
      }
      setState(() {
        cartResponse =  response;
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
      final response = await apiService.removePromoCode(context,promoCodes);
      if ((response.cart?.promotions?.firstOrNull?.code ?? '')
          .isEmpty) {
        AppUtils.showToast(
            'Promo code removed successfully');
      }
      setState(() {
        cartResponse =  response;
        cartLoading = false;
      });
    } catch (e) {
      setState(() {
        cartLoading = false;
      });
      print(e);
    }
  }


  void updateCart(int qty,String cartItemId,int index) async {
    try {
      debugPrint('calling update');
      final ApiService apiService = ApiService();
      cartResponse = await apiService.updateCart(context,qty,cartItemId);
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

  void removeCart(String cartItemId,int index) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.removeCart(context,cartItemId);
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
                style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: promoCodeController,
                decoration: InputDecoration(
                  hintText:AppStrings.promo_code,
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
                  (cartResponse?.cart?.promotions??[]).isEmpty? AppStrings.apply: 'Remove',
                  style: FontUtils.primaryFontStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Colors.white),
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

  void updatePaymentMethod(String paymentProviderId) async {
    try {
      setState(() {
        cartLoading =true;
      });
      final ApiService apiService = ApiService();
      final response = await apiService.updatePaymentMethod(
              context, paymentProviderId, cartResponse!);
      setState(() {
        pp_id = response.paymentCollection?.paymentSessions?.firstOrNull?.providerId??'';
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        cartLoading =false;
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



  void placeOrder(String paymentProviderId) async {
    switch (paymentProviderId) {
      case 'pp_razorpay_razorpay':
        makeRazorPayCall(orderId!);
        break;
      case 'pp_system_default':
        completeCart();
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
      PageRouteUtils.pushAndRemoveUntil(context, OrderPlacedPage(orderId: response.order?.id??'',));
    } catch (e) {
      setState(() {
        cartLoading = true;
      });
      print(e);
    }
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
    completeCart();
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {}


}

