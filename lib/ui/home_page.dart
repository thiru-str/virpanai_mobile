import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/widgets/combined_header_app_bar.dart';
import 'package:waioz/ui/widgets/home/Slider2.dart';
import 'package:waioz/ui/widgets/home/banner1.dart';
import 'package:waioz/ui/widgets/home/banner_2.dart';
import 'package:waioz/ui/widgets/home/grid_2.dart';
import 'package:waioz/ui/widgets/home/item_9.dart';
import 'package:waioz/ui/widgets/home/slider_1.dart';
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
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../api/api_service.dart';
import '../utility/app_assets.dart';
import '../utility/app_utils.dart';

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
      initializePages();
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

  Future<void> initializePages() async {
    getHomePageApi();
    appHeader = (await SharedPreferencesUtil().getString('app_header') ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CombinedHeaderAppBar(
          headerType: appHeader,
          title: headerTitle,
          cartCount: cartItems ?? 0,
          onCartClick: () => eventBus.fire(TabSwitchEvent(2)),
          onSearchClick: () => PageRouteUtils.pushWithFade(
            context,
            const ProductPage(),
          ),
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
                        await getHomePageApi();
                      },
                      child: homePageResponse?.content?.isEmpty == true?Center(child: NoOrdersWidget(message: 'Your Components is Empty', buttonText: 'Explore Categories', iconPath: AppAssets.ic_cart_empty, onButtonTap: (){
                        eventBus.fire(TabSwitchEvent(1));
                      })):SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 16.0),
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount:
                                    homePageResponse?.content?.length ?? 0,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final homePageContent =
                                      homePageResponse?.content?[index];
                                  return getLayoutWidget(homePageContent);
                                },
                              ),
                            ),
                            Visibility(
                                visible: cartItems != null && cartItems != 0,
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
        ));
  }

  Widget getLayoutWidget(Content? homePageContent) {
    print('item ${homePageContent?.layoutName}');
    switch (homePageContent?.layoutName) {
      case "item1":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Item1(content: homePageContent),
        );
      case "Slider2":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Slider2(content: homePageContent!);
      case "item2":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Item2(content: homePageContent),
        );
      case "item3":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Item3(content: homePageContent!),
        );
      case "item4":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Item4(content: homePageContent!),
        );
      case "item5":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Item5(content: homePageContent!),
        );
      case "item6":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Item6(content: homePageContent!),
        );
      case "item7":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Item7(content: homePageContent!),
        );
      case "item8":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Item8(content: homePageContent),
        );
      case "Slider3":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Slider3(content: homePageContent),
        );
      case "Grid1":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Grid1(content: homePageContent!),
        );
      case "Grid2":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Grid2(content: homePageContent!),
        );
      case "Banner2": // video
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Banner2(content: homePageContent!),
        );
      case "Slider1":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Slider1(content: homePageContent!),
        );
      case "Banner1":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Banner1(content: homePageContent!),
        );
      case "item9":
        return homePageContent?.layoutData?.isEmpty == true?const SizedBox():Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Item9(
            content: homePageContent!,
            onCartQtyChanged: (deltaQty, variantId) async {
              await addCart(deltaQty, variantId);
            },
          ),
        );

      default:
        return const SizedBox();
    }
  }

  Future<void> getHomePageApi() async {
    try {
      final ApiService apiService = ApiService();
      homePageResponse = await apiService.getHomePage(context);
      SharedPreferencesUtil()
          .saveString('region_id', homePageResponse?.global?.regionId ?? "");
      SharedPreferencesUtil()
          .saveString('cart_id', homePageResponse?.global?.cartId ?? "");
      SharedPreferencesUtil().saveString(
          'currency_symbol', homePageResponse?.global?.currencySymbol ?? "");
      SharedPreferencesUtil()
          .saveMap('global', homePageResponse?.global?.toJson() ?? {});
      setState(() {
        apiLoading = false;
        homePageResponse;
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
