import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/past_order_details.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';

import '../../utility/page_route_utils.dart';

class CreateCustomerPage extends StatelessWidget {
  const CreateCustomerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stores = [
      {
        'name': 'Poorvika Mobiles',
        'address': 'Alagar Kovil Main Rd, K.Pudur,Madurai',
        'productCount': 200,
        'price': '₹ 90,000',
        'image': 'https://your-url.com/icon1.png',
      },
      {
        'name': 'Supreme Mobiles',
        'address': 'Alagar Kovil Main Rd, K.Pudur,Madurai',
        'productCount': 100,
        'price': '₹5,000',
        'image': 'https://your-url.com/icon2.png',
      },
      {
        'name': 'The Chennai Mobiles',
        'address': 'Alagar Kovil Main Rd, K.Pudur,Madurai',
        'productCount': 50,
        'price': '₹ 20,000',
        'image': 'https://your-url.com/icon3.png',
      },
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(
        title: 'Customer List',
        showFilter: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  return OrderItemCard(
                    imageUrl:
                        'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',
                    storeName: stores[index]['name'] as String,
                    storeAddress: stores[index]['address'] as String,
                    productCount: stores[index]['productCount'] as int,
                    totalPrice: stores[index]['price'] as String,
                  );
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here (e.g., navigate to a new customer form)
        },
        backgroundColor: const Color(0xFF005B65), // Dark teal color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
