import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/checkout_page.dart';
import 'package:waioz/ui/widgets/cart_calculation.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/delivery_address_widget.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../model/register_response.dart' as RegisterResponse;
import 'package:waioz/model/check_out_shipping_address_model.dart' as CheckOut;
import '../utility/currency_util.dart';
import 'address_list_page.dart';

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
  late StreamSubscription<ReloadEvent> _streamSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCartApi();
    listenToEvents();

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

  void listenToEvents() {
    _streamSubscription = eventBus.on<ReloadEvent>().listen((event) {
      if (mounted) {
        if(event.reload) {
          getCartApi();
        }
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
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
      backgroundColor: Colors.white,
      /*body: Center(child: NoOrdersWidget(message: 'Your Cart is Empty', buttonText: 'Explore Categories', iconPath: AppAssets.ic_cart_empty, onButtonTap: (){})),);*/
      body: apiLoading
          ?  Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : cartResponse?.cart?.items?.isNotEmpty?? false
          ? Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Visibility(
              visible: false,
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
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
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
                            style: FontUtils.secondaryFontStyle(color: AppColors.primary),
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
                  PageRouteUtils.pushWithSlide(context,
                      CheckOutPage(cartResponse: cartResponse,));
                }
              },
              child:  Text(
                AppStrings.check_out,
                style: FontUtils.primaryFontStyle(fontSize: 18, color: Colors.white),
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
    );
  }

  void getCartApi() async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      emitEvent(cartResponse!);
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
                style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  style: FontUtils.primaryFontStyle(fontSize: 16, color: Colors.white),
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


}

