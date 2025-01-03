import 'package:flutter/material.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/checkout_page.dart';
import 'package:waioz/ui/widgets/cart_calculation.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../api/api_service.dart';
import '../utility/currency_util.dart';

class CartPage extends StatefulWidget {
  final bool isFromBottomNav;

  const CartPage({super.key, this.isFromBottomNav = true});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  CartResponse? cartResponse;
  bool apiLoading = true;
  bool isAnimating = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCartApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFromBottomNav
          ? AppBar(
              backgroundColor: Colors.white,
              title: Text(
                'Cart',
                style: FontUtils.gabaritoStyle(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
              centerTitle: true,
            )
          : CommonHeaderAppBar(
              onBackTap: () {
                Navigator.of(context).pop();
              },
            ),
      backgroundColor: Colors.white,
      /*body: Center(child: NoOrdersWidget(message: 'Your Cart is Empty', buttonText: 'Explore Categories', iconPath: AppAssets.ic_cart_empty, onButtonTap: (){})),);*/
      body: apiLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : cartResponse!.cart!.items!.isNotEmpty
              ? Scaffold(
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
                                /*Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      'Remove All',
                                      style: FontUtils.circularStdStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),*/
                                const SizedBox(height: 10),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: cartResponse!.cart!.items!.length,
                                  itemBuilder: (context, index) {
                                    final cartItem =
                                        cartResponse!.cart!.items![index];
                                    return CartItemCard(
                                      imageUrl: cartItem.thumbnail!,
                                      productName: cartItem.productTitle!,
                                      size: cartItem.variantTitle!,
                                      color: 'color',
                                      // Replace with actual color
                                      price: CurrencyUtil.appendCurrency((cartItem.unitPrice! * cartItem.quantity!).toString()),
                                      quantity: cartItem.quantity!,
                                      isUpdating: cartItem.isUpdating!,
                                      onIncrease: () {
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
                                              removeCart(cartItem.id!);
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
                              keyText: 'Subtotal:',
                              valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.subtotal.toString()),
                            ),
                            CartCalculation(
                              keyText: 'Tax:',
                              valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.taxTotal.toString()),
                            ),
                            CartCalculation(
                              keyText: 'Total:',
                              valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.total.toString()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
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
                        PageRouteUtils.push(context, CheckOutPage(cartResponse: cartResponse,));
                      },
                      child: const Text(
                        'Checkout',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: NoOrdersWidget(
                      message: 'Your Cart is Empty',
                      buttonText: 'Explore Categories',
                      iconPath: AppAssets.ic_cart_empty,
                      onButtonTap: () {})),
    );
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

  void updateCart(int qty,String cartItemId,int index) async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.updateCart(context,qty,cartItemId);
      setState(() {
        cartResponse;
        setState(() {
          cartResponse!.cart!.items![index].isUpdating = false;
        });
      });
    } catch (e) {
      setState(() {

      });
      print(e);
    }
  }

  void removeCart(String cartItemId) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.removeCart(context,cartItemId);
      getCartApi();
    } catch (e) {
      setState(() {

      });
      print(e);
    }
  }



}
