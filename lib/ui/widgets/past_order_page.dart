import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';

class PastOrderPage extends StatelessWidget {
  const PastOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Past Order',showFilter: true,),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 5,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return PastOrderCard(
              dateLabel: 'Mon, June 2, 2025',
              imageUrls:[ 'https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png','https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png','https://gowelmart.s3.ap-south-1.amazonaws.com/1751373789803-Rectangle_734.png',],
              productCount: 200,
              totalPrice: '100',
            );
          },
        ),
      ),
    );
  }
}
