import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/hold_account.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/ui/widgets/custom_app_bar.dart';
import 'package:waioz/ui/widgets/home/Slider2.dart';
import 'package:waioz/ui/widgets/home/banner1.dart';
import 'package:waioz/ui/widgets/home/banner_2.dart';
import 'package:waioz/ui/widgets/home/grid_1.dart';
import 'package:waioz/ui/widgets/home/grid_2.dart';
import 'package:waioz/ui/widgets/home/item_9.dart';

import 'package:waioz/ui/widgets/home/slider_1.dart';
import 'package:waioz/ui/widgets/home/slider_3.dart';
import 'package:waioz/ui/widgets/home/item_1.dart';
import 'package:waioz/ui/widgets/home/item_2.dart';
import 'package:waioz/ui/widgets/home/item_3.dart';
import 'package:waioz/ui/widgets/home/item_4.dart';
import 'package:waioz/ui/widgets/home/item_5.dart';
import 'package:waioz/ui/widgets/home/item_6.dart';
import 'package:waioz/ui/widgets/home/item_7.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../api/api_service.dart';

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

  late StreamSubscription<ViewCartModel> _eventSubscription;
  late final ScrollController _scrollController;
  late final ValueNotifier<_CartBarData> _cartBarData;

  final int _initialLimit = 10;

  bool _isInitialLoading = true;
  bool _isPrefetching = false;
  bool _isUserScrolling = false;

  int _totalCount = 0;
  List<Content> _contents = [];
  final List<Content> _pendingUiAppend = [];

  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _scrollController = ScrollController();
    _cartBarData = ValueNotifier(const _CartBarData.empty());
    initializePages();
    listenToEvents();
  }

  void listenToEvents() {
    _eventSubscription = eventBus.on<ViewCartModel>().listen((event) {
      if (!mounted) {
        return;
      }

      _cartBarData.value = _CartBarData(
        totalItems: event.totalItems,
        itemImages: List<String>.from(event.itemImages),
      );
    });
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    _scrollController.dispose();
    _cartBarData.dispose();
    super.dispose();
  }

  Future<void> initializePages() async {
    getHomePageApi();
    appHeader = (await SharedPreferencesUtil().getString('app_header')) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final double viewportHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: ValueListenableBuilder<_CartBarData>(
          valueListenable: _cartBarData,
          builder: (context, cartData, _) {
            return CustomSearchAppBar(
              hintText: 'Search "Mascara"',
              cartCount: cartData.totalItems,
              onCartClick: () => eventBus.fire(TabSwitchEvent(2)),
              onSearchTap: () {
                PageRouteUtils.pushWithFade(
                  context,
                  const ProductPage(categoryId: ''),
                );
              },
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _isInitialLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is UserScrollNotification) {
                        final scrolling =
                            notification.direction != ScrollDirection.idle;
                        if (scrolling != _isUserScrolling) {
                          _isUserScrolling = scrolling;
                          if (!scrolling) {
                            _flushPendingPrefetch();
                          }
                        }
                      } else if (notification is ScrollEndNotification) {
                        if (_isUserScrolling) {
                          _isUserScrolling = false;
                        }
                        _flushPendingPrefetch();
                      }
                      return false;
                    },
                    child: CustomScrollView(
                      key: const PageStorageKey<String>('home_cms_feed'),
                      controller: _scrollController,
                      cacheExtent: viewportHeight * 0.8,
                      physics: const ClampingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final content = _contents[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: getLayoutWidget(content),
                                );
                              },
                              childCount: _contents.length,
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: true,
                            ),
                          ),
                        ),
                        if (_isPrefetching)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 110),
                        ),
                      ],
                    ),
                  ),
            ValueListenableBuilder<_CartBarData>(
              valueListenable: _cartBarData,
              builder: (context, cartData, _) {
                if (cartData.totalItems == 0) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        PageRouteUtils.pushWithSlide(context, const CartPage());
                      },
                      child: ViewCartWidget(
                        totalItems: cartData.totalItems,
                        itemImages: cartData.itemImages,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getLayoutWidget(Content homePageContent) {
    final widget = switch (homePageContent.layoutName) {
      "item1" => Item1(content: homePageContent),
      "Slider2" => Slider2(content: homePageContent),
      "item2" => Item2(content: homePageContent),
      "item3" => Item3(content: homePageContent),
      "item4" => Item4(content: homePageContent),
      "item5" => Item5(content: homePageContent),
      "item6" => Item6(content: homePageContent),
      "item7" => Item7(content: homePageContent),
      "item9" => Item9(content: homePageContent),
      "Slider3" => Slider3(content: homePageContent),
      "Grid1" => Grid1(content: homePageContent),
      "Grid2" => Grid2(content: homePageContent),
      "Banner2" => Banner2(content: homePageContent),
      "Slider1" => Slider1(content: homePageContent),
      "Banner1" => Banner1(content: homePageContent),
      _ => const SizedBox(),
    };

    return RepaintBoundary(child: widget);
  }

  void getHomePageApi() async {
    try {
      final apiService = ApiService();

      // ---- FIRST LOAD (FAST) ----
      final initialResponse = await apiService.getHomePage(
        context,
        limit: _initialLimit,
        offset: 0,
      );

      if (initialResponse.error?.code == '00007') {
        showPendingOrdersDialog(context);
        return;
      }

      _totalCount = initialResponse.count ?? 0;

      setState(() {
        _contents = List.from(initialResponse.content ?? []);
        _isInitialLoading = false;
      });

      _saveGlobalData(initialResponse);
      getCartApi();

      // ---- PREFETCH REST (BACKGROUND) ----
      final loadedCount = _contents.length;

      if (_totalCount > loadedCount) {
        _prefetchRemaining(
          offset: loadedCount,
          totalRemaining: _totalCount - loadedCount,
        );
      }
    } catch (e) {
      setState(() => _isInitialLoading = false);
      debugPrint(e.toString());
    }
  }

  Future<void> _prefetchRemaining({
    required int offset,
    required int totalRemaining,
  }) async {
    if (_isPrefetching || totalRemaining <= 0) return;

    _isPrefetching = true;

    const int batchSize = 10;
    const int uiBatchThreshold = 12;

    int currentOffset = offset;
    int remaining = totalRemaining;

    final List<Content> buffer = [];

    try {
      while (remaining > 0 && mounted) {
        final fetchCount = remaining.clamp(0, batchSize);

        final response = await _apiService.getHomePage(
          context,
          limit: fetchCount,
          offset: currentOffset,
        );

        if (!mounted) return;

        buffer.addAll(response.content ?? []);

        currentOffset += fetchCount;
        remaining -= fetchCount;

        // Queue smaller chunks for UI append; avoid setState during active scroll.
        if (buffer.length >= uiBatchThreshold) {
          _pendingUiAppend.addAll(buffer);
          buffer.clear();
          _flushPendingPrefetch();
          await Future.delayed(
            _isUserScrolling
                ? const Duration(milliseconds: 48)
                : const Duration(milliseconds: 16),
          );
        }
      }

      if (buffer.isNotEmpty) {
        _pendingUiAppend.addAll(buffer);
        _flushPendingPrefetch(force: true);
      }
    } catch (e) {
      debugPrint('Prefetch failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPrefetching = false;
        });
      }
    }
  }

  void _flushPendingPrefetch({bool force = false}) {
    if (!mounted || _pendingUiAppend.isEmpty) return;
    if (_isUserScrolling && !force) return;

    final chunk = List<Content>.from(_pendingUiAppend);
    _pendingUiAppend.clear();
    setState(() {
      _contents.addAll(chunk);
    });
  }

  void _saveGlobalData(HomePageResponse response) {
    SharedPreferencesUtil()
        .saveString('region_id', response.global?.regionId ?? '');
    SharedPreferencesUtil()
        .saveString('cart_id', response.global?.cartId ?? '');
    SharedPreferencesUtil()
        .saveString('currency_symbol', response.global?.currencySymbol ?? '');
    SharedPreferencesUtil().saveMap('global', response.global?.toJson() ?? {});
  }

  void getCartApi() async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      final totalQty = cartResponse?.cart!.items!
          .map((item) => item.quantity ?? 0) // pick quantity, default to 0
          .fold<int>(0, (sum, qty) => sum + qty);
      final images = (cartResponse?.cart?.items ?? [])
          .map((item) => item.thumbnail)
          .where((thumb) => thumb != null && thumb.isNotEmpty)
          .cast<String>()
          .toList();

      _cartBarData.value = _CartBarData(
        totalItems: totalQty ?? 0,
        itemImages: images,
      );

      if ((cartResponse?.cart?.items?.length ?? 0) > 0) {
        eventBus.fire(ViewCartModel(totalQty ?? 0, images));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showPendingOrdersDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // eventBus.on<ClosePendingOrdersDialogEvent>().listen((event) {
        //   Navigator.of(context, rootNavigator: true).pop();
        //   Navigator.pop(context);
        // });

        return WillPopScope(
          onWillPop: () async {
            // Return false to prevent back button from closing dialog
            return false;
          },
          child: HoldAccountDialog(
            onJoin: () async {
              // Handle sign out action
              await SharedPreferencesUtil().clear();
              if (mounted) {
                PageRouteUtils.pushAndRemoveUntil(context, WelcomePage());
              }
            },
          ),
        );
      },
    );
  }
}

class _CartBarData {
  final int totalItems;
  final List<String> itemImages;

  const _CartBarData({required this.totalItems, required this.itemImages});

  const _CartBarData.empty()
      : totalItems = 0,
        itemImages = const [];
}
