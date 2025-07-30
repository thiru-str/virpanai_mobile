import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/events/event_utils.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/map_page.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/ui/widgets/common_header.dart';
import 'package:waioz/ui/widgets/home/Slider2.dart';
import 'package:waioz/ui/widgets/home/banner1.dart';
import 'package:waioz/ui/widgets/home/banner_2.dart';
import 'package:waioz/ui/widgets/home/grid_1.dart';
import 'package:waioz/ui/widgets/home/grid_2.dart';
import 'package:waioz/ui/widgets/home/slider_1.dart';
import 'package:waioz/ui/widgets/home/slider_3.dart';
import 'package:waioz/ui/widgets/search_address.dart';
import 'package:waioz/ui/widgets/home/item_1.dart';
import 'package:waioz/ui/widgets/home/item_2.dart';
import 'package:waioz/ui/widgets/home/item_3.dart';
import 'package:waioz/ui/widgets/home/item_4.dart';
import 'package:waioz/ui/widgets/home/item_5.dart';
import 'package:waioz/ui/widgets/home/item_6.dart';
import 'package:waioz/ui/widgets/home/item_7.dart';
import 'package:waioz/ui/widgets/home/item_8.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../api/api_service.dart';
import '../utility/app_utils.dart';
import 'widgets/common_header_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  HomePageResponse? homePageResponse;
  CartResponse? cartResponse;
  bool apiLoading = true;
  String headerTitle = "";
  String addressType = "";
  String appHeader = "header-1";

  int? cartItems;
  List<String>? cartItemImages;

  late StreamSubscription<ViewCartEvent> _eventSubscription;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializePages();
    listenToEvents();
  }

  void listenToEvents() {
    _eventSubscription = eventBus.on<ViewCartEvent>().listen((event) {
      if (mounted) {
        setState(() {
          cartItems = event.totalItems;
          cartItemImages = event.itemImages;
        });
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription.cancel(); // Cancel the subscription to prevent memory leaks
    super.dispose();
  }

  Future<void> initializePages() async {
    getHomePageApi();
    appHeader = (await SharedPreferencesUtil().getString('app_header'))!;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appHeader == "header-2" ? CommonHeaderAppBar(
          title: AppStrings.home,
          leading: false,
          onBackTap: () {
            Navigator.of(context).pop();
          },
        ) : null,
      backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Background layer for the sticky header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white, // Match your header background
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                ),
              ),

              Column(
                children: [
                  // Sticky CommonHeader
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CommonHeader(
                      headerType: appHeader,
                      title: headerTitle,
                      cartCount: cartItems ?? 0,
                      onCartClick: () {
                        PageRouteUtils.pushWithSlide(context, const CartPage());
                      },
                      onSearchClick: () {
                        PageRouteUtils.pushWithSlide(
                          context,
                          SearchAddressPage(
                            onTapAddress: (selectedAddress) {
                              setState(() {
                                headerTitle = selectedAddress.address1!;
                                addressType = selectedAddress.addressName!;
                              });
                            },
                          ),
                        );
                      },
                      addressType: addressType,
                    ),
                  ),

                  // Scrollable content area
                  Expanded(
                    child: apiLoading
                        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16), // Space below sticky header
                          ListView.separated(
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            scrollDirection: Axis.vertical,
                            itemCount: homePageResponse!.content!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final homePageContent = homePageResponse!.content![index];
                              return getLayoutWidget(homePageContent);
                            },
                          ),
                          const SizedBox(height: 80), // Space for bottom cart
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Floating cart button (unchanged from your original)
              if (cartItems != null && cartItems != 0)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        PageRouteUtils.pushWithSlide(context, const CartPage());
                      },
                      child: ViewCartWidget(
                        totalItems: cartItems!,
                        itemImages: cartItemImages!,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        )
    );
  }

  Widget getLayoutWidget(Content homePageContent) {
    AppLogger.print('items--->', homePageContent.layoutName??'');
    switch (homePageContent.layoutName) {
      case "item1":
        return Item1(content: homePageContent);
      case "item2":
        return Item2(content: homePageContent);
      case "item3":
        return Item3(content: homePageContent);
      case "item4":
        return Item4(content: homePageContent);
      case "item5":
        return Item5(content: homePageContent);
      case "item6":
        return Item6(content: homePageContent);
      case "item7":
        return Item7(content: homePageContent);
      case "item8":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Item8(content: homePageContent),
        );
      case "Slider2":
        return Slider2(content: homePageContent);
      case "Slider3":
        return Slider3(content: homePageContent);
      case "Grid1":
        return Grid1(content: homePageContent);
      case "Grid2":
        return Grid2(content: homePageContent);
      case "Banner2": // video
        return Banner2(content: homePageContent);
      case "Slider1":
        return Slider1(content: homePageContent);
      case "Banner1":
        return Banner1(content: homePageContent);
      default:
        return const SizedBox();
    }
  }

  void getHomePageApi() async {
    try {
      final ApiService apiService = ApiService();
      homePageResponse = await apiService.getHomePage(context);
      SharedPreferencesUtil().saveString('region_id', homePageResponse!.global!.regionId!);
      SharedPreferencesUtil().saveString('cart_id', homePageResponse!.global!.cartId!);
      SharedPreferencesUtil().saveString('currency_symbol', homePageResponse!.global!.currencySymbol!);
      SharedPreferencesUtil().saveMap('global', homePageResponse!.global!.toJson());
      setState(() {
        apiLoading = false;
        homePageResponse;
      });
      getCartApi();
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void getCartApi() async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      setState(() {
        cartItems = cartResponse!.cart!.items!.length;
        cartItemImages = cartResponse!.cart!.items!.map((item) => item.thumbnail!).toList();
      });
      if((cartResponse?.cart?.items?.length?? 0) > 0) {
        eventBus.fire(ViewCartEvent(cartItems!, cartItemImages!));
      }
    } catch (e) {
      print(e);
    }
  }


}
