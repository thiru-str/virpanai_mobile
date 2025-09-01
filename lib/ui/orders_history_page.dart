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

  @override
  void initState() {
    super.initState();
    getOrderHistoryAPI();
    _tabController = TabController(length: 5, vsync: this); // 5 tabs
  }

  @override
  void dispose() {
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
          // const SizedBox(height: 20),
          // CustomScrollableTabBar(
          //   tabController: _tabController,
          //   tabs: const [
          //     Tab(text: "Processing"),
          //     Tab(text: "Shipped"),
          //     Tab(text: "Delivered"),
          //     Tab(text: "Returned"),
          //     Tab(text: "Cancelled"),
          //   ],
          // ),
          // const SizedBox(height: 20),
          // Expanded(
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 25),
          //     child: TabBarView(
          //       controller: _tabController,
          //       children: [
          //         _buildOrdersList(["#428912", "#427364"]),
          //         _buildOrdersList(["#458912", "#457364"]),
          //         _buildOrdersList(["#453219"]),
          //         _buildOrdersList(["#451234", "#450678"]),
          //         _buildOrdersList(["#459876"]),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),) : NoOrdersWidget(
        message: AppStrings.no_order_yet,
        buttonText: AppStrings.explore_categories,
        iconPath: AppAssets.ic_cart_empty,
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
      itemCount: orderHistoryResponse?.orders?.length ?? 1,
      itemBuilder: (context, index) {
        return OrderWidget(
          orderId: (orderHistoryResponse?.orders?[index].displayId ?? 1).toString(),
          itemCount: (orderHistoryResponse?.orders?[index].items?.length ?? 1).toString(),
          createdAt: toIST(orderHistoryResponse?.orders?[index].createdAt??DateTime.now()),
          itemPrice: (orderHistoryResponse?.orders?[index].total?? 0),
          onTap: () {
            // PageRouteUtils.pushWithSlide(context, OrderDetailPage());
            PageRouteUtils.pushWithSlide(context, OrderDetailItemPage(orderId: orderHistoryResponse?.orders?[index].id??'',));
          },
        );
      },
    );
  }

  DateTime toIST(DateTime utcTime) {
    return utcTime.add(Duration(hours: 5, minutes: 30));
  }

  void getOrderHistoryAPI() async {
    try {
      final ApiService apiService = ApiService();
      var response = await apiService.getOrderHistory(context);
      if (mounted) {
        setState(() {
          apiLoading = false;
          // Sort orders by displayId in descending order, handling nullable displayId
          if (response?.orders != null) {
            response?.orders?.sort((a, b) {
              // Use null-coalescing operator to handle null values (default to 0)
              return (b.displayId ?? 0).compareTo(a.displayId ?? 0);  // Sort in descending order
            });
          }
          orderHistoryResponse = response;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiLoading = false;
        });
      }
      print(e);
    }
  }
}
