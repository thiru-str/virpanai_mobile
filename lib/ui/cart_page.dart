import 'package:flutter/material.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/rating_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

import '../api/api_service.dart';

class CartPage extends StatefulWidget {
  final bool isFromBottomNav;

  const CartPage({super.key,this.isFromBottomNav = true});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool apiLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getCartApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.isFromBottomNav ?? false
            ? null
            : CommonHeaderAppBar(
          onBackTap: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        body: Center(child: NoOrdersWidget(message: 'Your Cart is Empty', buttonText: 'Explore Categories', iconPath: AppAssets.ic_cart_empty, onButtonTap: (){})),);
  }

  void getCartApi() async {
    try {
      final ApiService apiService = ApiService();
      //ProductDetailReponse productDetailReponse = await apiService.productDetail(context,widget.productId);
      setState(() {
        apiLoading = false;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
