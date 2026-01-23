import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/past_order_detail_response.dart';
import 'package:waioz/model/pending_order_detail_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/empty_view.dart';
import 'package:waioz/ui/widgets/order_details.dart';
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
import 'order_filter_bottom_sheet.dart';

class PendingOrderDetailsPage extends StatefulWidget {
  const PendingOrderDetailsPage({Key? key}) : super(key: key);

  @override
  State<PendingOrderDetailsPage> createState() => _PendingOrderDetailsPageState();
}

class _PendingOrderDetailsPageState extends State<PendingOrderDetailsPage> {

  PendingOrderDetailResponse? _pastOrderDetailResponse;
  bool apiLoading = true;
  List<String> initialStatuses = [];
  late StreamSubscription<ReloadEvent> _eventSubscription;
  String _searchQuery = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initApis();
    listenToEvents();
  }




  @override
  void dispose() {
    _eventSubscription.cancel(); // Cancel the subscription to prevent memory leaks
    super.dispose();
  }

  void listenToEvents() {
    _eventSubscription = eventBus.on<ReloadEvent>().listen((event) {
      if (mounted) {
        initApis();
      }
    });
  }

  Future<void> initApis() async {
    getApis();
  }

  @override
  Widget build(BuildContext context) {
    final displayResponse = _pastOrderDetailResponse;

    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CommonAppBar(title: 'Pending Order', showBack: true),
        body: apiLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
          children: [

            // Content area that takes remaining space
            Expanded(
              child: (displayResponse?.pendingOrderDetails?.length ?? 0) == 0
                  ? Center(
                child: EmptyView(
                  imageAsset: AppAssets.ic_no_list,
                  title: _searchQuery.isNotEmpty ? 'No Results Found' : 'No Pending Orders',
                  description: _searchQuery.isNotEmpty
                      ? 'No orders match your search "$_searchQuery"'
                      : 'You currently don\'t have any past orders',
                  imageHeight: 150,
                ),
              )
                  : ListView.builder(
                itemCount: displayResponse?.pendingOrderDetails?.length ?? 0,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = displayResponse?.pendingOrderDetails?[index];
                  return GestureDetector(
                    onTap: () {
                      PageRouteUtils.pushWithFade(
                        context,
                        OrderDetailsPage(orderId: item?.id ?? ''),
                      );
                    },
                    child: OrderItemCard(
                      imageUrl: item?.shopImage ?? '',
                      storeName: item?.shopName ?? '',
                      storeAddress: item?.shopAddress ?? '',
                      phoneNumber: item?.phone ?? '',
                      productCount: item?.noOfProducts ?? '',
                      totalPrice: item?.totalPrice ?? '',
                      statusText: item?.orderStatus ?? '',
                      paymentMode: item?.paymentMethod,
                        orderDate: item?.date??'',
                        orderId: '#${(item?.displayId??0).toString()}'
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void getApis() async {
    try {
      final ApiService apiService = ApiService();
      final pastOrderDetailResponse = await apiService.pendingOrderDetail(context);
      setState(() {
        _pastOrderDetailResponse = pastOrderDetailResponse;
        apiLoading = false;
        if (_pastOrderDetailResponse?.pendingOrderDetails?.isEmpty??false) {
          eventBus.fire(ClosePendingOrdersDialogEvent());
        }
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
