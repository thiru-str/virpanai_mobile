import 'package:flutter/material.dart';
import 'package:waioz/model/order_history_reponse.dart';
import 'package:waioz/ui/transaction_detail_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/order_status_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import 'bottom_nav_page.dart';
import 'widgets/cart_calculation.dart';
import 'widgets/common_header_app_bar.dart';
import 'widgets/order_detail_item_card.dart';

class OrderDetailItemPage extends StatefulWidget {
  final String? orderId;

  const OrderDetailItemPage({super.key, this.orderId});

  @override
  State<OrderDetailItemPage> createState() => _OrderDetailItemPageState();
}

class _OrderDetailItemPageState extends State<OrderDetailItemPage> {
  String paymentType = "Unknown"; // Default value
  Order? order;
  Map<String, String> paymentTypeMap = {
    "pp_system_default": "COD",
    "pp_stripe_stripe": "Stripe",
    "pp_razorpay_razorpay": "Razorpay",
    "pp_neft_neft": "UPI",
  };
  bool apiLoading = true;

  @override
  void initState() {
    super.initState();
    initializePages();
  }

  Future<void> initializePages() async {
    getOrderHistoryAPI();
  }

  void getOrderHistoryAPI() async {
    try {
      final ApiService apiService = ApiService();
      var response = await apiService.getIndividualOrderHistory(
          context, widget.orderId ?? '');
      setState(() {
        order = response.order;
        debugPrint('order details called');
        String? paymentId = order
                ?.paymentCollections?.first.payments?.firstOrNull?.providerId ??
            '';
        print(paymentId);
        paymentType = paymentTypeMap[paymentId] ?? "Unknown";
        apiLoading = false;
      });
    } catch (e) {
      debugPrint('exception called');
      if (mounted) {
        setState(() {
          apiLoading = false;
        });
      }
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    //First check if canceled
    final isCanceled = order?.status == 'canceled';
    // Map fulfillmentStatus
    final fulfillmentStatus = order?.metadata?.fulfillmentStatus ?? '';

    final steps = buildOrderSteps(order?.status, order?.metadata?.fulfillmentStatus);
    final currentStep = getCurrentStep(order?.status, order?.metadata?.fulfillmentStatus);

    return PopScope(
        canPop: false, // Disable default back button
        onPopInvoked: (didPop) async {
          if (didPop) return;
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context); // Normal back navigation
          } else {
            // Redirect to home when no backstack exists
            PageRouteUtils.pushAndRemoveUntil(context, BottomNavPage());
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CommonHeaderAppBar(
            title: AppStrings.orders,
            onBackTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                PageRouteUtils.pushAndRemoveUntil(context, BottomNavPage());
              }
            },
          ),
          body: apiLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : SingleChildScrollView(
                  // Wrap the body with SingleChildScrollView for scrolling
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    // Use a Column to arrange the widgets vertically
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrderStatusWidget(
                        currentStep: currentStep,
                        steps: steps,
                        isCanceled: order?.status == 'canceled',
                      ),
                      const SizedBox(height: 10), // List of order items
                      _buildOrdersList(),
                      const SizedBox(height: 10), // List of order items
                      _buildSectionTitle('Billing details'),
                      const SizedBox(height: 10), // List of order items
                      Container(
                        padding: const EdgeInsets.all(0.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CartPaymentMethodWidget(
                              paymentMethod: paymentType,
                              // Or any other payment method
                              onTap: () {
                                PageRouteUtils.pushWithSlide(
                                    context,
                                    TransactionDetailsScreen(
                                      orderID: order?.id ?? "",
                                    ));
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              visible: (order?.subtotal ?? 0) > 0,
                              child: CartCalculation(
                                keyText: '${AppStrings.subTotal}:',
                                valueText: CurrencyUtil.appendCurrency(
                                    (order?.subtotal ?? 0).toString()),
                              ),
                            ),
                            Visibility(
                              visible: (order?.taxTotal ?? 0) > 0,
                              child: CartCalculation(
                                keyText: '${AppStrings.tax}:',
                                valueText: CurrencyUtil.appendCurrency(
                                    (order?.taxTotal ?? 0).toString()),
                              ),
                            ),
                            Visibility(
                              visible: (order?.total ?? 0) > 0,
                              child: CartCalculation(
                                  keyText: '${AppStrings.total}:',
                                  valueText: CurrencyUtil.appendCurrency(
                                      (order?.total ?? 0).toString())),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Shipping details'),
                      const SizedBox(height: 20), // List of order items
                      _buildShippingDetailsCard(), // Shipping details card
                      const SizedBox(height: 20),
                      Visibility(
                        visible: fulfillmentStatus == 'not_fulfilled' &&
                            !isCanceled,
                        child: GestureDetector(
                          onTap: (){
                            _showCancellation(context,order?.id??'');
                          },
                          child: Text(
                            'Cancel Order',
                            style: FontUtils.primaryFontStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
        ));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: FontUtils.primaryFontStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showCancellation(BuildContext context,String orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonAlertDialog(
          title: 'Cancel Order',
          content: 'Are you sure you want to cancel the order?',
          contentOk: AppStrings.yes,
          contentCancel: AppStrings.no,
          onTapOk: () async {
            try {
              Navigator.pop(context);
              setState(() {
                apiLoading = true;
              });
              final response = await ApiService().cancelOrder(context, orderId);
               debugPrint('order status ${response.status??false}');
              if(response.status??false) {
                getOrderHistoryAPI();
              }
            } catch (e) {
              print(e);
            } finally {
              setState(() {
                apiLoading = false;
              });
            }

          },
        );
      },
    );
  }

  // Method to build the list of orders
  Widget _buildOrdersList() {
    return ListView.builder(
      shrinkWrap: true,
      // Prevent the list from taking up unnecessary space
      physics: NeverScrollableScrollPhysics(),
      // Disable scrolling for the list within SingleChildScrollView
      itemCount: order?.items?.length ?? 0,
      // Define the number of items you want to show
      itemBuilder: (context, index) {
        final itemDetail = order?.items?[index];
        return OrderDetailItemCard(
          imageUrl: itemDetail?.thumbnail ?? "",
          size: itemDetail?.variantTitle ?? "",
          productName: (itemDetail?.quantity ?? "").toString() +
              " x " +
              (itemDetail?.productTitle ?? ""),
          color: '',
          // Product color
          price:
              CurrencyUtil.appendCurrency(itemDetail?.total.toString() ?? "0"),
        );
      },
    );
  }

  Widget _buildShippingDetailsCard() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        width: double.infinity, // Full width
        decoration: BoxDecoration(
          color: AppColors.secondary, // Background color
          borderRadius:
              BorderRadius.circular(8), // Border radius for rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            Text(
              '${order?.cart?.shippingAddress?.address1}, '
              '${order?.cart?.shippingAddress?.city}, '
              '${order?.cart?.shippingAddress?.postalCode}, '
              '${order?.cart?.shippingAddress?.province ?? ''}.',style: FontUtils.primaryFontStyle(fontSize: 12),
            ),
            SizedBox(height: 4),
            Text('${order?.cart?.shippingAddress?.phone ?? ''}',style: FontUtils.secondaryFontStyle(fontSize: 12),),
          ],
        ));
  }

  List<OrderStatusStep> buildOrderSteps(String? orderStatus, String? fulfillmentStatus) {
    if (orderStatus == 'canceled') {
      return [
        OrderStatusStep(
          label: 'Processing',
          svgAsset: AppAssets.order_processing,
          activeColor: Colors.grey,
        ),
        OrderStatusStep(
          label: 'Cancelled',
          svgAsset: AppAssets.order_canceled,
          activeColor: Colors.red,
        ),
      ];
    }

    return [
      OrderStatusStep(
        label: 'Order Processing',
        svgAsset: AppAssets.order_processing,
        activeColor: Colors.grey,
      ),
      OrderStatusStep(
        label: 'Ready For Dispatch',
        svgAsset: AppAssets.order_dispatch,
        activeColor: Colors.blue,
      ),
      OrderStatusStep(
        label: 'Shipped',
        svgAsset: AppAssets.order_shipped,
        activeColor: Colors.orange,
      ),
      OrderStatusStep(
        label: 'Delivered',
        svgAsset: AppAssets.order_delivered,
        activeColor: Colors.green,
      ),
    ];
  }


  int getCurrentStep(String? orderStatus, String? fulfillmentStatus) {
    if (orderStatus == 'canceled') return 1;

    return switch (fulfillmentStatus) {
      'not_fulfilled' => 0,
      'fulfilled'     => 1,
      'shipped'       => 2,
      'delivered'     => 3,
      _               => 0,
    };
  }

}
