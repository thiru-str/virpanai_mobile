import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/dealer_response.dart';
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
import '../../utility/shared_preferences_util.dart';

class DistributorDetailPage extends StatefulWidget {
  const DistributorDetailPage({Key? key}) : super(key: key);

  @override
  State<DistributorDetailPage> createState() => _DistributorDetailPageState();
}

class _DistributorDetailPageState extends State<DistributorDetailPage> {

  DealerResponse? dealerResponse;
  Dealer? dealer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Wait for the customer data to be fetched
    dealerResponse = await getDistributorResponse();
    setState(() {
      dealer = dealerResponse?.dealer;
    });


  }

  Future<DealerResponse?> getDistributorResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('dealer_info');
    if (userData != null) {
      return DealerResponse.fromJson(userData);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Distributor Details',showBack: true,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24,),
              ProfileInfoCard(
                title: 'Name',
                value: dealer?.name??'',
              ),
              ProfileInfoCard(
                title: 'Email Address',
                value: dealer?.email??'',
              ),
              ProfileInfoCard(
                title: 'Phone Number',
                value: '+91 ${dealer?.phone??''}',
              ),
              Visibility(
                visible: (dealer?.address1??'').isNotEmpty,
                child: ProfileInfoCard(
                  title: 'Address',
                  value: dealer?.address1??'',
                ),
              ),
              Visibility(
                visible: (dealer?.panNumber??'').isNotEmpty,
                child: ProfileInfoCard(
                  title: 'PAN Number',
                  value: dealer?.panNumber??'',
                ),
              ),



            ],
          ),
        )
        ,
      ),
    );
  }
}
