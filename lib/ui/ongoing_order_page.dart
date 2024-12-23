


import 'package:flutter/material.dart';
import 'package:waioz/model/get_orders_response_model.dart';
import 'package:waioz/utility/AppColors.dart';

import '../api/api_service.dart';
import '../utility/shared_preferences_util.dart';
import 'order_item_grid.dart';


class OngoingOrderPage extends StatefulWidget {
  const OngoingOrderPage({super.key});

  @override
  State<OngoingOrderPage> createState() => _OngoingOrderPageState();
}

class _OngoingOrderPageState extends State<OngoingOrderPage> {
  GetOrdersResponse? getOrdersResponse;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: getOrdersResponse!=null ?Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Expanded(child: OrderItemGrid(ordersList: getOrdersResponse!.data!.orderList!))
          ],
        ),
      ):const Center(child: CircularProgressIndicator(color: AppColors.primary,),),
    );
  }

  void fetchProducts() async {
    String? token = await SharedPreferencesUtil().getString('token');
    int? branchId = await SharedPreferencesUtil().getInt('branch_id');
    final ApiService apiService = ApiService();
    try {
      getOrdersResponse = await apiService.getOrders(context);
      setState(() {
        getOrdersResponse;
      });
    } catch (e) {
      print(e);
    }
  }
}
