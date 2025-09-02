import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../model/view_cart_model.dart';
import '../utility/app_colors.dart';
import '../utility/app_strings.dart';
import '../utility/currency_util.dart';
import 'product_detail_page.dart';
import 'widgets/no_orders_widget.dart';

class MyFavoritesPage extends StatefulWidget {
  final bool? isFromBottomNav; // Optional Address parameter

  const MyFavoritesPage({super.key, this.isFromBottomNav});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  WishlistResponse? wishListResponse;
  bool apiLoading = true;
  Customer? customer;

  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Wait for the customer data to be fetched
    customer = await getCustomerResponse();

    if (customer != null) {
      getWishListApi(customer?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:CommonHeaderAppBar(
        title: AppStrings.my_favorites,
        leading: widget.isFromBottomNav ?? false ? false : true,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: apiLoading
          ?  Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : wishListResponse?.products?.isNotEmpty ?? false
          ? SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16, // Space between columns
                mainAxisSpacing: 16, // Space between rows
                scrollDirection: Axis.vertical,
                itemCount: wishListResponse?.products?.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final product = wishListResponse!.products?[index];
                  return GestureDetector(
                    onTap: () {},
                    child: ProductCard(
                        imageUrl:
                        product?.thumbnail ?? "",
                        title: product?.title ?? "",
                        price: CurrencyUtil.appendCurrency((product?.variants?.first.calculatedPrice?.calculatedAmount ?? 0).toString()),
                        onTapFavorite: () {
                          String currentCustomerId = customer?.id ?? "";
                          var currentWishlistEntry;

                          // Check if productWishlist is not null and is a list
                          if (product?.productWishlist is List) {
                            // Check if the list contains the current customer's wishlist entry
                            currentWishlistEntry = (product?.productWishlist as List).firstWhere(
                                  (item) => item['customer_id'] == currentCustomerId,
                              orElse: () => null, // Return null if no match is found
                            );
                          } else if (product?.productWishlist is Map) {
                            // Check if the productWishlist is a map and matches the current customer ID
                            currentWishlistEntry = (product?.productWishlist as Map)['customer_id'] == currentCustomerId
                                ? product?.productWishlist
                                : null;
                          }
                          if (currentWishlistEntry != null) {
                            // If the wishlist entry is found, delete it
                            print('Wishlist entry found: ${currentWishlistEntry['id']}');
                            deleteWishList(product?.id, currentWishlistEntry['id']);
                          } else {
                            print('No wishlist entry for this customer.');
                          }
                        },
                        isFavorite: true,
                        onTapCard: () {
                          PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: product?.id ?? "0"));
                        }),
                  );
                },
              ),
            ),
          ))
          : NoOrdersWidget(
        message: AppStrings.no_wishlist_yet,
        buttonText: AppStrings.explore_categories,
        iconPath: AppAssets.ic_cart_empty,
        showExplore: (widget.isFromBottomNav?? false),
        onButtonTap: () {
          eventBus.fire(TabSwitchEvent(1));
        },
      ),
    );
  }

  Future<void> getCustomerInfo() async {
    customer = await getCustomerResponse();
    if (customer != null) {
      setState(() {
        customer;
      });
    }
  }

  Future<Customer?> getCustomerResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('customer');
    if (userData != null) {
      return Customer.fromJson(userData);
    }
    return null;
  }

  void getWishListApi(String? customerID) async {
    try {
      final ApiService apiService = ApiService();
      var response = await apiService.getWishList(context, customerID);
      if (mounted) {
        setState(() {
          wishListResponse = response;
          apiLoading = false;
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

  void deleteWishList(String? productId, String? wishlistId) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.deleteFavourite(context, productId, wishlistId);
      if (mounted) {
        setState(() {
          apiLoading = false;
          getWishListApi(customer?.id);
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
}
