import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/ui/widgets/store_location_widget.dart';
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_utils.dart';

import '../../api/api_service.dart';
import '../../model/live_order_detail_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/font_utils.dart';
import '../../utility/page_route_utils.dart';
import 'common_alert_dialog.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final bool isFromLiveOrder;

  const OrderDetailsPage(
      {Key? key, required this.orderId, this.isFromLiveOrder = false})
      : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  LiveOrderDetailResponse? _liveOrderDetailResponse;
  bool apiLoading = true;
  bool completeOrderLoading = false;

  String _selectedCompletionStatus = 'Delivered'; // default

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
      appBar: CommonAppBar(
        title: widget.isFromLiveOrder ? 'Order Details' : 'Past Order',
        showBack: true,
      ),
      body: apiLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StoreSummaryCard(
                      storeName: _liveOrderDetailResponse?.data?.shopName ?? '',
                      address:
                          _liveOrderDetailResponse?.data?.shopAddress ?? '',
                      phone: _liveOrderDetailResponse?.data?.phone ?? '',
                      orderDate: _liveOrderDetailResponse?.data?.date ?? '',
                      orderId:
                          '#${(_liveOrderDetailResponse?.data?.displayId ?? 0).toString()}',
                      totalPrice:
                          _liveOrderDetailResponse?.data?.totalPrice ?? '',
                    ),
                    // StoreLocationCard(
                    //   icon: const Icon(Icons.location_on, color: Colors.teal, size: 32),
                    //   mapWidget: Image.asset(
                    //     AppAssets.ic_map,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    Visibility(
                      visible:
                          (_liveOrderDetailResponse?.data?.paymentMethod ?? '')
                              .isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Payment Mode',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Text(
                                  _liveOrderDetailResponse
                                          ?.data?.paymentMethod ??
                                      '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'List of Products',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Visibility(
                              visible: !widget.isFromLiveOrder &&
                                  (_liveOrderDetailResponse
                                                  ?.data?.orderStatus ??
                                              '')
                                          .toLowerCase() ==
                                      'processing',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: const Text(
                                  "Yet to progress",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                    ListView.builder(
                      itemCount:
                          _liveOrderDetailResponse?.data?.products?.length ?? 0,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final item =
                            _liveOrderDetailResponse?.data?.products?[index];
                        return ProductsCard(
                          imageUrl: item?.productImage ?? '',
                          title: item?.productTitle ?? '',
                          variantTitle: item?.variantTitle,
                          productCount: item?.quantity ?? '',
                          price: item?.total ?? '',
                        );
                      },
                    ),
                    Visibility(
                      visible:
                          (_liveOrderDetailResponse?.data?.orderStatus ?? '')
                                  .toLowerCase() ==
                              'shipped',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              "Update Order Status",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Radio Buttons
                            ...completionStatuses.keys.map((displayStatus) {
                              return RadioListTile<String>(
                                value: displayStatus,
                                groupValue: _selectedCompletionStatus,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCompletionStatus = value!;
                                  });
                                },
                                title: Text(
                                  displayStatus,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                activeColor: AppColors.primary,
                                contentPadding: EdgeInsets.zero,
                                dense: true, // 🔥 reduces height
                                visualDensity: const VisualDensity(
                                  vertical: -4, // 🔥 tighter spacing
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 12),

                            // Button
                            completeOrderLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ElevatedButton(
                                    onPressed: () async {
                                      if ((_liveOrderDetailResponse
                                                      ?.data?.paymentMethod ??
                                                  '')
                                              .toLowerCase() ==
                                          'cod') {
                                        _showPaymentConfirmation(context);
                                      } else {
                                        markAsComplete(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      minimumSize:
                                          const Size(double.infinity, 60),
                                    ),
                                    child: Text(
                                      'Update Status',
                                      style: FontUtils.primaryFontStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> markAsComplete(BuildContext context) async {
    setState(() {
      completeOrderLoading = true;
    });
    try {
      final selectedApiStatus = completionStatuses[_selectedCompletionStatus]!;

      final response = await ApiService().completeOrder(
          context,
          _liveOrderDetailResponse?.data?.orderId ?? '',
          _liveOrderDetailResponse?.data?.fulfillmentId ?? '',
          selectedApiStatus);

      if ((response.message ?? '').isNotEmpty) {
        AppUtils.showToast(response.message!);
      }

      setState(() {
        _liveOrderDetailResponse?.data?.orderStatus = 'Completed';
        eventBus.fire(ReloadEvent(true));
      });
    } catch (error) {
      debugPrint('$error');
    } finally {
      setState(() {
        completeOrderLoading = false;
      });
    }
  }

  void getApis() async {
    try {
      final ApiService apiService = ApiService();
      final orderDetailResponse =
          await apiService.orderDetail(context, widget.orderId);
      setState(() {
        _liveOrderDetailResponse = orderDetailResponse;
        apiLoading = false;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void _showPaymentConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonAlertDialog(
          title: 'COD Order',
          content:
              'This is a Cash on Delivery order. Please ensure payment is collected before proceeding.',
          contentOk: 'Proceed',
          contentCancel: 'Cancel',
          onTapOk: () {
            Navigator.pop(context);
            markAsComplete(context);
          },
        );
      },
    );
  }

  final Map<String, String> completionStatuses = {
    'Delivered': 'delivered',
    'Partially Delivered': 'partially delivered',
    'Canceled': 'canceled',
    'Partially Canceled': 'partially canceled',
  };
}
