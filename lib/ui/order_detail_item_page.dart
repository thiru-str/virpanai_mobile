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
import 'package:waioz/utility/app_utils.dart';
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
      return double.tryParse(
              meta['wallet_split']['wallet_amount']?.toString() ?? '0') ??
          0;
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
    "pp_paytm_paytm": "Paytm",
    "pp_wallet_wallet": "Wallet",
  };
  bool apiLoading = true;
  int _currentTab = 0;
  List<ReturnReason>? returnReasons;
  final Map<String, double> _reviewedProductRatings = <String, double>{};
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
      final reviewedProductRatings =
          await _fetchCustomerReviewRatings(apiService, response.data);
      if (!mounted) return;
      setState(() {
        order = response.data;
        _reviewedProductRatings
          ..clear()
          ..addAll(reviewedProductRatings);
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

  Future<Map<String, double>> _fetchCustomerReviewRatings(
    ApiService apiService,
    Data? orderData,
  ) async {
    final productIds = (orderData?.items ?? [])
        .where(_isDeliveredItem)
        .map((item) => item.productId ?? '')
        .where((productId) => productId.isNotEmpty)
        .toSet();

    final ratings = <String, double>{};
    await Future.wait(productIds.map((productId) async {
      try {
        final reviewResponse =
            await apiService.getProductReviews(context, productId);
        final customerReview = reviewResponse.data?.customerReview;
        final reviewId = customerReview?.id ?? '';
        final rating = double.tryParse(customerReview?.rating ?? '');
        if (reviewId.isNotEmpty && rating != null) {
          ratings[productId] = rating;
        }
      } catch (e) {
        debugPrint('review rating load error: $e');
      }
    }));

    return ratings;
  }

  bool _isDeliveredItem(Item item) {
    final status = (item.status ?? '').trim().toLowerCase();
    return status == 'delivered' || (item.detail?.deliveredQuantity ?? 0) > 0;
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
                                valueText: CurrencyUtil.appendCurrency(((order
                                                ?.prices?.itemSubtotal ??
                                            0) -
                                        ((order?.items ?? [])
                                            .where((item) => item.isPlatformFee)
                                            .fold<num>(
                                                0,
                                                (sum, item) =>
                                                    sum +
                                                    ((item.unitPrice ?? 0) *
                                                        (item.quantity ?? 0)))))
                                    .toString()),
                              ),
                            ),
                            if ((order?.prices?.discountTotal ?? 0) > 0)
                              CartCalculation(
                                keyText: order?.couponCode != null
                                    ? 'Coupon (${order!.couponCode}):'
                                    : 'Coupon Discount:',
                                valueText:
                                    '- ${CurrencyUtil.appendCurrency((order?.prices?.discountTotal ?? 0).toStringAsFixed(2))}',
                                valueStyle: TextStyle(
                                    fontSize: 16, color: Colors.green.shade700),
                              ),
                            if ((order?.prices?.physicalDiscountTotal ?? 0) > 0)
                              CartCalculation(
                                keyText: 'Physical Discount:',
                                valueText:
                                    '- ${CurrencyUtil.appendCurrency((order?.prices?.physicalDiscountTotal ?? 0).toStringAsFixed(2))}',
                                valueStyle: TextStyle(
                                    fontSize: 16, color: Colors.green.shade700),
                              ),
                            Visibility(
                              visible: (order?.prices?.shippingTotal ?? 0) > 0,
                              child: CartCalculation(
                                keyText: '${AppStrings.shipping}:',
                                valueText: CurrencyUtil.appendCurrency(
                                    (order?.prices?.shippingTotal ?? 0)
                                        .toString()),
                              ),
                            ),
                            if ((order?.items ?? [])
                                    .any((item) => item.isPlatformFee) &&
                                (order!.items!
                                        .where((item) => item.isPlatformFee)
                                        .fold<num>(
                                            0,
                                            (sum, item) =>
                                                sum +
                                                ((item.unitPrice ?? 0) *
                                                    (item.quantity ?? 0)))) >
                                    0)
                              CartCalculation(
                                keyText: '${AppStrings.platform_fee}:',
                                valueText: CurrencyUtil.appendCurrency(
                                    ((order?.items ?? [])
                                            .where((item) => item.isPlatformFee)
                                            .fold<num>(
                                                0,
                                                (sum, item) =>
                                                    sum +
                                                    ((item.unitPrice ?? 0) *
                                                        (item.quantity ?? 0))))
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
                                keyText:
                                    'Loyalty ($_loyaltyPointsApplied pts):',
                                valueText:
                                    '- ${CurrencyUtil.appendCurrency(_loyaltyDiscount.toStringAsFixed(2))}',
                                keyStyle: TextStyle(
                                    fontSize: 16, color: AppColors.primary),
                                valueStyle: TextStyle(
                                    fontSize: 16, color: AppColors.primary),
                              ),
                            if (_walletAmount > 0)
                              CartCalculation(
                                keyText: 'Wallet:',
                                valueText:
                                    '- ${CurrencyUtil.appendCurrency(_walletAmount.toStringAsFixed(2))}',
                                keyStyle: TextStyle(
                                    fontSize: 16, color: Colors.green.shade700),
                                valueStyle: TextStyle(
                                    fontSize: 16, color: Colors.green.shade700),
                              ),
                            Visibility(
                              visible: (order?.prices?.total ?? 0) > 0,
                              child: CartCalculation(
                                  keyText: '${AppStrings.total}:',
                                  valueText: CurrencyUtil.appendCurrency(
                                      (((order?.prices?.total ?? 0) -
                                                  _walletAmount -
                                                  _loyaltyDiscount)
                                              .clamp(0, double.infinity))
                                          .toStringAsFixed(2))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if ((order?.prices?.itemSubtotal ??
                              order?.prices?.total ??
                              0) >
                          0)
                        OrderLoyaltyBadge(
                          orderTotal: (order!.prices!.itemSubtotal ??
                                  order!.prices!.total!) -
                              _loyaltyDiscount,
                          orderStatus: order?.status ?? '',
                          paymentStatus: order?.paymentStatus ?? '',
                          orderId: order?.id,
                        ),
                      _buildSectionTitle(AppStrings.shipping_details),
                      const SizedBox(height: 12), // List of order items
                      _buildShippingDetailsCard(), // Shipping details card
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
    final List<Item> allItems =
        (order?.items ?? []).where((item) => !item.isPlatformFee).toList();

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
            final isDelivered = _isDeliveredItem(itemDetail);
            return Padding(
              padding: EdgeInsets.only(
                bottom: (index == visibleItems.length - 1) ? 0 : 16.0,
              ),
              child: OrderDetailItemCard(
                showReturnButton: itemDetail.isReturnable ?? false,
                showRating: isDelivered,
                initialRating:
                    _reviewedProductRatings[itemDetail.productId] ?? 0,
                ratingReadOnly:
                    _reviewedProductRatings.containsKey(itemDetail.productId),
                ratingLabel:
                    _reviewedProductRatings.containsKey(itemDetail.productId)
                        ? 'You rated this product'
                        : 'Please rate the product',
                imageUrl: itemDetail.thumbnail ?? '',
                variant: _buildOrderItemVariant(itemDetail),
                productName:
                    '${itemDetail.quantity ?? ''} x ${itemDetail.productTitle ?? ''}',
                status: itemDetail.status ?? '',
                price: CurrencyUtil.appendCurrency(
                  ((itemDetail.unitPrice ?? 0) * (itemDetail.quantity ?? 0))
                      .toString(),
                ),
                onRatingTap: () => _showReviewBottomSheet(itemDetail),
                onRatingChanged: (rating) => _showReviewBottomSheet(
                  itemDetail,
                  initialRating: rating,
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

  String _buildOrderItemVariant(Item item) {
    final variantTitle = item.variantTitle ?? '';
    final metadata = item.metadata;

    if (metadata?.unitBasedInventory == true &&
        metadata?.unitQuantity != null &&
        metadata!.unitQuantity! > 0) {
      final unit = (metadata.displayUnit ?? metadata.unitType ?? '')
          .trim()
          .toLowerCase();
      final value = metadata.unitQuantity!;
      late final String formattedUnit;

      if (unit == 'kg') {
        formattedUnit = value % 1000 == 0
            ? '${value ~/ 1000} kg'
            : '${(value / 1000).toStringAsFixed(value % 100 == 0 ? 1 : 2)} kg';
      } else if (unit == 'g' || unit == 'gram' || unit == 'grams') {
        formattedUnit = '$value g';
      } else if (unit == 'ml') {
        formattedUnit = '$value ml';
      } else if (unit == 'l' ||
          unit == 'ltr' ||
          unit == 'litre' ||
          unit == 'liter') {
        formattedUnit = value % 1000 == 0
            ? '${value ~/ 1000} L'
            : '${(value / 1000).toStringAsFixed(value % 100 == 0 ? 1 : 2)} L';
      } else {
        formattedUnit = '$value${unit.isNotEmpty ? ' $unit' : ''}';
      }

      if (variantTitle.isEmpty || variantTitle == 'Default variant') {
        return formattedUnit;
      }

      return '$variantTitle • $formattedUnit';
    }

    if (variantTitle == 'Default variant') {
      return '';
    }

    return variantTitle;
  }

  Future<void> _showReviewBottomSheet(
    Item itemDetail, {
    double initialRating = 0,
  }) async {
    final productId = itemDetail.productId ?? '';
    if (productId.isEmpty) {
      AppUtils.showToast('Product details are missing. Please try again.');
      return;
    }
    if (_reviewedProductRatings.containsKey(productId)) {
      AppUtils.showToast('You have already reviewed this product.');
      return;
    }

    try {
      final reviewResponse =
          await ApiService().getProductReviews(context, productId);
      final customerReviewId = reviewResponse.data?.customerReview?.id ?? '';
      if (customerReviewId.isNotEmpty) {
        final rating =
            double.tryParse(reviewResponse.data?.customerReview?.rating ?? '');
        if (rating != null) {
          _reviewedProductRatings[productId] = rating;
        }
        AppUtils.showToast('You have already reviewed this product.');
        return;
      }
    } catch (e) {
      debugPrint('review status check error: $e');
    }

    final reviewController = TextEditingController();
    double selectedRating = initialRating;
    bool isSubmitting = false;

    final successMessage = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6D8DF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Add review',
                          textAlign: TextAlign.center,
                          style: UiTypography.cardTitle().copyWith(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          itemDetail.productTitle ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: UiTypography.cardSubtitle(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            final isSelected = selectedRating >= starValue;
                            return IconButton(
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              onPressed: () {
                                setModalState(() {
                                  selectedRating = starValue.toDouble();
                                });
                              },
                              icon: Icon(
                                Icons.star,
                                size: 40,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: reviewController,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: AppStrings.write_your_review,
                            filled: true,
                            fillColor: const Color(0xFFF9F9FB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EC)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EC)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (selectedRating < 1) {
                                    AppUtils.showToast(
                                      'Provide rating to continue',
                                    );
                                    return;
                                  }

                                  FocusScope.of(sheetContext).unfocus();
                                  setModalState(() {
                                    isSubmitting = true;
                                  });

                                  var shouldCloseSheet = false;
                                  try {
                                    final response =
                                        await ApiService().postProductReview(
                                      this.context,
                                      productId,
                                      selectedRating.toInt().toString(),
                                      reviewController.text.trim(),
                                    );
                                    shouldCloseSheet = true;
                                    if (sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop(
                                        response.message?.isNotEmpty == true
                                            ? response.message!
                                            : AppStrings.review_submitted,
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint('review submit error: $e');
                                  } finally {
                                    if (!shouldCloseSheet &&
                                        sheetContext.mounted) {
                                      setModalState(() {
                                        isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  AppStrings.submit_review,
                                  style: UiTypography.cardAction(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (successMessage != null && mounted) {
      _reviewedProductRatings[productId] = selectedRating;
      AppUtils.showToast(successMessage);
    }
  }

  Widget _buildShippingDetailsCard() {
    return Container(
        padding: const EdgeInsets.all(18),
        width: double.infinity, // Full width
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.location_on_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order?.shippingAddress?.address1}, '
                    '${order?.shippingAddress?.city}, '
                    '${order?.shippingAddress?.postalCode}, '
                    '${order?.shippingAddress?.province ?? ''}.',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 14,
                      color: AppColors.textColor,
                    ).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${order?.shippingAddress?.phone ?? ''}',
                    style: UiTypography.cardMeta(color: AppColors.textColor50),
                  ),
                ],
              ),
            ),
          ],
        ));
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
