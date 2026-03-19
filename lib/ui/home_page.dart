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
import 'package:waioz/ui/widgets/home/item_1.dart';
import 'package:waioz/ui/widgets/home/item_2.dart';
import 'package:waioz/ui/widgets/home/item_3.dart';
import 'package:waioz/ui/widgets/home/item_4.dart';
import 'package:waioz/ui/widgets/home/item_5.dart';
import 'package:waioz/ui/widgets/home/item_6.dart';
import 'package:waioz/ui/widgets/home/item_7.dart';
import 'package:waioz/ui/widgets/home/slider_3.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../api/api_service.dart';
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
  String appHeader = "";

  int? cartItems;
  List<String>? cartItemImages;

  late StreamSubscription<ViewCartModel> _eventSubscription;

  bool isLoggedIn = false;

  final int _limit = 10;
  int _offset = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

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

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMoreApi();
      }
    });
  }

  Future<void> _loadMoreApi() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    _offset += _limit;

    await getHomePageApi(
      offset: _offset,
      limit: _limit,
      isLoadMore: true,
    );
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
    _scrollController.dispose();
    _eventSubscription
        .cancel(); // Cancel the subscription to prevent memory leaks
    super.dispose();
  }

  Future<void> initializePages() async {
    final savedHeader =
        await SharedPreferencesUtil().getString('app_header') ?? "";
    if (mounted && savedHeader.isNotEmpty) {
      setState(() {
        appHeader = savedHeader;
      });
    }
    getHomePageApi(limit: _limit, offset: _offset);
  }

  @override
  Widget build(BuildContext context) {
    late final PreferredSizeWidget homeAppBar;
    if (apiLoading) {
      homeAppBar = HomeHeaderSkeleton(
        headerType: appHeader.isEmpty ? 'header-4' : appHeader,
      );
    } else {
      homeAppBar = CombinedHeaderAppBar(
        headerType: appHeader.isEmpty ? 'header-4' : appHeader,
        title: headerTitle,
        cartCount: cartItems ?? 0,
        onCartClick: () => eventBus.fire(TabSwitchEvent(2)),
        onSearchClick: () => PageRouteUtils.pushWithFade(
          context,
          const ProductPage(),
        ),
      );
    }

    return Scaffold(
        appBar: homeAppBar,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: apiLoading
              ? const HomePageSkeleton()
              : RefreshIndicator(
                  onRefresh: () async {
                    _offset = 0;
                    _hasMore = true;
                    setState(() => apiLoading = true);
                    await getHomePageApi(offset: 0, limit: _limit);
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (!_isLoadingMore &&
                          _hasMore &&
                          scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200) {
                        _loadMoreApi();
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Main UI Components
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 16.0),
                            child: buildComponentList(),
                          ),

                          // Load More Indicator
                          if (_isLoadingMore)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),

                          if (!_hasMore)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                AppStrings.end_of_page,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),

                          SizedBox(
                            height:
                                cartItems != null && cartItems != 0 ? 100 : 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
        ));
  }

  ListView buildComponentList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: homePageResponse?.content?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final content = homePageResponse?.content ?? [];
        if (index < content.length) {
          final homePageContent = content[index];
          return AppReveal(
            index: index,
            child: getLayoutWidget(homePageContent),
          );
        }

        return _isLoadingMore
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                    child: CircularProgressIndicator(
                  color: AppColors.primary,
                )),
              )
            : const SizedBox.shrink();
      },
    );
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
            : Item3(content: homePageContent!);
      case "item4":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Item4(content: homePageContent!);
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
            : Item7(content: homePageContent!);
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
            : Grid2(content: homePageContent!);
      case "Grid3":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Grid3(content: homePageContent!);
      case "Grid5":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Grid5(content: homePageContent!);
      case "Grid6":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Grid6(content: homePageContent!);
      case "Grid7":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Grid7(content: homePageContent!);
      case "Grid8":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Grid8(content: homePageContent!);
      case "Grid10":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Grid10(content: homePageContent!);
      case "Grid11":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Grid11(content: homePageContent!);
      case "Banner2": // video
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner2(content: homePageContent!);
      case "Slider1":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider1(content: homePageContent!);
      case "Slider6":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider6(content: homePageContent!);
      case "Slider7":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider7(content: homePageContent!);
      case "Slider9":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider9(
                content: homePageContent!,
                onCartQtyChanged: (deltaQty, variantId) async {
                  await addCart(deltaQty, variantId);
                },
              );
      case "Banner1":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner1(content: homePageContent!);
      case "Banner3":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner3(content: homePageContent!);
      case "Banner4":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner4(content: homePageContent!);
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

  Future<void> getHomePageApi({
    int offset = 0,
    int limit = 10,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        setState(() => apiLoading = true);
      }

      final apiService = ApiService();
      final newResponse = await apiService.getHomePage(
        context,
        limit: limit,
        offset: offset,
      );

      /// FIRST PAGE
      if (!isLoadMore) {
        homePageResponse = newResponse; // normal full load
      } else {
        /// LOAD MORE PAGE – append data
        final oldList = homePageResponse?.content ?? [];
        final newList = newResponse.content ?? [];

        if (newList.isNotEmpty) {
          oldList.addAll(newList);
          homePageResponse?.content = oldList;
        } else {
          _hasMore = false; // no more pages
        }
      }

      // Save global meta values
      SharedPreferencesUtil()
          .saveString('region_id', newResponse.global?.regionId ?? "");
      SharedPreferencesUtil()
          .saveString('cart_id', newResponse.global?.cartId ?? "");
      SharedPreferencesUtil().saveString(
          'currency_symbol', newResponse.global?.currencySymbol ?? "");
      SharedPreferencesUtil()
          .saveMap('global', newResponse.global?.toJson() ?? {});

      setState(() {
        apiLoading = false;
        _isLoadingMore = false;
      });

      getCartApi();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        apiLoading = false;
        _isLoadingMore = false;
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
      final productItems = cartResponse?.cart?.items?.where((item) => !item.isPlatformFee).toList() ?? [];
      setState(() {
        cartItems = productItems.length;
        cartItemImages = productItems
            .map((item) => item.thumbnail ?? "")
            .toList();
      });
      if (productItems.isNotEmpty) {
        final qtyMap = <String, int>{};
        for (var item in productItems) {
          if (item.variantId != null) qtyMap[item.variantId!] = item.quantity ?? 0;
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
