import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';

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
        'price': '₹ 5,000',
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/bg_ledger.svg', // Replace with your actual SVG
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  Column(
                    children: const [
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
              return OrderItemCard(
                imageUrl: store['image']??'',
                storeName: store['name']!,
                storeAddress: store['address']!,
                productCount: store['productCount']!,
                totalPrice: store['price']!,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
