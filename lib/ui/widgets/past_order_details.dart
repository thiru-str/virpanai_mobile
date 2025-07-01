import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';

class PastOrderDetailsPage extends StatelessWidget {
  const PastOrderDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Past Order',showBack: true,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        //controller: controller,
                        //onChanged: onChanged,
                        decoration: InputDecoration(
                          //hintText: hintText,
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){},
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF005B65), // Dark teal tone
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.tune, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
          ListView.builder(
            itemCount: 5,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return OrderItemCard(
                imageUrl: 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',
                storeName: 'Supreme Mobiles',
                storeAddress: 'Alagar Kovil Main Rd, K.Pudur,Madurai',
                productCount: 200,
                totalPrice: '₹5,000',
                statusText: 'Processing',
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
