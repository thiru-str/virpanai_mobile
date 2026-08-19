import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/home/Slider2.dart';
import 'package:waioz/ui/widgets/home/marketplace_registry.dart';
import 'package:waioz/ui/widgets/home/cms_text_color.dart';
import 'package:waioz/ui/widgets/home/banner1.dart';
import 'package:waioz/ui/widgets/home/banner_2.dart';
import 'package:waioz/ui/widgets/home/banner_3_4.dart';
import 'package:waioz/ui/widgets/home/banner_5.dart';
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
import 'package:waioz/ui/widgets/no_orders_widget.dart';
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

  List<Content> get _visibleComponents {
    final content = customPageResponse?.content ?? const <Content>[];
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
      ...kMarketplaceLayouts,
    };

    if (kMarketplaceNoDataLayouts.contains(content.layoutName)) {
      return true; // copy-only components render without layoutData
    }
    return supportedLayouts.contains(content.layoutName) &&
        (content.layoutData?.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final visibleComponents = _visibleComponents;

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
                            child: visibleComponents.isEmpty
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
                                            itemCount: visibleComponents.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              final homePageContent =
                                                  visibleComponents[index];
                                              return CmsTextColor(
                                                color: parseCmsColor(
                                                    homePageContent
                                                        .layoutSecondaryColor),
                                                cardColor: parseCmsColor(
                                                    homePageContent
                                                        .layoutCardColor),
                                                accent: parseCmsColor(
                                                    homePageContent
                                                        .layoutPrimaryColor),
                                                child: clampCmsTextScale(
                                                    context,
                                                    getLayoutWidget(
                                                        homePageContent)),
                                              );
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
      case "Slider10":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Slider10(
                  content: homePageContent!,
                  onCartQtyChanged: (deltaQty, variantId) async {
                    await addCart(deltaQty, variantId);
                  },
                ),
              );
      case "Slider11":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Slider11(content: homePageContent!),
              );
      case "Slider12":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Slider12(content: homePageContent!),
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
      case "Banner5":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Banner5(content: homePageContent!),
              );
      case "Banner6":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Banner6(content: homePageContent!),
              );
      case "Banner7":
        return homePageContent?.layoutData?.isEmpty == true
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Banner7(content: homePageContent!),
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
        cartItems = cartResponse?.cart?.items
            ?.where((item) => !item.isPlatformFee)
            .length;
        cartItemImages = cartResponse?.cart?.items
            ?.where((item) => !item.isPlatformFee)
            .map((item) => item.thumbnail ?? "")
            .toList();
      });
      if ((cartResponse?.cart?.items
                  ?.where((item) => !item.isPlatformFee)
                  .length ??
              0) >
          0) {
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
