import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/past_order_details.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../api/api_service.dart';
import '../../model/past_order_response.dart';
import '../../utility/app_assets.dart';
import '../../utility/date_utils.dart';
import '../../utility/page_route_utils.dart';
import '../order_filter_bottom_sheet.dart';
import 'empty_view.dart';

class PastOrderPage extends StatefulWidget {
  const PastOrderPage({Key? key}) : super(key: key);

  @override
  State<PastOrderPage> createState() => _PastOrderPageState();
}

class _PastOrderPageState extends State<PastOrderPage> {
  PastOrderResponse? _pastOrderResponse;
  bool apiLoading = true;

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
    return apiLoading?Center(child: CircularProgressIndicator(color: AppColors.primary,),):Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: 'Past Order',showFilter: true,onFilterTap: () async {
        // final initialDate = DateTime.now();
        // final dob = await DateHelper.showDobPicker(context, initialDate, disablePastDates: true);
        // debugPrint('dob ${DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(dob!.toUtc())}');
        final result3 = await showOrdersFilterSheet(
          context,
          showDate: true,
          showStatus: false,
        );
        if (result3 != null) {
          // result.startUtc, result.endUtc are UTC (or null if not chosen)
          // result.statuses is a List<String>
          print(result3);
        }
      }),
      body: SafeArea(
        child: ( _pastOrderResponse?.pastOrders?.length??0) == 0?const EmptyView(imageAsset: AppAssets.ic_no_list, title: 'No Past Orders', description: 'You currently don\'t have any past orders',imageHeight: 150,):ListView.builder(
          itemCount: _pastOrderResponse?.pastOrders?.length??0,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final item= _pastOrderResponse?.pastOrders?[index];
            return GestureDetector(
              onTap: (){
                PageRouteUtils.pushWithFade(
                    context, PastOrderDetailsPage(date: item?.date??'',));
              },
              child: PastOrderCard(
                dateLabel: item?.date??'',
                imageUrls:item?.data?.customerImages??[],
                productCount: item?.data?.noOfProducts??'',
                totalPrice: item?.data?.totalPrice??'',
              ),
            );
          },
        ),
      ),
    );
  }

  void getApis() async {
    try {
      final ApiService apiService = ApiService();
      final pastOrderResponse = await apiService.pastOrders(context);
      setState(() {
        _pastOrderResponse = pastOrderResponse;
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
