import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/product_wishlist_response.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../utility/app_colors.dart';
import '../utility/app_strings.dart';
import 'widgets/no_orders_widget.dart';

class MyFavoritesPage extends StatefulWidget {
  final bool? isFromBottomNav; // Optional Address parameter

  const MyFavoritesPage({super.key, this.isFromBottomNav});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  GetWishlistResponse? wishListResponse;
  bool apiLoading = true;
  Customer? customer;

  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Wait for the customer data to be fetched
    Customer? customer = await getCustomerResponse();

    // If customer is available, call getWishListApi() with the customer ID
    if (customer != null) {
      getWishListApi(customer.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isFromBottomNav ?? false
          ? null
          : CommonHeaderAppBar(
              title: AppStrings.my_favorites,
              onBackTap: () {
                Navigator.of(context).pop();
              },
            ),
      body: apiLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : wishListResponse?.productWishlist?.isNotEmpty ?? false
              ? SafeArea(
                  child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: wishListResponse?.productWishlist?.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        crossAxisSpacing: 16, // Space between columns
                        mainAxisSpacing: 16, // Space between rows
                        childAspectRatio:
                            0.6, // Adjust this for proper card proportions
                      ),
                      itemBuilder: (context, index) {
                        final product = wishListResponse!.productWishlist![index].products?.first;
                        return GestureDetector(
                          onTap: () {},
                          child: ProductCard(
                              imageUrl:
                              product?.thumbnail ?? "",
                              title: product?.title ?? "",
                              price: "32.0",
                              onTapFavorite: () {
                                addWishListAPI(product?.id);
                              },
                              isFavorite: true,
                              onTapCard: () {}),
                        );
                      },
                    ),
                  ),
                ))
              : NoOrdersWidget(
                  message: AppStrings.no_wishlist_yet,
                  buttonText: AppStrings.explore_categories,
                  iconPath: AppAssets.ic_cart_empty,
                  onButtonTap: () {
                    // PageRouteUtils.push(context, AddAddressPage());
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

  void addWishListAPI(String? productID) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.addWishList(context, productID);
      setState(() {
        apiLoading = false;
      });
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
