import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/past_order_detail_response.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/ui/widgets/store_location_widget.dart';
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../api/api_service.dart';
import '../../utility/page_route_utils.dart';
import '../order_filter_bottom_sheet.dart';
import 'order_details.dart';

class PastOrderDetailsPage extends StatefulWidget {
  final String date;
  const PastOrderDetailsPage({Key? key,required this.date}) : super(key: key);

  @override
  State<PastOrderDetailsPage> createState() => _PastOrderDetailsPageState();
}

class _PastOrderDetailsPageState extends State<PastOrderDetailsPage> {

  PastOrderDetailResponse? _pastOrderDetailResponse;
  bool apiLoading = true;
  List<String> initialStatuses = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initApis();
  }

  Future<void> initApis() async {
    getApis();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Past Order',showBack: true,),
      body: apiLoading?Center(child: CircularProgressIndicator(color: AppColors.primary,),):SafeArea(
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
                          hintText: 'Search anything...',
                          //hintText: hintText,
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final result = await showOrdersFilterSheet(
                          context,
                          showDate: false,
                          showStatus: true,
                          initialStatuses: initialStatuses
                        );
                        if (result != null) {
                          debugPrint('Result: $result'); // Better debug logging
                          setState(() {
                            initialStatuses = result.statuses;
                          });
                          getApis();
                        }
                      },
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
            itemCount: _pastOrderDetailResponse?.pastOrderDetails?.length??0,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final item = _pastOrderDetailResponse?.pastOrderDetails?[index];
              return GestureDetector(
                onTap: (){
                  PageRouteUtils.pushWithFade(
                      context, OrderDetailsPage(orderId: item?.id??'',));
                },
                child: OrderItemCard(
                  imageUrl: item?.shopImage??'',
                  storeName: item?.shopName??'',
                  storeAddress: item?.shopAddress??'',
                  productCount: item?.noOfProducts??'',
                  totalPrice: item?.totalPrice??'',
                  statusText: item?.orderStatus??'',
                ),
              );
            },
          )
            ],
          ),
        ),
      ),
    );
  }
  void getApis() async {
    try {
      final ApiService apiService = ApiService();
      final pastOrderDetailResponse = await apiService.pastOrderDetail(context,widget.date,initialStatuses);
      setState(() {
        _pastOrderDetailResponse = pastOrderDetailResponse;
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
