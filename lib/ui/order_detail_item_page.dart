import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/model/order_detail_response.dart';
import 'package:waioz/model/return_response.dart';
import 'package:waioz/ui/transaction_detail_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/order_status_widget.dart';
import 'package:waioz/ui/widgets/order_tab_switcher.dart';
import 'package:waioz/ui/widgets/profile_item_widget.dart';
import 'package:waioz/ui/widgets/return_order_bottom_sheet.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

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

  double get _walletAmount {
    final meta = order?.metadata;
    if (meta is Map && meta['wallet_split'] is Map) {
      return double.tryParse(meta['wallet_split']['wallet_amount']?.toString() ?? '0') ?? 0;
    }
    return 0;
  }

  Map<String, dynamic>? get _fulfillmentMeta {
    final m = order?.metadata;
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }

  String get _fulfillmentType => _fulfillmentMeta?['fulfillment_type'] as String? ?? 'standard';

  String _friendlyDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    if (d.isAtSameMomentAs(today)) return 'Today';
    if (d.isAtSameMomentAs(tomorrow)) return 'Tomorrow';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
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
    "pp_paytm_paytm": "Paytm",
    "pp_wallet_wallet": "Wallet",
  };
  bool apiLoading = true;
  int _currentTab = 0;
  List<ReturnReason>? returnReasons;
  String invoiceUrl = "";
  String token = "";

  @override
  void initState() {
    super.initState();
    initReturn();
    initializePages();
  }

  Future<void> initializePages() async {
    getOrderHistoryAPI();
    invoiceUrl = (await SharedPreferencesUtil().getString('invoice_url')) ?? '';
    token = (await SharedPreferencesUtil().getString('token')) ?? '';
  }

  Future<void> initReturn() async {
    var response = await getReturnReasons();

    if (response?.isNotEmpty == true) {
      setState(() {
        returnReasons = response;
      });
    }
  }

  Future<List<ReturnReason>?> getReturnReasons() async {
    dynamic global = await SharedPreferencesUtil().getJson('return_reasons');
    if (global != null && global is List) {
      try {
        return global
            .map((e) => ReturnReason.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing return reasons: $e');
      }
    }
    return null;
  }

  void getOrderHistoryAPI() async {
    try {
      final ApiService apiService = ApiService();
      var response =
          await apiService.getOrderDetails(context, widget.orderId ?? '');
      setState(() {
        order = response.data;
        debugPrint('order details called');
        String? paymentId = order?.paymentMethod ?? '';
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
          backgroundColor: const Color(0xFFF9F9FB),
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
          body: apiLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : SingleChildScrollView(
                  // Wrap the body with SingleChildScrollView for scrolling
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    // Use a Column to arrange the widgets vertically
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrdersList(),
                      const SizedBox(height: 16), // List of order items
                      _buildSectionTitle(AppStrings.billing_details),
                      const SizedBox(height: 12), // List of order items
                      Container(
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
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
                      _buildSectionTitle('Delivery Details'),
                      const SizedBox(height: 20), // List of order items
                      _buildFulfillmentCard(), // Fulfillment details card
                      const SizedBox(height: 20),
                      Visibility(
                        visible: (order?.paymentStatus ?? '') == 'pending',
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showCancellation(context, order?.id ?? '');
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 54),
                            side: const BorderSide(
                                color: Color(0xFFE5484D), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFFE5484D), size: 20),
                          label: Text(
                            AppStrings.cancel_order,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 16,
                              color: const Color(0xFFE5484D),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (order?.paymentStatus ?? '') == 'delivered',
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
        ));
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
      style: UiTypography.cardTitle().copyWith(
        fontSize: 18,
        height: 1.25,
        letterSpacing: -0.2,
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
    final List<Item> allItems = (order?.items ?? []).where((item) => !item.isPlatformFee).toList();

    // Split items by status
    final List<Item> returnedItems = allItems
        .where((item) => (item.status ?? '').toLowerCase().contains('returned'))
        .toList();

    final List<Item> deliveredItems = allItems
        .where(
            (item) => !(item.status ?? '').toLowerCase().contains('returned'))
        .toList();

    final bool hasReturned = returnedItems.isNotEmpty;
    final bool hasDelivered = deliveredItems.isNotEmpty;

    final List<Item> visibleItems = !hasReturned
        ? deliveredItems
        : !hasDelivered
            ? returnedItems
            : (_currentTab == 0 ? deliveredItems : returnedItems);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDelivered && hasReturned) ...[
          OrderTabSwitcher(
            initialIndex: _currentTab,
            onTabChanged: (index) {
              setState(() => _currentTab = index);
            },
          ),
          const SizedBox(height: 16),
        ],
        ListView.builder(
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
                showReturnButton: itemDetail.isReturnable ?? false,
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
                onReturnTap: () async {
                  final response = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) {
                      return ReturnOrderBottomSheet(
                        orderId: widget.orderId ?? '',
                        cartId: order?.cartId ?? '',
                        orderItem: itemDetail,
                        reasons: returnReasons ?? [],
                      );
                    },
                  );
                  if (response == true) {
                    getOrderHistoryAPI();
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFulfillmentCard() {
    final type = _fulfillmentType;
    final meta = _fulfillmentMeta ?? {};

    final isPickup = type == 'pickup';
    final isScheduled = type == 'scheduled';

    final IconData icon = isPickup
        ? Icons.storefront_outlined
        : isScheduled
            ? Icons.event_available_rounded
            : Icons.local_shipping_outlined;

    final Color iconColor = isPickup
        ? Colors.orange.shade600
        : AppColors.primary;

    final String typeLabel = isPickup
        ? 'Self Pickup'
        : isScheduled
            ? 'Scheduled Delivery'
            : 'Standard Delivery';

    String? slotLine;
    if (isPickup) {
      final date = _friendlyDate(meta['pickup_date'] as String?);
      final slot = meta['pickup_any_time'] == true
          ? 'Any time'
          : meta['pickup_slot_label'] as String?;
      if (date.isNotEmpty || slot != null) {
        slotLine = [date, slot].where((s) => s != null && s.isNotEmpty).join('  ·  ');
      }
    } else if (isScheduled) {
      final date = _friendlyDate(meta['delivery_date'] as String?);
      final slot = meta['delivery_time_slot_label'] as String?;
      if (date.isNotEmpty || slot != null) {
        slotLine = [date, slot].where((s) => s != null && s.isNotEmpty).join('  ·  ');
      }
    }

    final pickupAddress = meta['pickup_address'] as String?;
    final hasShippingAddress = order?.shippingAddress?.address1 != null;

    // Build clean address string
    final String? addressText = isPickup
        ? (pickupAddress?.isNotEmpty == true ? pickupAddress : null)
        : order?.shippingAddress?.address1 != null
            ? [
                order!.shippingAddress!.address1,
                if ((order!.shippingAddress!.address2 ?? '').isNotEmpty)
                  order!.shippingAddress!.address2,
                order!.shippingAddress!.city,
                order!.shippingAddress!.postalCode,
              ].where((s) => s != null && s!.isNotEmpty).join(', ')
            : null;

    final String? phoneText = !isPickup &&
            (order?.shippingAddress?.phone ?? '').isNotEmpty
        ? order!.shippingAddress!.phone
        : null;

    final String? instructionsText = isScheduled &&
            (meta['delivery_instructions'] as String?)?.isNotEmpty == true
        ? meta['delivery_instructions'] as String
        : null;

    final bool hasBottom =
        addressText != null || phoneText != null || instructionsText != null;

    // Accent color — primary purple for all types (matches app language)
    const Color accent = Color(0xFF8E6CEF); // AppColors.primary

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header strip: type icon + label ──────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          color: accent.withValues(alpha: 0.05),
          child: Row(children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 8),
            Text(typeLabel,
                style: FontUtils.primaryFontStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
          ]),
        ),

        Divider(color: Colors.grey.shade100, height: 1),

        // ── Date · slot ───────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(14, 14, 14, hasBottom ? 0 : 14),
          child: slotLine != null && slotLine.isNotEmpty
              ? Text(slotLine,
                  style: FontUtils.primaryFontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor))
              : Text('Delivered as soon as possible',
                  style: FontUtils.primaryFontStyle(
                      fontSize: 13, color: Colors.grey.shade500)),
        ),

        // ── Address / instructions ────────────────────────────────
        if (hasBottom) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Divider(color: Colors.grey.shade100, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              if (instructionsText != null) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.notes_rounded, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 7),
                  Expanded(child: Text(instructionsText,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 12, color: Colors.grey.shade500))),
                ]),
                if (addressText != null) const SizedBox(height: 7),
              ],
              if (addressText != null)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(
                    isPickup ? Icons.location_on_outlined : Icons.home_outlined,
                    size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 7),
                  Expanded(child: Text(addressText,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 12, color: Colors.grey.shade500))),
                ]),
              if (phoneText != null) ...[
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.phone_outlined, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 7),
                  Text(phoneText,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ]),
              ],
            ]),
          ),
        ],

      ]),
    );
  }

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
