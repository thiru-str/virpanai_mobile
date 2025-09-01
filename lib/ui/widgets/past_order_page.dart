import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/past_order_details.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../api/api_service.dart';
import '../../model/past_order_response.dart';
import '../../model/view_cart_model.dart';
import '../../utility/app_assets.dart';
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
  String? startUtc = '';
  String? endUtc = '';
  DateTime? startTimeUtc;
  DateTime? endTimeUtc;
  late StreamSubscription<ReloadEvent> _eventSubscription;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initApis();
    listenToEvents();
  }

  Future<void> initApis() async {
    getApis();
  }

  void listenToEvents() {
    _eventSubscription = eventBus.on<ReloadEvent>().listen((event) {
      if (mounted) {
        initApis();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription.cancel(); // Cancel the subscription to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
                title: 'Past Order',
                showFilter: true,
                onFilterTap: () async {
                  final result = await showOrdersFilterSheet(
                    context,
                    showDate: true,
                    showStatus: false,
                    initialStart: startTimeUtc,
                    initialEnd: endTimeUtc
                  );
                  if (result != null) {
                    startUtc = result.startUtc != null
                        ? DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(result.startUtc!.toUtc())
                        : '';
                    endUtc = result.endUtc != null
                        ? DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(result.endUtc!.toUtc())
                        : '';
                    setState(() {
                      startTimeUtc = result.startUtc;
                      endTimeUtc = result.endUtc;
                    });
                    debugPrint('Result: $result'); // Better debug logging
                    getApis();
                  }
                }),
            body: apiLoading?Center(child: CircularProgressIndicator(color: AppColors.primary,),):SafeArea(
        child: ( _pastOrderResponse?.pastOrders?.length??0) == 0?const EmptyView(imageAsset: AppAssets.ic_no_list, title: 'No Past Orders', description: 'You currently don\'t have any past orders',imageHeight: 150,):ListView.builder(
          itemCount: _pastOrderResponse?.pastOrders?.length??0,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final item= _pastOrderResponse?.pastOrders?[index];
            return GestureDetector(
              onTap: (){
                PageRouteUtils.pushWithFade(
                    context, PastOrderDetailsPage(date: item?.formatedDate??'',));
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
      final pastOrderResponse = await apiService.pastOrders(context,startUtc??'',endUtc??'');
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
