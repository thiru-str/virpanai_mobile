import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/home/Slider2.dart';
import 'package:waioz/ui/widgets/home/banner1.dart';
import 'package:waioz/ui/widgets/home/banner_2.dart';
import 'package:waioz/ui/widgets/home/banner_3_4.dart';
import 'package:waioz/ui/widgets/home/grid_2.dart';
import 'package:waioz/ui/widgets/home/grid_3.dart';
import 'package:waioz/ui/widgets/home/grid_5.dart';
import 'package:waioz/ui/widgets/home/grid_6.dart';
import 'package:waioz/ui/widgets/home/grid_7.dart';
import 'package:waioz/ui/widgets/home/grid_8.dart';
import 'package:waioz/ui/widgets/home/grid_10.dart';
import 'package:waioz/ui/widgets/home/grid_11.dart';
import 'package:waioz/ui/widgets/home/item_11.dart';
import 'package:waioz/ui/widgets/home/item_12.dart';
import 'package:waioz/ui/widgets/home/item_13.dart';
import 'package:waioz/ui/widgets/home/item_14.dart';
import 'package:waioz/ui/widgets/home/item_9.dart';
import 'package:waioz/ui/widgets/home/slider_1.dart';
import 'package:waioz/ui/widgets/home/slider_6.dart';
import 'package:waioz/ui/widgets/home/slider_7.dart';
import 'package:waioz/ui/widgets/home/slider_9.dart';
import 'package:waioz/ui/widgets/home/grid_1.dart';
import 'package:waioz/ui/widgets/home/item_8.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/home/item_1.dart';
import 'package:waioz/ui/widgets/home/item_2.dart';
import 'package:waioz/ui/widgets/home/item_3.dart';
import 'package:waioz/ui/widgets/home/item_4.dart';
import 'package:waioz/ui/widgets/home/item_5.dart';
import 'package:waioz/ui/widgets/home/item_6.dart';
import 'package:waioz/ui/widgets/home/item_7.dart';
import 'package:waioz/ui/widgets/home/slider_3.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../api/api_service.dart';
import '../model/custom_page_response.dart';
import '../utility/app_assets.dart';
import '../utility/app_strings.dart';
import '../utility/app_utils.dart';
import '../utility/page_route_utils.dart';
import 'bottom_nav_page.dart';

class CustomPage extends StatefulWidget {
  final slug;
  const CustomPage({super.key, required this.slug});

  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  CustomPageResponse? customPageResponse;
  CartResponse? cartResponse;
  bool apiLoading = true;

  int? cartItems;
  List<String>? cartItemImages;

  late StreamSubscription<ViewCartModel> _eventSubscription;

