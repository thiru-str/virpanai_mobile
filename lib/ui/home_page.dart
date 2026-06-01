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
  bool _locationChangeInProgress = false;
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
    await getHomePageApi(limit: _limit, offset: _offset);
  }

  Future<void> _loadSelectedAddress() async {
    final map = await SharedPreferencesUtil().getMap('selected_address');
    if (!mounted) return;
    if (map == null) {
      setState(() {
        headerTitle = "";
        addressType = "";
        _selectedLat = null;
        _selectedLng = null;
        _selectedPincode = null;
      });
      return;
    }
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
          if (_locationChangeInProgress) return;
          final result = await PageRouteUtils.pushWithSlide(
            context,
            const SearchAddressPage(),
          );
          final selectedAddress = _normalizeSelectedAddress(result);
          if (selectedAddress == null || !mounted) return;
          await _handleLocationSelection(selectedAddress);
        },
        onProfileTap: () => eventBus.fire(TabSwitchEvent(4)),
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
              ?.where((item) => !item.isVirtualItem)
              .toList() ??
          [];
      final totalQty = productItems
          .map((item) => item.quantity ?? 0)
          .fold<int>(0, (sum, qty) => sum + qty);
      setState(() {
        cartItems = totalQty;
        cartItemImages = productItems.map((item) => item.thumbnail ?? "").toList();
      });
      final qtyMap = <String, int>{};
      for (var item in productItems) {
        if (item.variantId != null) {
          qtyMap[item.variantId!] =
              (qtyMap[item.variantId!] ?? 0) + (item.quantity ?? 0);
        }
      }
      eventBus.fire(ViewCartModel(cartItems, cartItemImages, qtyMap));
      //eventBus.fire(ViewCartModel(cartItems!, cartItemImages!));
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic>? _normalizeSelectedAddress(dynamic result) {
    if (result is! Map) return null;
    return Map<String, dynamic>.from(result);
  }

  double? _extractLatitude(Map<String, dynamic>? address) {
    final metadata = address?['metadata'];
    if (metadata is! Map) return null;
    return double.tryParse(metadata['latitude']?.toString() ?? '');
  }

  double? _extractLongitude(Map<String, dynamic>? address) {
    final metadata = address?['metadata'];
    if (metadata is! Map) return null;
    return double.tryParse(metadata['longitude']?.toString() ?? '');
  }

  String _extractCartStoreId(CartResponse? cart) {
    final metadata = cart?.cart?.metadata;
    if (metadata is! Map) return '';
    final storeId = metadata['storeId']?.toString().trim() ?? '';
    return storeId;
  }

  bool _isSameLocation(
    Map<String, dynamic>? currentAddress,
    Map<String, dynamic> nextAddress,
  ) {
    final currentLat = _extractLatitude(currentAddress);
    final currentLng = _extractLongitude(currentAddress);
    final nextLat = _extractLatitude(nextAddress);
    final nextLng = _extractLongitude(nextAddress);

    if (currentLat != null &&
        currentLng != null &&
        nextLat != null &&
        nextLng != null) {
      return currentLat == nextLat && currentLng == nextLng;
    }

    final currentLabel =
        (currentAddress?['address_1'] ?? currentAddress?['address_name'] ?? '')
            .toString();
    final nextLabel =
        (nextAddress['address_1'] ?? nextAddress['address_name'] ?? '')
            .toString();
    return currentLabel.isNotEmpty && currentLabel == nextLabel;
  }

  Future<bool> _showReplaceCartDialog(
    Future<void> Function() onConfirm,
  ) async {
    Object? dialogError;
    StackTrace? dialogStackTrace;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var isProcessing = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return PopScope(
              canPop: !isProcessing,
              child: AlertDialog(
                backgroundColor: Colors.white,
                title: const Text('Replace Cart Items?'),
                content: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isProcessing
                      ? const SizedBox(
                          key: ValueKey('location-change-loading'),
                          width: 220,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Updating location...',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : const Text(
                          key: ValueKey('location-change-message'),
                          'Your cart already contains items for the current location. If you switch location, those items will be removed.',
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: isProcessing
                        ? null
                        : () => Navigator.of(dialogContext).pop(false),
                    child: const Text('No, Stay in Current Location'),
                  ),
                  TextButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            setDialogState(() => isProcessing = true);
                            try {
                              await onConfirm();
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop(true);
                              }
                            } catch (error, stackTrace) {
                              dialogError = error;
                              dialogStackTrace = stackTrace;
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop(false);
                              }
                            }
                          },
                    child: const Text('Yes, Change Location'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (dialogError != null) {
      Error.throwWithStackTrace(dialogError!, dialogStackTrace!);
    }

    return result == true;
  }

  Future<void> _handleLocationSelection(
    Map<String, dynamic> nextAddress,
  ) async {
    final nextLat = _extractLatitude(nextAddress);
    final nextLng = _extractLongitude(nextAddress);

    if (nextLat == null || nextLng == null) {
      AppUtils.showToast('Unable to determine the selected location.');
      return;
    }

    final currentAddress =
        await SharedPreferencesUtil().getMap('selected_address');
    if (_isSameLocation(currentAddress, nextAddress)) {
      return;
    }

    setState(() => _locationChangeInProgress = true);

    try {
      final apiService = ApiService();
      final nextLocationDetails = await apiService.getPublicDetails(
        latitude: nextLat,
        longitude: nextLng,
      );
      final nextStoreId = nextLocationDetails.storeId?.trim() ?? '';

      if (nextStoreId.isEmpty) {
        AppUtils.showToast('No store found for the selected location.');
        return;
      }

      final cartId = await SharedPreferencesUtil().getString('cart_id');
      CartResponse? activeCart;
      String currentCartStoreId = '';

      if (cartId != null && cartId.isNotEmpty) {
        activeCart = await apiService.getCart(context);
        currentCartStoreId = _extractCartStoreId(activeCart);

        final currentLat = _extractLatitude(currentAddress);
        final currentLng = _extractLongitude(currentAddress);

        if (currentLat != null && currentLng != null) {
          final currentLocationDetails = await apiService.getPublicDetails(
            latitude: currentLat,
            longitude: currentLng,
          );
          final currentResolvedStoreId =
              currentLocationDetails.storeId?.trim() ?? '';

          if (currentResolvedStoreId.isNotEmpty &&
              currentCartStoreId != currentResolvedStoreId) {
            await apiService.syncCartLocation(
              context,
              latitude: currentLat,
              longitude: currentLng,
              address: currentAddress,
            );
            activeCart = await apiService.getCart(context);
            currentCartStoreId = _extractCartStoreId(activeCart);
          }

          if (currentCartStoreId.isEmpty) {
            currentCartStoreId = currentResolvedStoreId;
          }
        }
      }

      final realCartItems = (activeCart?.cart?.items ?? [])
          .where((item) => !item.isVirtualItem)
          .toList();

      final shouldReplaceCart = realCartItems.isNotEmpty &&
          currentCartStoreId.isNotEmpty &&
          currentCartStoreId != nextStoreId;

      if (shouldReplaceCart) {
        final confirmed = await _showReplaceCartDialog(
          () => _applyLocationChange(
            nextAddress,
            clearCartItems: true,
          ),
        );
        if (!confirmed) {
          return;
        }
      } else {
        await _applyLocationChange(
          nextAddress,
          clearCartItems: false,
        );
      }
    } catch (e) {
      AppUtils.showToast('Failed to change location. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _locationChangeInProgress = false);
      }
    }
  }

  Future<void> _applyLocationChange(
    Map<String, dynamic> nextAddress, {
    required bool clearCartItems,
  }) async {
    final latitude = _extractLatitude(nextAddress);
    final longitude = _extractLongitude(nextAddress);

    if (latitude == null || longitude == null) {
      AppUtils.showToast('Unable to determine the selected location.');
      return;
    }

    final apiService = ApiService();
    final cartId = await SharedPreferencesUtil().getString('cart_id');

    if (cartId != null && cartId.isNotEmpty) {
      await apiService.syncCartLocation(
        context,
        latitude: latitude,
        longitude: longitude,
        address: nextAddress,
      );

      if (clearCartItems) {
        await apiService.clearCartItems(context);
      }
    }

    await SharedPreferencesUtil().saveMap('selected_address', nextAddress);

    _offset = 0;
    _hasMore = true;
    await initializePages();
    getCartApi();
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
