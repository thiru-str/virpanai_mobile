import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/widgets/search_address.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/widgets/combined_header_app_bar.dart';
import 'package:waioz/ui/widgets/home/Slider2.dart';
import 'package:waioz/ui/widgets/home/banner1.dart';
import 'package:waioz/ui/widgets/home/banner_2.dart';
import 'package:waioz/ui/widgets/home/banner_3_4.dart';
import 'package:waioz/ui/widgets/home/banner_5.dart';
import 'package:waioz/ui/widgets/home/marketplace_registry.dart';
import 'package:waioz/ui/widgets/home/cms_text_color.dart';
import 'package:waioz/ui/widgets/home/banner_6.dart';
import 'package:waioz/ui/widgets/home/banner_7.dart';
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
import 'package:waioz/ui/widgets/home/item_15.dart';
import 'package:waioz/ui/widgets/home/item_16.dart';
import 'package:waioz/ui/widgets/home/item_9.dart';
import 'package:waioz/ui/widgets/home/slider_1.dart';
import 'package:waioz/ui/widgets/home/slider_10.dart';
import 'package:waioz/ui/widgets/home/slider_11.dart';
import 'package:waioz/ui/widgets/home/slider_12.dart';
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
// --- marketplace list components (Slider50+/Banner8+/Collection3+) ---
import 'package:waioz/ui/widgets/home/slider50.dart';
import 'package:waioz/ui/widgets/home/slider51.dart';
import 'package:waioz/ui/widgets/home/slider52.dart';
import 'package:waioz/ui/widgets/home/slider53.dart';
import 'package:waioz/ui/widgets/home/slider54.dart';
import 'package:waioz/ui/widgets/home/slider55.dart';
import 'package:waioz/ui/widgets/home/slider56.dart';
import 'package:waioz/ui/widgets/home/slider57.dart';
import 'package:waioz/ui/widgets/home/slider58.dart';
import 'package:waioz/ui/widgets/home/slider59.dart';
import 'package:waioz/ui/widgets/home/banner8.dart';
import 'package:waioz/ui/widgets/home/banner9.dart';
import 'package:waioz/ui/widgets/home/banner10.dart';
import 'package:waioz/ui/widgets/home/banner11.dart';
import 'package:waioz/ui/widgets/home/banner12.dart';
import 'package:waioz/ui/widgets/home/banner13.dart';
import 'package:waioz/ui/widgets/home/banner14.dart';
import 'package:waioz/ui/widgets/home/banner15.dart';
import 'package:waioz/ui/widgets/home/banner16.dart';
import 'package:waioz/ui/widgets/home/banner17.dart';
import 'package:waioz/ui/widgets/home/collection3.dart';
import 'package:waioz/ui/widgets/home/collection4.dart';
import 'package:waioz/ui/widgets/home/collection5.dart';
import 'package:waioz/ui/widgets/home/collection6.dart';
import 'package:waioz/ui/widgets/home/collection7.dart';
import 'package:waioz/ui/widgets/home/collection8.dart';
import 'package:waioz/ui/widgets/home/collection9.dart';
import 'package:waioz/ui/widgets/home/collection10.dart';
import 'package:waioz/ui/widgets/home/collection11.dart';
import 'package:waioz/ui/widgets/home/collection12.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/ui_typography.dart';
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
  // Location params derived from the selected delivery address — passed to
  // the home page API so backend can later use them for geo-aware content.
  double? _selectedLat;
  double? _selectedLng;
  String? _selectedPincode;

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
    await _loadSelectedAddress();
    getHomePageApi(limit: _limit, offset: _offset);
  }

  Future<void> _loadSelectedAddress() async {
    final map = await SharedPreferencesUtil().getMap('selected_address');
    if (!mounted || map == null) return;
    // Build a single-line address from the parts we care about
    final addr1 = map['address_1'] as String? ?? '';
    final city = map['city'] as String? ?? '';
    final province = map['province'] as String? ?? '';
    final postal = map['postal_code'] as String? ?? '';
    final parts =
        [addr1, city, province, postal].where((s) => s.trim().isNotEmpty);
    final meta = map['metadata'] as Map<String, dynamic>?;
    setState(() {
      headerTitle = parts.join(', ');
      addressType = (map['address_name'] as String?)?.trim().isNotEmpty == true
          ? map['address_name'] as String
          : 'Other';
      _selectedLat = double.tryParse((meta?['latitude'] as String?) ?? '');
      _selectedLng = double.tryParse((meta?['longitude'] as String?) ?? '');
      _selectedPincode = postal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleContent = _visibleComponents;

    late final PreferredSizeWidget homeAppBar;
    if (apiLoading) {
      homeAppBar = HomeHeaderSkeleton(
        headerType: appHeader.isEmpty ? 'header-4' : appHeader,
      );
    } else {
      homeAppBar = CombinedHeaderAppBar(
        headerType: appHeader.isEmpty ? 'header-4' : appHeader,
        title: headerTitle,
        addressType: addressType,
        cartCount: cartItems ?? 0,
        onCartClick: () => eventBus.fire(TabSwitchEvent(2)),
        onSearchClick: () => PageRouteUtils.pushWithFade(
          context,
          const ProductPage(),
        ),
        onLocationTap: () async {
          await PageRouteUtils.pushWithSlide(
              context, const SearchAddressPage());
          initializePages();
        },
        onProfileTap: () => eventBus.fire(TabSwitchEvent(4)),
      );
    }

    return Scaffold(
        appBar: homeAppBar,
        backgroundColor: const Color(0xFFF9F9FB),
        body: SafeArea(
          child: apiLoading
              ? const HomePageSkeleton()
              : RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                  displacement: 28,
                  strokeWidth: 2.6,
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          if (visibleContent.isEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 32.0, 20.0, 28.0),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.55,
                                ),
                                child: NoOrdersWidget(
                                  message: AppStrings.components_empty,
                                  buttonText: AppStrings.explore_categories,
                                  iconPath: AppAssets.ic_cart_empty,
                                  onButtonTap: () {
                                    eventBus.fire(TabSwitchEvent(1));
                                  },
                                ),
                              ),
                            )
                          else ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 0.0,
                                  right: 0.0,
                                  top: 14.0,
                                  bottom: 12.0),
                              child: buildComponentList(visibleContent),
                            ),
                            if (_isLoadingMore)
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2.6,
                                  ),
                                ),
                              ),
                            if (!_hasMore)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 18.0),
                                child: Text(
                                  AppStrings.end_of_page,
                                  style: UiTypography.cardMeta(
                                    color: AppColors.textColor50,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                          SizedBox(
                            height:
                                cartItems != null && cartItems != 0 ? 112 : 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ));
  }

  List<Content> get _visibleComponents {
    final content = homePageResponse?.content ?? const <Content>[];
    return content.where(_shouldRenderComponent).toList();
  }

  bool _shouldRenderComponent(Content content) {
    const supportedLayouts = {
      "item1",
      "Slider2",
      "item2",
      "item3",
      "item4",
      "item5",
      "item6",
      "item7",
      "item8",
      "Slider3",
      "Grid1",
      "Grid2",
      "Grid3",
      "Grid5",
      "Grid6",
      "Grid7",
      "Grid8",
      "Grid10",
      "Grid11",
      "Banner2",
      "Slider1",
      "Slider6",
      "Slider7",
      "Slider9",
      "Banner1",
      "Banner3",
      "Banner4",
      "item9",
      "item11",
      "item12",
      "item13",
      "item14",
      "Slider10",
      "Slider11",
      "Slider12",
      "Banner5",
      "Banner6",
      "Banner7",
      "item15",
      "item16",
      ...kMarketplaceLayouts,
          "Slider50",
      "Slider51",
      "Slider52",
      "Slider53",
      "Slider54",
      "Slider55",
      "Slider56",
      "Slider57",
      "Slider58",
      "Slider59",
      "Banner8",
      "Banner9",
      "Banner10",
      "Banner11",
      "Banner12",
      "Banner13",
      "Banner14",
      "Banner15",
      "Banner16",
      "Banner17",
      "Collection3",
      "Collection4",
      "Collection5",
      "Collection6",
      "Collection7",
      "Collection8",
      "Collection9",
      "Collection10",
      "Collection11",
      "Collection12",
    };

    if (kMarketplaceNoDataLayouts.contains(content.layoutName)) {
      return true; // copy-only components render without layoutData
    }
    return supportedLayouts.contains(content.layoutName) &&
        (content.layoutData?.isNotEmpty ?? false);
  }

  ListView buildComponentList(List<Content> content) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: content.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < content.length) {
          final homePageContent = content[index];
          return AppReveal(
            index: index,
            child: CmsTextColor(
              color: parseCmsColor(homePageContent.layoutSecondaryColor),
              cardColor: parseCmsColor(homePageContent.layoutCardColor),
              child: getLayoutWidget(homePageContent),
            ),
          );
        }

        return _isLoadingMore
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.6,
                    ),
                  ),
                ),
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
      case "Slider10":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider10(
                content: homePageContent!,
                onCartQtyChanged: (deltaQty, variantId) async {
                  await addCart(deltaQty, variantId);
                },
              );
      case "Slider11":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider11(content: homePageContent!);
      case "Slider12":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider12(content: homePageContent!);
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
      case "Banner5":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner5(content: homePageContent!);
      case "Banner6":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner6(content: homePageContent!);
      case "Banner7":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner7(content: homePageContent!);
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
      case "item15":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item15(
                  content: homePageContent!,
                  onCartQtyChanged: (deltaQty, variantId) async {
                    await addCart(deltaQty, variantId);
                  },
                ),
              );
      case "item16":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Item16(content: homePageContent!),
              );
      case "Slider50":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider50(content: homePageContent!);
      case "Slider51":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider51(content: homePageContent!);
      case "Slider52":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider52(content: homePageContent!);
      case "Slider53":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider53(content: homePageContent!);
      case "Slider54":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider54(content: homePageContent!);
      case "Slider55":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider55(content: homePageContent!);
      case "Slider56":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider56(content: homePageContent!);
      case "Slider57":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider57(content: homePageContent!);
      case "Slider58":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider58(content: homePageContent!);
      case "Slider59":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Slider59(content: homePageContent!);
      case "Banner8":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner8(content: homePageContent!);
      case "Banner9":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner9(content: homePageContent!);
      case "Banner10":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner10(content: homePageContent!);
      case "Banner11":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner11(content: homePageContent!);
      case "Banner12":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner12(content: homePageContent!);
      case "Banner13":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner13(content: homePageContent!);
      case "Banner14":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner14(content: homePageContent!);
      case "Banner15":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner15(content: homePageContent!);
      case "Banner16":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner16(content: homePageContent!);
      case "Banner17":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Banner17(content: homePageContent!);
      case "Collection3":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection3(content: homePageContent!);
      case "Collection4":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection4(content: homePageContent!);
      case "Collection5":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection5(content: homePageContent!);
      case "Collection6":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection6(content: homePageContent!);
      case "Collection7":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection7(content: homePageContent!);
      case "Collection8":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection8(content: homePageContent!);
      case "Collection9":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection9(content: homePageContent!);
      case "Collection10":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection10(content: homePageContent!);
      case "Collection11":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection11(content: homePageContent!);
      case "Collection12":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Collection12(content: homePageContent!);
      default:
        return marketplaceHomeWidget(
              homePageContent!,
              onCartQtyChanged: (delta, variantId) async {
                await addCart(delta, variantId);
              },
            ) ??
            const SizedBox();
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
        latitude: _selectedLat,
        longitude: _selectedLng,
        pincode: _selectedPincode,
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
      final productItems = cartResponse?.cart?.items
              ?.where((item) => !item.isPlatformFee)
              .toList() ??
          [];
      setState(() {
        cartItems = productItems.length;
        cartItemImages =
            productItems.map((item) => item.thumbnail ?? "").toList();
      });
      if (productItems.isNotEmpty) {
        final qtyMap = <String, int>{};
        for (var item in productItems) {
          if (item.variantId != null)
            qtyMap[item.variantId!] = item.quantity ?? 0;
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
