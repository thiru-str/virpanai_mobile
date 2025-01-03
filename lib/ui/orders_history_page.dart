import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/ui/order_detail_page.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/custom_scrollable_tab_bar.dart';
import 'package:waioz/ui/widgets/order_widget.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // getOrderHistoryAPI();
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
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      child: Column(
        children: [
          Expanded(
            child: _buildOrdersList(["428912", "427364"]),
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
      ),),
    );
  }

  Widget _buildOrdersList(List<String> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderWidget(
          orderId: orders[index],
          itemCount: "2",
          onTap: () {
            PageRouteUtils.push(context, OrderDetailPage());
          },
        );
      },
    );
  }
  // void getOrderHistoryAPI(String? customerID) async {
  //   try {
  //     final ApiService apiService = ApiService();
  //     var response = await apiService.getWishList(context, customerID);
  //     if (mounted) {
  //       setState(() {
  //         apiLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         apiLoading = false;
  //       });
  //     }
  //     print(e);
  //   }
  // }
}
