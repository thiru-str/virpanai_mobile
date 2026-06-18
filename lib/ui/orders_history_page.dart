import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/order_history_reponse.dart';
import 'package:waioz/ui/order_detail_item_page.dart';
import 'package:waioz/ui/order_detail_page.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/custom_scrollable_tab_bar.dart';
import 'package:waioz/ui/widgets/order_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import 'widgets/no_orders_widget.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  OrderHistoryResponse? orderHistoryResponse;
  bool apiLoading = true;

  final int _limit = 20;
  int _offset = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    getOrderHistoryAPI(offset: _offset, limit: _limit);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMoreOrders();
      }
    });
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    _offset += _limit;
    await getOrderHistoryAPI(offset: _offset, limit: _limit, isLoadMore: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.orders,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body:  apiLoading
          ?  Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ) : orderHistoryResponse?.orders?.isNotEmpty ?? false ?
      Padding(padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        child: Column(
          children: [
            Expanded(
              child: _buildOrdersList(),
            ),
          ],
        ),) : NoOrdersWidget(
        message: AppStrings.no_order_yet,
        buttonText: AppStrings.explore_categories,
        iconPath: AppAssets.ic_cart_empty,
        showExplore: false,
        onButtonTap: () async {
          // final result = await PageRouteUtils.pushWithSlide(
          //     context,
          //     AddAddressPage());
          // if (result == true) {
          //   getAddressListApi();
          // }
        },
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: (orderHistoryResponse?.orders?.length ?? 0) + 1,
      itemBuilder: (context, index) {
        final orders = orderHistoryResponse?.orders ?? [];

        if (index < orders.length) {
          final order = orders[index];
          return OrderWidget(
            orderId: (order.displayId ?? 1).toString(),
            itemCount: (order.items?.where((item) => !item.isPlatformFee).length ?? 1).toString(),
            createdAt: toIST(order.createdAt ?? DateTime.now()),
            itemPrice: (order.status ?? '').toLowerCase() == 'canceled'
                ? (order.subtotal ?? 0)
                // order.total is the pre-discount total; wallet split and
                // loyalty checkout-apply (deferred debit) both live on
                // order.metadata and must be subtracted manually so the
                // list shows what the customer actually paid. Without the
                // loyalty leg a wallet+points order rendered the cart
                // total here while the detail page showed ₹0 owed.
                : ((order.total ?? 0)
                        - (order.metadata?.walletAmount ?? 0)
                        - (order.metadata?.loyaltyDiscountAmount ?? 0))
                    .clamp(0, double.infinity),
            onTap: () {
              PageRouteUtils.pushWithSlide(
                context,
                OrderDetailItemPage(orderId: order.id ?? ''),
              );
            },
          );
        }

        return _isLoadingMore
            ?  Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary,)),
        )
            : const SizedBox.shrink();
      },
    );

  }

  DateTime toIST(DateTime utcTime) {
    return utcTime.add(Duration(hours: 5, minutes: 30));
  }

  Future<void> getOrderHistoryAPI({int offset = 0, int limit = 10, bool isLoadMore = false}) async {
    try {
      if (!isLoadMore) setState(() => apiLoading = true);

      final ApiService apiService = ApiService();
      var response = await apiService.getOrderHistory(
        context,
        limit,
        offset
      );

      if (mounted) {
        setState(() {
          apiLoading = false;
          _isLoadingMore = false;

          final fetchedOrders = response.orders ?? [];

          if (isLoadMore) {
            orderHistoryResponse?.orders?.addAll(fetchedOrders);
          } else {
            orderHistoryResponse = response;
          }

          orderHistoryResponse?.orders?.sort(
                  (a, b) => (b.displayId ?? 0).compareTo(a.displayId ?? 0));

          final totalCount = response.count ?? fetchedOrders.length;
          _hasMore = (orderHistoryResponse?.orders?.length ?? 0) < totalCount;
        });
      }
    } catch (e) {
      setState(() {
        apiLoading = false;
        _isLoadingMore = false;
      });
      print('Order history API error: $e');
    }
  }




}
