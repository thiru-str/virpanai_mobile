import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/past_order_details.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/ui/widgets/profile_info_card.dart';
import 'package:waioz/ui/widgets/shop_detail_row.dart';
import 'package:waioz/ui/widgets/shop_image_card.dart';
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';

import '../../utility/page_route_utils.dart';

class CustomerDetailPage extends StatelessWidget {
  const CustomerDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Info',showBack: true,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                child: Text(
                  'Owner Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const ProfileInfoCard(
                title: 'Name',
                value: 'Vishnu Kumar',
              ),
              const ProfileInfoCard(
                title: 'Email Address',
                value: 'Vishnu@Gmail.Com',
              ),
              const ProfileInfoCard(
                title: 'Phone Number',
                value: '+91 84512 26949',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                child: Text(
                  'Shop Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: const [
                    ShopDetailRow(title: 'Shop Name', value: 'Orange Mobiles'),
                    ShopDetailRow(title: 'Address', value: 'N Veli St Simmakkal'),
                    ShopDetailRow(title: 'Country', value: 'India'),
                    ShopDetailRow(title: 'City / Postal Code', value: 'Madurai / 625012'),
                    ShopDetailRow(title: 'GST Number', value: '1241572513'),
                    ShopDetailRow(
                      title: 'GST image',
                      imageUrl: 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                child: Text(
                  'Shop Image',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Column(
                children: [
                  ShopImageCard(
                    imageUrl: 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',
                    title: 'Shop Front With Name Board',
                    size: '870 MB',
                  ),
                  ShopImageCard(
                    imageUrl: 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',
                    title: 'Shop Interior',
                    size: '870 MB',
                  ),
                  ShopImageCard(
                    imageUrl: 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',
                    title: 'Shop Counter',
                    size: '870 MB',
                  ),
                ],
              )


            ],
          ),
        )
        ,
      ),
    );
  }
}
