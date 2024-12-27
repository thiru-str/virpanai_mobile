import 'package:flutter/material.dart';
import 'package:waioz/utility/app_strings.dart';

import 'widgets/common_header_app_bar.dart';
import 'widgets/order_detail_item_card.dart';

class OrderDetailItemPage extends StatefulWidget {
  const OrderDetailItemPage({super.key});

  @override
  State<OrderDetailItemPage> createState() => _OrderDetailItemPageState();
}

class _OrderDetailItemPageState extends State<OrderDetailItemPage> {
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: _buildOrdersList(),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return OrderDetailItemCard(
          imageUrl: 'https://cartel.waioz.com/uploads/1735195194161-men.png',
          size: 'M',
          productName: 'Men\'s Harrington Jacket',
          color: 'Lemon',
          price: '148',
        );
      },
    );
  }
}
