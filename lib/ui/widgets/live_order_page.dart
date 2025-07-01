import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/utility/app_assets.dart';

import '../../utility/page_route_utils.dart';
import 'order_details.dart';

class LiveOrderPage extends StatelessWidget {
  const LiveOrderPage({Key? key}) : super(key: key);

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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Good Morning!',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ravi Kumar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Live Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Ledger Balance Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.order_bg,
                    height: 120,
                    fit: BoxFit.fitWidth,
                  ),
                  const Column(
                    children: [
                      Text(
                        'Ledger Balance',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '₹ 60,000',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
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
            // Store Cards
            ...stores.map((store) {
              // return PastOrderCard(
              //   dateLabel: 'mon, June 2, 2025',
              //   imageUrls:[ 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png','https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png','https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',],
              //   productCount: store['productCount'] as int,
              //   totalPrice: store['price'] as String,
              // );return ProductsCard(
              //   imageUrl: 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',
              //   title: 'MI IOOOOmAh Power Bank 3i - Blue',
              //   productCount: store['productCount'] as int,
              //   price: store['price'] as String,
              // );
              return GestureDetector(
                onTap: (){
                  PageRouteUtils.pushWithFade(
                      context,const OrderDetailsPage());
                },
                child: OrderItemCard(
                  imageUrl: 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',
                  storeName: store['name'] as String,
                  storeAddress: store['address'] as String,
                  productCount: store['productCount'] as int,
                  totalPrice: store['price'] as String,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
