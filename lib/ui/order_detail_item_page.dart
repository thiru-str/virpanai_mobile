import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/model/order_detail_response.dart';
import 'package:waioz/model/order_history_reponse.dart'
    as legacy_order_models;
import 'package:waioz/ui/transaction_detail_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/order_status_widget.dart';
import 'package:waioz/ui/widgets/profile_item_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../utility/shared_preferences_util.dart';
import 'bottom_nav_page.dart';
import 'widgets/cart_calculation.dart';
import 'widgets/common_header_app_bar.dart';
import 'widgets/order_detail_item_card.dart';
import 'widgets/order_loyalty_badge.dart';

class OrderDetailItemPage extends StatefulWidget {
  final String? orderId;

  const OrderDetailItemPage({super.key, this.orderId});

  @override
  State<OrderDetailItemPage> createState() => _OrderDetailItemPageState();
}

class _OrderDetailItemPageState extends State<OrderDetailItemPage> {
  String paymentType = "Unknown"; // Default value
  Data? order;
  legacy_order_models.Order? legacyOrder;

  double get _walletAmount {
    final meta = order?.metadata;
    if (meta is Map && meta['wallet_split'] is Map) {
      return double.tryParse(meta['wallet_split']['wallet_amount']?.toString() ?? '0') ?? 0;
    }
    return 0;
  }

  num get _loyaltyDiscount {
    final meta = order?.metadata;
    if (meta is Map && meta['loyalty_checkout_apply'] is Map) {
      final apply = meta['loyalty_checkout_apply'];
      final amt = apply['discount_amount'];
      final pts = apply['points_to_apply'] ?? apply['points_applied'];
      if (amt != null && pts != null && (pts as num) > 0) return amt as num;
    }
    return 0;
  }

  int get _loyaltyPointsApplied {
    final meta = order?.metadata;
    if (meta is Map && meta['loyalty_checkout_apply'] is Map) {
      final apply = meta['loyalty_checkout_apply'];
      final pts = apply['points_to_apply'] ?? apply['points_applied'];
      if (pts != null && (pts as num) > 0) return pts.toInt();
    }
    return 0;
  }
  Map<String, String> paymentTypeMap = {
    "pp_system_default": "COD",
    "pp_stripe_stripe": "Stripe",
    "pp_razorpay_razorpay": "Razorpay",
    "pp_neft_neft": "NEFT",
    "pp_payu_payu": "PayU",
    "pp_wallet_wallet": "Wallet",
  };
  bool apiLoading = true;
  String invoiceUrl = "";
  String token = "";

  @override
  void initState() {
    super.initState();
    initializePages();
  }

  Future<void> initializePages() async {
    getOrderHistoryAPI();
    invoiceUrl = (await SharedPreferencesUtil().getString('invoice_url')) ?? '';
    token = (await SharedPreferencesUtil().getString('token')) ?? '';
  }

