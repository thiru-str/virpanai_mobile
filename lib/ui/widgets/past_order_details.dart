import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/past_order_detail_response.dart';
import 'package:waioz/model/view_cart_model.dart';
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
import 'empty_view.dart';
import 'order_details.dart';

class PastOrderDetailsPage extends StatefulWidget {
  final String date;
  const PastOrderDetailsPage({Key? key,required this.date}) : super(key: key);

  @override
  State<PastOrderDetailsPage> createState() => _PastOrderDetailsPageState();
}

class _PastOrderDetailsPageState extends State<PastOrderDetailsPage> {

  PastOrderDetailResponse? _pastOrderDetailResponse;
  PastOrderDetailResponse? _filteredPastOrderDetailResponse;
  bool apiLoading = true;
  List<String> initialStatuses = [];
  late StreamSubscription<ReloadEvent> _eventSubscription;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initApis();
    listenToEvents();


    // Add listener for search text changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterOrders();
      });
    });
  }

  void _filterOrders() {
    if (_pastOrderDetailResponse == null || _searchQuery.isEmpty) {
      _filteredPastOrderDetailResponse = _pastOrderDetailResponse;
      return;
    }

    final filteredOrders = _pastOrderDetailResponse!.pastOrderDetails?.where((order) {
      return order.shopName?.toLowerCase().contains(_searchQuery) == true ||
          order.shopAddress?.toLowerCase().contains(_searchQuery) == true ||
          order.orderStatus?.toLowerCase().contains(_searchQuery) == true ||
          order.totalPrice?.toLowerCase().contains(_searchQuery) == true ||
          (order.noOfProducts?.toString().contains(_searchQuery) == true);
    }).toList();

    setState(() {
      _filteredPastOrderDetailResponse = PastOrderDetailResponse(
        pastOrderDetails: filteredOrders,
        // Copy other properties if they exist
      );
    });
  }

  // Clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filteredPastOrderDetailResponse = _pastOrderDetailResponse;
    });
  }


  @override
  void dispose() {
    _eventSubscription.cancel(); // Cancel the subscription to prevent memory leaks
    _searchController.dispose();
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
    final displayResponse = _searchQuery.isNotEmpty
        ? _filteredPastOrderDetailResponse
        : _pastOrderDetailResponse;
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
                        controller: _searchController,
                        //onChanged: onChanged,
                        decoration: InputDecoration(

                          hintText: 'Search anything...',
                          //hintText: hintText,
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                            onPressed: _clearSearch,
                          )
                              : null,
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
              (displayResponse?.pastOrderDetails?.length ?? 0) == 0
                  ? Padding(
                padding: const EdgeInsets.only(top: 48.0),
                child: EmptyView(
                  imageAsset: AppAssets.ic_no_list,
                  title: _searchQuery.isNotEmpty ? 'No Results Found' : 'No Past Orders',
                  description: _searchQuery.isNotEmpty
                      ? 'No orders match your search "$_searchQuery"'
                      : 'You currently don\'t have any past orders',
                  imageHeight: 150,
                ),
              )
                  : ListView.builder(
                          itemCount: displayResponse?.pastOrderDetails?.length??0,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
              final item = displayResponse?.pastOrderDetails?[index];
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
