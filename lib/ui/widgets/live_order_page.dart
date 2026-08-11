import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/dealer_response.dart';
import 'package:waioz/model/live_order_response.dart';
import 'package:waioz/ui/pending_order_details.dart';
import 'package:waioz/ui/dealer_order_create_page.dart';
import 'package:waioz/ui/profile_page.dart';
import 'package:waioz/ui/widgets/clear_pending_orders.dart';
import 'package:waioz/ui/widgets/empty_view.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../api/api_service.dart';
import '../../model/view_cart_model.dart';
import '../../utility/page_route_utils.dart';
import '../welcome_page.dart';
import 'order_details.dart';

class LiveOrderPage extends StatefulWidget {
  const LiveOrderPage({Key? key}) : super(key: key);

  @override
  State<LiveOrderPage> createState() => _LiveOrderPageState();
}

class _LiveOrderPageState extends State<LiveOrderPage> {
  final ApiService apiService = ApiService();
  LiveOrdersResponse? _liveOrdersResponse;
  DealerResponse? _dealerResponse;
  bool apiLoading = true;

  final int _limit = 10;
  int _offset = 0;

  bool _isFetchingMore = false;
  bool _hasMore = true;

  final List<LiveOrder> _orders = [];

  late ScrollController _scrollController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    getInitialApis();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getInitialApis() async {
    try {
      final dealerResponse = await apiService.getDealerDetails(context);
      await SharedPreferencesUtil()
          .saveMap('dealer_info', dealerResponse.toJson());

      await fetchLiveOrders(isInitial: true);

      setState(() {
        _dealerResponse = dealerResponse;
        apiLoading = false;
      });
    } catch (e) {
      apiLoading = false;
    }
  }

  Future<void> fetchLiveOrders({bool isInitial = false}) async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;

    final response = await apiService.liveOrders(
      context,
      limit: _limit,
      offset: _offset,
    );

    final newOrders = response.liveOrders ?? [];

    setState(() {
      if (isInitial) {
        _orders.clear();
      }

      _orders.addAll(newOrders);
      _offset += newOrders.length;

      _hasMore = _orders.length < (response.count ?? 0);
      _isFetchingMore = false;
      _liveOrdersResponse = response;
    });

    if (response.hasPending == true && isInitial) {
      showPendingOrdersDialog(context);
    }
  }

  Future<void> _refreshLiveOrdersAfterPlacement() async {
    _offset = 0;
    _hasMore = true;
    await fetchLiveOrders(isInitial: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore) {
      fetchLiveOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: apiLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Hello!',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _dealerResponse?.dealer?.name ?? '',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              PageRouteUtils.pushWithFade(
                                  context, ProfilePage());
                            },
                            icon: Icon(
                              Icons.account_circle_outlined,
                              color: AppColors.primary,
                              size: 32,
                            ))
                      ]),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Live Orders',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  // Ledger Balance Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          (_liveOrdersResponse?.rawLedgerBalance ?? 0) >= 0
                              ? AppAssets.order_bg
                              : AppAssets.order_bg_red,
                          height: 120,
                          fit: BoxFit.fill,
                        ),
                        Column(
                          children: [
                            const Text(
                              'Ledger Balance',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  _liveOrdersResponse?.ledgerBalance ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_liveOrdersResponse?.hasPending == true)
                                  Positioned.fill(
                                    child: ClipRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 6, sigmaY: 6),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Text(
                              'Total Value Of All Orders',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_orders.isEmpty)
                    const EmptyView(
                      imageAsset: AppAssets.ic_no_list,
                      title: 'No Live Orders',
                      description: 'You currently don\'t have any live orders',
                      imageHeight: 150,
                    )
                  else
                    ..._orders.map((item) {
                      return GestureDetector(
                        onTap: () {
                          PageRouteUtils.pushWithFade(
                            context,
                            OrderDetailsPage(
                              orderId: item.id ?? '',
                              isFromLiveOrder: true,
                            ),
                          );
                        },
                        child: OrderItemCard(
                          imageUrl: item.shopImage ?? '',
                          storeName: item.shopName ?? '',
                          storeAddress: item.shopAddress ?? '',
                          productCount: item.noOfProducts ?? '',
                          totalPrice: item.totalPrice ?? '',
                          phoneNumber: item.phone ?? '',
                          orderDate: item.date ?? '',
                          orderId: '#${item.displayId}',
                        ),
                      );
                    }).toList(),

                  if (_hasMore)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                          child: CircularProgressIndicator(
                        color: AppColors.primary,
                      )),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create order',
        backgroundColor: AppColors.primary,
        onPressed: () => showDealerOrderCustomerDrawer(
          context,
          onOrderPlaced: _refreshLiveOrdersAfterPlacement,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void showPendingOrdersDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        eventBus.on<ClosePendingOrdersDialogEvent>().listen((event) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pop(context);
        });

        return WillPopScope(
          onWillPop: () async {
            // Return false to prevent back button from closing dialog
            return false;
          },
          child: ClearPendingOrdersDialog(
            onLogOut: () {
              SharedPreferencesUtil().clear();
              PageRouteUtils.pushAndRemoveUntil(context, WelcomePage());
            },
            onJoin: () async {
              PageRouteUtils.push(context, const PendingOrderDetailsPage());
            },
          ),
        );
      },
    );
  }
}