  void getOrderHistoryAPI() async {
    try {
      final ApiService apiService = ApiService();
      final response =
          await apiService.getOrderDetails(context, widget.orderId ?? '');
      legacy_order_models.Order? legacy;
      try {
        final legacyResponse = await apiService.getIndividualOrderHistory(
          context,
          widget.orderId ?? '',
        );
        legacy = legacyResponse.order;
      } catch (_) {}

      final paymentId = response.data?.paymentMethod ??
          legacy?.paymentCollections?.firstOrNull?.payments?.firstOrNull
              ?.providerId ??
          '';

      setState(() {
        order = response.data;
        legacyOrder = legacy;
        debugPrint('order details called');
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
    return PopScope(
        canPop: false, // Disable default back button
        onPopInvoked: (didPop) async {
          if (didPop) return;
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context); // Normal back navigation
          } else {
            // Redirect to home when no backstack exists
            PageRouteUtils.pushAndRemoveUntil(context, const BottomNavPage());
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
                PageRouteUtils.pushAndRemoveUntil(
                    context, const BottomNavPage());
              }
            },
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.linearGradient),
            child: apiLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : SingleChildScrollView(
                  // Wrap the body with SingleChildScrollView for scrolling
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    // Use a Column to arrange the widgets vertically
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: OrderStatusWidget(
                          currentStep: getCurrentStep(
                            legacyOrder?.status ?? order?.status,
                            _fulfillmentStatus,
                          ),
                          steps: buildOrderSteps(
                            legacyOrder?.status ?? order?.status,
                            _fulfillmentStatus,
                          ),
                          isCanceled:
                              (legacyOrder?.status ?? order?.status) ==
                                  'canceled',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildOrdersList(),
                      const SizedBox(height: 10), // List of order items
                      _buildSectionTitle(AppStrings.billing_details),
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
                            if (_deliveryMethodName.isNotEmpty)
                              CartCalculation(
                                keyText: 'Delivery Method:',
                                valueText: _deliveryMethodName,
                                valueStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              visible: (order?.prices?.itemSubtotal ?? 0) > 0,
                              child: CartCalculation(
                                keyText: '${AppStrings.subTotal}:',
                                valueText: CurrencyUtil.appendCurrency(
                                    ((order?.prices?.itemSubtotal ?? 0) -
                                        ((order?.items ?? [])
                                            .where((item) => item.isPlatformFee)
                                            .fold<num>(0, (sum, item) => sum + ((item.unitPrice ?? 0) * (item.quantity ?? 0)))))
                                        .toString()),
                              ),
                            ),
                            if ((order?.prices?.discountTotal ?? 0) > 0)
                              CartCalculation(
                                keyText: order?.couponCode != null
                                    ? 'Coupon (${order!.couponCode}):'
                                    : 'Coupon Discount:',
                                valueText: '- ${CurrencyUtil.appendCurrency((order?.prices?.discountTotal ?? 0).toStringAsFixed(2))}',
                                valueStyle: TextStyle(fontSize: 16, color: Colors.green.shade700),
                              ),
                            Visibility(
                              visible: (order?.prices?.shippingTotal ?? 0) > 0,
                              child: CartCalculation(
                                keyText: '${AppStrings.shipping}:',
                                valueText: CurrencyUtil.appendCurrency(
                                    (order?.prices?.shippingTotal ?? 0).toString()),
                              ),
                            ),
                            if ((order?.items ?? []).any((item) => item.isPlatformFee) &&
                                (order!.items!.where((item) => item.isPlatformFee).fold<num>(0, (sum, item) => sum + ((item.unitPrice ?? 0) * (item.quantity ?? 0)))) > 0)
                              CartCalculation(
                                keyText: '${AppStrings.platform_fee}:',
                                valueText: CurrencyUtil.appendCurrency(
                                    ((order?.items ?? [])
                                        .where((item) => item.isPlatformFee)
                                        .fold<num>(0, (sum, item) => sum + ((item.unitPrice ?? 0) * (item.quantity ?? 0))))
                                        .toString()),
                              ),
                            Visibility(
                              visible: (order?.prices?.taxTotal ?? 0) > 0,
                              child: CartCalculation(
                                keyText: '${AppStrings.tax}:',
                                valueText: CurrencyUtil.appendCurrency(
                                    (order?.prices?.taxTotal ?? 0).toString()),
                              ),
                            ),
                            if (_loyaltyDiscount > 0)
                              CartCalculation(
                                keyText: 'Loyalty ($_loyaltyPointsApplied pts):',
                                valueText: '- ${CurrencyUtil.appendCurrency(_loyaltyDiscount.toStringAsFixed(2))}',
                                keyStyle: TextStyle(fontSize: 16, color: AppColors.primary),
                                valueStyle: TextStyle(fontSize: 16, color: AppColors.primary),
                              ),
                            if (_walletAmount > 0)
                              CartCalculation(
                                keyText: 'Wallet:',
                                valueText: '- ${CurrencyUtil.appendCurrency(_walletAmount.toStringAsFixed(2))}',
                                keyStyle: TextStyle(fontSize: 16, color: Colors.green.shade700),
                                valueStyle: TextStyle(fontSize: 16, color: Colors.green.shade700),
                              ),
                            Visibility(
                              visible: (order?.prices?.total ?? 0) > 0,
                              child: CartCalculation(
                                  keyText: '${AppStrings.total}:',
                                  valueText: CurrencyUtil.appendCurrency(
                                      (((order?.prices?.total ?? 0) - _walletAmount - _loyaltyDiscount).clamp(0, double.infinity)).toStringAsFixed(2))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if ((order?.prices?.itemSubtotal ?? order?.prices?.total ?? 0) > 0)
                        OrderLoyaltyBadge(
                          orderTotal: (order!.prices!.itemSubtotal ?? order!.prices!.total!) - _loyaltyDiscount,
                          orderStatus: order?.status ?? '',
                          paymentStatus: order?.paymentStatus ?? '',
                          orderId: order?.id,
                        ),
                      _buildSectionTitle(AppStrings.shipping_details),
                      const SizedBox(height: 20), // List of order items
                      _buildShippingDetailsCard(), // Shipping details card
                      const SizedBox(height: 20),
                      Visibility(
                        visible: (order?.paymentStatus ?? '') == 'pending',
                        child: GestureDetector(
                          onTap: () {
                            _showCancellation(context, order?.id ?? '');
                          },
                          child: Text(
                            AppStrings.cancel_order,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _fulfillmentStatus == 'delivered',
                        child: ProfileItemWidget(
                          title: AppStrings.download_invoice,
                          onTap: () {
                            _launchURL(
                                '$invoiceUrl/${order?.id ?? ''}?token=${token}&isdownload=true');
                          },
                        ),
                      )
                    ],
                  ),
                ),
        )));
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens in external browser
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: FontUtils.primaryFontStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showCancellation(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonAlertDialog(
          title: AppStrings.cancel_order,
          content: AppStrings.cancel_order_confirmation,
          contentOk: AppStrings.yes,
          contentCancel: AppStrings.no,
          onTapOk: () async {
            try {
              Navigator.pop(context);
              setState(() {
                apiLoading = true;
              });
              final response = await ApiService().cancelOrder(context, orderId);
              debugPrint('order status ${response.status ?? false}');
              if (response.status ?? false) {
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

  Widget _buildOrdersList() {
    final List<Item> visibleItems =
        (order?.items ?? []).where((item) => !item.isPlatformFee).toList();

    if (visibleItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            AppStrings.no_items_found,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleItems.length,
      itemBuilder: (context, index) {
        final itemDetail = visibleItems[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: (index == visibleItems.length - 1) ? 0 : 16.0,
          ),
          child: OrderDetailItemCard(
            showRating: itemDetail.status == 'delivered',
            imageUrl: itemDetail.thumbnail ?? '',
            variant: itemDetail.variantTitle ?? '',
            productName:
                '${itemDetail.quantity ?? ''} x ${itemDetail.productTitle ?? ''}',
            status: itemDetail.status ?? '',
            price: CurrencyUtil.appendCurrency(
              ((itemDetail.unitPrice ?? 0) * (itemDetail.quantity ?? 0))
                  .toString(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShippingDetailsCard() {
    final dynamic shippingAddress =
        order?.shippingAddress ?? legacyOrder?.cart?.shippingAddress;
    final shippingLines = [
      shippingAddress?.address1,
      shippingAddress?.city,
      shippingAddress?.postalCode,
      shippingAddress?.province,
    ].where((value) => value != null && value.isNotEmpty).join(', ');

    return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity, // Full width
        decoration: BoxDecoration(
          color: AppColors.secondary, // Background color
          borderRadius:
              BorderRadius.circular(8), // Border radius for rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shippingLines),
            const SizedBox(height: 8),
            Text('${shippingAddress?.phone ?? ''}'),
          ],
        ));
  }

  String get _fulfillmentStatus =>
      legacyOrder?.metadata?.fulfillmentStatus ??
      legacyOrder?.fulfillmentStatus ??
      order?.orderStatus ??
      '';

  String get _deliveryMethodName =>
      legacyOrder?.cart?.shippingAddress == null
          ? ''
          : (legacyOrder?.metadata?.type == 'pickup'
              ? 'Self Pickup'
              : (legacyOrder?.cart?.shippingAddress?.address1?.isNotEmpty ?? false)
                  ? 'Delivery'
                  : '');

  List<OrderStatusStep> buildOrderSteps(
      String? orderStatus, String? fulfillmentStatus) {
    if (orderStatus == 'canceled') {
      return [
        OrderStatusStep(
          label: AppStrings.processing,
          svgAsset: AppAssets.order_processing,
          activeColor: Colors.grey,
        ),
        OrderStatusStep(
          label: AppStrings.cancelled,
          svgAsset: AppAssets.order_canceled,
          activeColor: Colors.red,
        ),
      ];
    }

    return [
      OrderStatusStep(
        label: AppStrings.order_processing,
        svgAsset: AppAssets.order_processing,
        activeColor: Colors.grey,
      ),
      OrderStatusStep(
        label: AppStrings.ready_for_dispatch,
        svgAsset: AppAssets.order_dispatch,
        activeColor: Colors.blue,
      ),
      OrderStatusStep(
        label: AppStrings.shipped,
        svgAsset: AppAssets.order_shipped,
        activeColor: Colors.orange,
      ),
      OrderStatusStep(
        label: AppStrings.delivered,
        svgAsset: AppAssets.order_delivered,
        activeColor: Colors.green,
      ),
    ];
  }

  int getCurrentStep(String? orderStatus, String? fulfillmentStatus) {
    if (orderStatus == 'canceled') return 1;

    return switch (fulfillmentStatus) {
      'not_fulfilled' => 0,
      'fulfilled' => 1,
      'shipped' => 2,
      'delivered' => 3,
      _ => 0,
    };
  }
}
