import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Order Details',showBack: true,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StoreSummaryCard(
                storeName: 'Poorvika Mobiles',
                address: 'Alagar Kovil Main Rd, K.Pudur, Madurai',
                totalPrice: '₹ 90,000',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'List of Products',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ListView.builder(
            itemCount: 5,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return const ProductsCard(
                    imageUrl: 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',
                    title: 'MI IOOOOmAh Power Bank 3i - Blue',
                    productCount: 100,
                    price: '100',
                  );
            },
          )
            ],
          ),
        ),
      ),
    );
  }
}
