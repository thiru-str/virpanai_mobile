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

  int _totalCount = 0;

  final int _limit = 10;
  int _offset = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();



  @override
  void initState() {
    super.initState();
    initApis();
    listenToEvents();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        loadMore();
      }
    });
  }



  @override
  void dispose() {
    _eventSubscription.cancel();
    _scrollController.dispose();
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
    _offset = 0;
    _hasMore = true;
    apiLoading = true;
    setState(() {});
    await getApis();
  }

  void loadMore() {
    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _offset += _limit;
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
                controller: _scrollController,
                itemCount: (displayResponse?.pendingOrderDetails?.length ?? 0) + 1,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final list = displayResponse?.pendingOrderDetails ?? [];

                  if (index < list.length) {
                    final item = list[index];
                    return GestureDetector(
                      onTap: () {
                        PageRouteUtils.pushWithFade(
                          context,
                          OrderDetailsPage(orderId: item.id ?? ''),
                        );
                      },
                      child: OrderItemCard(
                        imageUrl: item.shopImage ?? '',
                        storeName: item.shopName ?? '',
                        storeAddress: item.shopAddress ?? '',
                        phoneNumber: item.phone ?? '',
                        productCount: item.noOfProducts ?? '',
                        totalPrice: item.totalPrice ?? '',
                        statusText: item.orderStatus ?? '',
                        paymentMode: item.paymentMethod,
                        orderDate: item.date ?? '',
                        orderId: '#${(item.displayId ?? 0)}',
                      ),
                    );
                  }

                  // Loader at bottom
                  return _isLoadingMore
                      ?  Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary,)),
                  )
                      : const SizedBox();
                },
              )
              ,
            ),
          ],
        ),
      ),
    );
  }
  Future<void> getApis() async {
    try {
      final ApiService apiService = ApiService();

      final response = await apiService.pendingOrderDetail(
        context,
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _totalCount = response.count ?? 0;

        if (_offset == 0) {
          _pastOrderDetailResponse = response;
        } else {
          _pastOrderDetailResponse?.pendingOrderDetails
              ?.addAll(response.pendingOrderDetails ?? []);
        }

        apiLoading = false;
        _isLoadingMore = false;

        _hasMore = (_offset + _limit) < _totalCount;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
        _isLoadingMore = false;
      });
    }
  }

}