  bool isLoggedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppUtils.isLoggedIn().then((value) {
      setState(() {
        isLoggedIn = value;
      });
      initialize();
      listenToEvents();
    });
  }

  void listenToEvents() {
    _eventSubscription = eventBus.on<ViewCartModel>().listen((event) {
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
    _eventSubscription
        .cancel(); // Cancel the subscription to prevent memory leaks
    super.dispose();
  }

  Future<void> initialize() async {
    getCustomPageApi();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Disable default back button
        onPopInvoked: (didPop) async {
          if (didPop) return;
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context); // Normal back navigation
          } else {
            // Redirect to home when no backstack exists
            PageRouteUtils.pushAndRemoveUntil(context, BottomNavPage());
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
              appBar: CommonHeaderAppBar(
                title: '', // Pass the updated favorite status here
                onBackTap: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Stack(
                  children: [
                    apiLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              // Call your refresh function here
                              setState(() => apiLoading = true);
                              await getCustomPageApi();
                            },
                            child: customPageResponse?.content?.isEmpty == true
                                ? Center(
                                    child: NoOrdersWidget(
                                        message: AppStrings.components_empty,
                                        buttonText:
                                            AppStrings.explore_categories,
                                        iconPath: AppAssets.ic_cart_empty,
                                        onButtonTap: () {
                                          eventBus.fire(TabSwitchEvent(1));
                                        }))
                                : SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0, vertical: 16.0),
                                          child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: customPageResponse
                                                    ?.content?.length ??
                                                0,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              final homePageContent =
                                                  customPageResponse
                                                      ?.content?[index];
                                              return getLayoutWidget(
                                                  homePageContent);
                                            },
                                          ),
                                        ),
                                        Visibility(
                                            visible: cartItems != null &&
                                                cartItems != 0,
                                            child: const SizedBox(
                                              height: 80,
                                            ))
                                      ],
                                    ),
                                  ),
                          ),
                    Visibility(
                      visible: cartItems != null && cartItems != 0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: cartItems != null
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: GestureDetector(
                                  onTap: () {
                                    eventBus.fire(TabSwitchEvent(2));
                                  },
                                  child: ViewCartWidget(
                                      totalItems: cartItems!,
                                      itemImages: cartItemImages!),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }

  Widget getLayoutWidget(Content? homePageContent) {
    print('item ${homePageContent?.layoutName}');
    switch (homePageContent?.layoutName) {
      case "item1":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item1(content: homePageContent),
              );
      case "Slider2":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider2(content: homePageContent!);
      case "item2":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item2(content: homePageContent),
              );
      case "item3":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item3(content: homePageContent!),
              );
      case "item4":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item4(content: homePageContent!),
              );
      case "item5":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item5(content: homePageContent!),
              );
      case "item6":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item6(content: homePageContent!),
              );
      case "item7":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item7(content: homePageContent!),
              );
      case "item8":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item8(content: homePageContent),
              );
      case "Slider3":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Slider3(content: homePageContent),
              );
      case "Grid1":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Grid1(content: homePageContent!),
              );
      case "Grid2":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Grid2(content: homePageContent!),
              );
      case "Grid3":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Grid3(content: homePageContent!),
              );
      case "Grid5":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Grid5(content: homePageContent!),
              );
      case "Grid6":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Grid6(content: homePageContent!),
              );
      case "Grid7":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Grid7(content: homePageContent!),
              );
      case "Grid8":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Grid8(content: homePageContent!),
              );
      case "Grid10":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Grid10(content: homePageContent!),
              );
      case "Grid11":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Grid11(content: homePageContent!),
              );
      case "Banner2": // video
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Banner2(content: homePageContent!),
              );
      case "Slider1":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Slider1(content: homePageContent!),
              );
      case "Slider6":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Slider6(content: homePageContent!),
              );
      case "Slider7":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Slider7(content: homePageContent!),
              );
      case "Slider9":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Slider9(
                  content: homePageContent!,
                  onCartQtyChanged: (deltaQty, variantId) async {
                    await addCart(deltaQty, variantId);
                  },
                ),
              );
      case "Banner1":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Banner1(content: homePageContent!),
              );
      case "Banner3":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Banner3(content: homePageContent!),
              );
      case "Banner4":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Banner4(content: homePageContent!),
              );
      case "item9":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item9(
                  content: homePageContent!,
                  onCartQtyChanged: (deltaQty, variantId) async {
                    await addCart(deltaQty, variantId);
                  },
                ),
              );
      case "item11":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item11(content: homePageContent!),
              );
      case "item12":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item12(content: homePageContent!),
              );
      case "item13":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item13(content: homePageContent!),
              );
      case "item14":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item14(content: homePageContent!),
              );

      default:
        return const SizedBox();
    }
  }

  Future<void> getCustomPageApi() async {
    try {
      final ApiService apiService = ApiService();
      customPageResponse = await apiService.getCustomPage(context, widget.slug);
      setState(() {
        apiLoading = false;
        customPageResponse;
      });
      getCartApi();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void getCartApi() async {
    try {
      if (!isLoggedIn) {
        return;
      }
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      setState(() {
        cartItems = cartResponse?.cart?.items?.length;
        cartItemImages = cartResponse?.cart?.items
            ?.map((item) => item.thumbnail ?? "")
            .toList();
      });
      if ((cartResponse?.cart?.items?.length ?? 0) > 0) {
        final qtyMap = <String, int>{};
        for (var item in cartResponse?.cart?.items ?? []) {
          qtyMap[item.variantId] = item.quantity;
        }

        eventBus.fire(ViewCartModel(cartItems, cartItemImages, qtyMap));
        //eventBus.fire(ViewCartModel(cartItems!, cartItemImages!));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addCart(int qty, String variantId) async {
    try {
      final apiService = ApiService();
      await apiService.addCart(context, qty, variantId);
      getCartApi();
    } catch (e) {
      print(e);
    }
  }
}
