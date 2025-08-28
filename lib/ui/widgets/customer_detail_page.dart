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

import '../../model/customer_list_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/page_route_utils.dart';

class CustomerDetailPage extends StatelessWidget {
  final Customer? customer;
  const CustomerDetailPage({Key? key,required this.customer}) : super(key: key);

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
              ProfileInfoCard(
                title: 'Name',
                value: '${customer?.firstName??''} ${customer?.lastName??''}',
              ),
              ProfileInfoCard(
                title: 'Email Address',
                value: customer?.email??'',
              ),
              ProfileInfoCard(
                title: 'Phone Number',
                value: '+91 ${customer?.phone??''}',
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
                  children: [
                    ShopDetailRow(title: 'Shop Name', value: customer?.metadata?.shopName??''),
                    ShopDetailRow(title: 'Address', value:customer?.metadata?.address??''),
                    ShopDetailRow(title: 'Country', value: 'India'),
                    ShopDetailRow(title: 'City / Postal Code', value:customer?.metadata?.postalCode??''),
                    if(customer?.metadata?.isGst??false)
                        ShopDetailRow(
                            title: 'GST Number', value: customer?.metadata?.gstNumber??''),
                        ShopDetailRow(
                          title: 'GST image',
                          imageUrl: customer?.metadata?.shopGstImage??'',
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
              Column(
                children: [
                  ShopImageCard(
                    imageUrl: customer?.metadata?.shopNameBoardImage??'',
                    title: 'Shop Front With Name Board',
                    size: '870 MB',
                  ),
                  ShopImageCard(
                    imageUrl: customer?.metadata?.shopInteriorImage??'',
                    title: 'Shop Interior',
                    size: '870 MB',
                  ),
                  ShopImageCard(
                    imageUrl: customer?.metadata?.shopCounterImage??'',
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
