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
  String? status = 'shipped';
  late StreamSubscription<ReloadEvent> _eventSubscription;

  final int _limit = 10;
  int _offset = 0;

  bool _isFetchingMore = false;
  bool _hasMore = true;

  final List<PastOrder> _orders = [];

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    initApis();
    listenToEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _eventSubscription.cancel();
    super.dispose();
  }

  Future<void> initApis() async {
    _resetAndReload();
  }

  void listenToEvents() {
    _eventSubscription = eventBus.on<ReloadEvent>().listen((event) {
      if (mounted) {
        initApis();
      }
    });
  }

  Future<void> fetchPastOrders({bool isInitial = false}) async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;

    final response = await ApiService().pastOrders(
      context,
      startUtc ?? '',
      endUtc ?? '',
      status??'shipped',
      limit: _limit,
      offset: _offset,
    );

    final newOrders = response.pastOrders ?? [];

    setState(() {
      if (isInitial) {
        _orders.clear();
        _offset = 0;
      }

      _orders.addAll(newOrders);
      _offset += newOrders.length;

      _hasMore = _orders.length < (response.count ?? 0);
      _pastOrderResponse = response;

      _isFetchingMore = false;
      apiLoading = false;
    });
  }

  void _resetAndReload() {
    setState(() {
      apiLoading = true;
      _offset = 0;
      _hasMore = true;
      _isFetchingMore = false;
      _orders.clear();
    });

    fetchPastOrders(isInitial: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore) {
      fetchPastOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CommonAppBar(
                  title: 'Past Order',
                  showFilter: true,
                  onFilterTap: () async {
                    final result = await showOrdersFilterSheet(
                      context,
                      showDate: true,
                      showStatus: true,
                      initialStart: startTimeUtc,
                      initialEnd: endTimeUtc,
                      initialStatus: status,
                    );
                    if (result != null) {
                      startUtc = result.startUtc != null
                          ? DateFormat("yyyy-MM-ddTHH:mm:ss'Z'")
                          .format(result.startUtc!.toUtc())
                          : '';

                      endUtc = result.endUtc != null
                          ? DateFormat("yyyy-MM-ddTHH:mm:ss'Z'")
                          .format(result.endUtc!.toUtc())
                          : '';

                      setState(() {
                        startTimeUtc = result.startUtc;
                        endTimeUtc = result.endUtc;
                        status = result.status;
                      });

                      _resetAndReload();
                    }
                  }),
              body: apiLoading?Center(child: CircularProgressIndicator(color: AppColors.primary,),):SafeArea(
          child: _orders.isEmpty && !apiLoading ?const EmptyView(imageAsset: AppAssets.ic_no_list, title: 'No Past Orders', description: 'You currently don\'t have any past orders',imageHeight: 150,)
              :ListView.builder(
            controller: _scrollController,
            itemCount: _orders.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _orders.length) {
                return  Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary,)),
                );
              }

              final item = _orders[index];

              return GestureDetector(
                onTap: () {
                  PageRouteUtils.pushWithFade(
                    context,
                    PastOrderDetailsPage(
                      status: status??'',
                      date: item.formatedDate ?? '',
                    ),
                  );
                },
                child: PastOrderCard(
                  dateLabel: item.date ?? '',
                  imageUrls: item.data?.customerImages ?? [],
                  productCount: item.data?.totalOrders ?? 0,
                  totalPrice: item.data?.totalPrice ?? '',
                ),
              );
            },
          ),
              ),
      ),
    );
  }

}
