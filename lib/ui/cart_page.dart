import 'package:flutter/material.dart';
import 'package:waioz/model/up_sell_products_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/checkout_page.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/cart_calculation.dart';
import 'package:waioz/ui/widgets/cart_item_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../utility/app_utils.dart';
import '../utility/currency_util.dart';

class CartPage extends StatefulWidget {
  final bool isFromBottomNav;

  const CartPage({super.key, this.isFromBottomNav = false});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  CartResponse? cartResponse;
  UpSellProductsResponse? upSellProductsResponse;
  bool apiLoading = true;
  bool isAnimating = false;

  late AnimationController _animationController;
  late Animation<Offset> _animation;
  bool isLoggedIn = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AppUtils.isLoggedIn().then((value) {
      setState(() {
        isLoggedIn = value;
      });
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
    });
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
          Navigator.pop(context, true);
        },
      ),
      backgroundColor: Colors.white,
      /*body: Center(child: NoOrdersWidget(message: 'Your Cart is Empty', buttonText: 'Explore Categories', iconPath: AppAssets.ic_cart_empty, onButtonTap: (){})),);*/
      body: apiLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : cartResponse?.cart?.items?.isNotEmpty ?? false
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
                                const SizedBox(height: 10),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:
                                      cartResponse?.cart?.items?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final cartItem =
                                        cartResponse?.cart?.items?[index];
                                    return CartItemCard(
                                      imageUrl: cartItem?.thumbnail ?? "",
                                      productName: cartItem?.productTitle ?? "",
                                      size: cartItem?.variantTitle ==
                                              "Default variant"
                                          ? ""
                                          : cartItem?.variantTitle ?? "",
                                      color: 'color',
                                      // Replace with actual color
                                      price: CurrencyUtil.appendCurrency(
                                          ((cartItem?.unitPrice ?? 0) *
                                                  (cartItem?.quantity ?? 0))
                                              .toStringAsFixed(2)),
                                      quantity: cartItem?.quantity ?? 0,
                                      isUpdating: cartItem?.isUpdating ?? false,
                                      onRemoveAll: () {
                                        setState(() {
                                          cartResponse!.cart!.items![index].isUpdating = true;
                                        });
                                        //updateCart(0,cartItem.id!,index);
                                        removeCart(cartItem?.id??'',index);
                                      },
                                      onIncrease: () {
                                        setState(() {
                                          cartResponse!.cart!.items![index]
                                              .isUpdating = true;
                                        });
                                        updateCart(
                                            (cartItem?.quantity ?? 0) + 1,
                                            cartItem?.id ?? '',
                                            index);
                                      },
                                      // onDecrease: () {
                                      // setState(() {
                                      //   cartResponse!.cart!.items![index]
                                      //       .isUpdating = true;
                                      // });
                                      // if (cartItem?.quantity - 1 <= 0) {
                                      //   removeCart(cartItem!.id!);
                                      // } else {
                                      //   updateCart(cartItem?.quantity - 1,
                                      //       cartItem!.id!, index);
                                      // }

                                      // },
                                      //// Handle quantity decrease
                                      onDecrease: () {
                                        setState(() {
                                          cartResponse?.cart?.items?[index]
                                              .isUpdating = true;
                                        });

                                        final quantity =
                                            cartItem?.quantity ?? 0;
                                        final id = cartItem?.id;

                                        if (id == null) {
                                          // Optionally log error instead of crashing
                                          debugPrint(
                                              "Cart item id is null, cannot update/remove.");
                                          return;
                                        }

                                        if (quantity - 1 <= 0) {
                                          removeCart(id,index);
                                        } else {
                                          updateCart(quantity - 1, id, index);
                                        }
                                      },
                                    );
                                  },
                                ),
                                buildUpSellProducts(),
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CartCalculation(
                                        keyText: '${AppStrings.subTotal}:',
                                        valueText: CurrencyUtil.appendCurrency(
                                            cartResponse!.cart!.itemSubtotal!
                                                .toStringAsFixed(2)),
                                      ),
                                      Visibility(
                                          visible: cartResponse!
                                                  .cart!.discountSubtotal! >
                                              0,
                                          child: CartCalculation(
                                            keyText: '${AppStrings.discount}:',
                                            valueText:
                                                '- ${CurrencyUtil.appendCurrency(cartResponse!.cart!.discountSubtotal!.toStringAsFixed(2))}',
                                          )),
                                      Visibility(
                                          visible: cartResponse!
                                                  .cart!.shippingSubtotal! >
                                              0,
                                          child: CartCalculation(
                                            keyText: '${AppStrings.shipping}:',
                                            valueText:
                                                CurrencyUtil.appendCurrency(
                                                    cartResponse!
                                                        .cart!.shippingSubtotal!
                                                        .toStringAsFixed(2)),
                                          )),
                                      CartCalculation(
                                        keyText: '${AppStrings.tax}:',
                                        valueText: CurrencyUtil.appendCurrency(
                                            cartResponse!.cart!.taxTotal!
                                                .toStringAsFixed(2)),
                                      ),
                                      CartCalculation(
                                        keyText: '${AppStrings.total}:',
                                        valueText: CurrencyUtil.appendCurrency(
                                            cartResponse!.cart!.total!
                                                .toStringAsFixed(2)),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showPromoCodeBottomSheet(context);
                                        },
                                        child: Container(
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const ImageIcon(
                                                AssetImage(
                                                    AppAssets.ic_discount),
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  AppStrings.enter_promo_code,
                                                  style: FontUtils
                                                      .primaryFontStyle(
                                                          color: AppColors
                                                              .textColor),
                                                ),
                                              ),
                                              Text(
                                                AppStrings.apply,
                                                style: FontUtils
                                                    .secondaryFontStyle(
                                                        color:
                                                            AppColors.primary),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: SlideTransition(
                    position: _animation,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
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
                          PageRouteUtils.pushWithSlide(
                              context,
                              CheckOutPage(
                                cartResponse: cartResponse,
                              ));
                        },
                        child: Text(
                          AppStrings.check_out,
                          style: FontUtils.primaryFontStyle(
                              fontSize: 18, color: Colors.white),
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

  Widget buildUpSellProducts() {
    if ((upSellProductsResponse?.products?.length ?? 0) == 0) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Suggested for You',
          style: FontUtils.secondaryFontStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 310,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: upSellProductsResponse?.products?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = upSellProductsResponse?.products![index];
              return ProductCard(
                imageUrl: product?.thumbnail ?? '',
                title: product?.title ?? '',
                price: CurrencyUtil.appendCurrency(product
                        ?.variants
                        ?.firstOrNull
                        ?.calculatedPrice
                        ?.rawCalculatedAmount
                        ?.value ??
                    ''),
                onTapCard: () {
                  PageRouteUtils.pushWithSlide(
                    context,
                    ProductDetailPage(productId: product?.id ?? ''),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void getCartApi() async {
    try {
      if (!isLoggedIn) {
        setState(() {
          apiLoading = false;
        });
        return;
      }
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      emitEvent(cartResponse!);
      upSellProductsResponse = await apiService.upSellingProducts(context);
      setState(() {
        upSellProductsResponse;
        apiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void emitEvent(CartResponse cartResponse) {
    eventBus.fire(ViewCartModel(cartResponse.cart!.items!.length,
        cartResponse.cart!.items!.map((item) => item.thumbnail!).toList()));
  }

  void addPromoCode(String promoCode) async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.addPromoCode(context, promoCode);
      setState(() {
        cartResponse;
      });
    } catch (e) {
      print(e);
    }
  }

  void updateCart(int qty, String cartItemId, int index) async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.updateCart(context, qty, cartItemId);
      setState(() {
        cartResponse;
        setState(() {
          cartResponse!.cart!.items![index].isUpdating = false;
        });
      });
    } catch (e) {
      setState(() {});
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
          cartResponse?.cart?.items?[index].isUpdating = false;
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
                  AppStrings.apply,
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
}
