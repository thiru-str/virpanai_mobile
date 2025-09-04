import 'package:flutter/material.dart';
import 'package:waioz/model/order_history_reponse.dart';
import 'package:waioz/ui/transaction_detail_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import 'widgets/cart_calculation.dart';
import 'widgets/common_header_app_bar.dart';
import 'widgets/order_detail_item_card.dart';

class OrderDetailItemPage extends StatefulWidget {

  final Order? selectedOrder;

  const OrderDetailItemPage({super.key, this.selectedOrder});

  @override
  State<OrderDetailItemPage> createState() => _OrderDetailItemPageState();
}

class _OrderDetailItemPageState extends State<OrderDetailItemPage> {

  String paymentType = "Unknown"; // Default value

  @override
  void initState() {
    // TODO: implement initState
    Map<String, String> paymentTypeMap = {
      "pp_system_default": "COD",
      "pp_stripe_stripe": "Stripe",
      "pp_razorpay_razorpay": "Razorpay",
      "pp_neft_neft": "NEFT",
    };
    String? paymentId = widget.selectedOrder?.paymentCollections?.first.payments?.first.providerId;
    print(paymentId);
    setState(() {
      paymentType = paymentTypeMap[paymentId] ?? "Unknown";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.orders,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: SingleChildScrollView(  // Wrap the body with SingleChildScrollView for scrolling
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(  // Use a Column to arrange the widgets vertically
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrdersList(),
            _buildSectionTitle('Billing details'),
            const SizedBox(height: 10),// List of order items
            Container(
              padding: const EdgeInsets.all(0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  CartPaymentMethodWidget(
                    paymentMethod: paymentType, // Or any other payment method
                    onTap: () {
                      PageRouteUtils.pushWithSlide(context, TransactionDetailsScreen(orderID: widget.selectedOrder?.id ?? "",));
                    },
                  ),
                  SizedBox(height: 10,),
                  CartCalculation(
                    keyText: '${AppStrings.subTotal}:',
                    valueText: CurrencyUtil.appendCurrency((widget.selectedOrder?.subtotal ?? 0).toString()),
                  ),
                  CartCalculation(
                    keyText: '${AppStrings.tax}:',
                    valueText: CurrencyUtil.appendCurrency((widget.selectedOrder?.taxTotal ?? 0).toString()),
                  ),
                  CartCalculation(
                    keyText: '${AppStrings.total}:',
                    valueText: CurrencyUtil.appendCurrency((widget.selectedOrder?.total ?? 0).toString())
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Shipping details'),
            const SizedBox(height: 20),// List of order items
            _buildShippingDetailsCard(),  // Shipping details card
          ],
        ),
      ),
    );
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

  // Method to build the list of orders
  Widget _buildOrdersList() {
    return ListView.builder(
      shrinkWrap: true,  // Prevent the list from taking up unnecessary space
      physics: NeverScrollableScrollPhysics(),  // Disable scrolling for the list within SingleChildScrollView
      itemCount: widget.selectedOrder?.items?.length ??0,  // Define the number of items you want to show
      itemBuilder: (context, index) {
        final itemDetail = widget.selectedOrder?.items?[index];
        return OrderDetailItemCard(
          imageUrl: itemDetail?.thumbnail ?? "",
          size: itemDetail?.variantTitle ?? "",
          productName: (itemDetail?.quantity ?? "").toString() + " x " + (itemDetail?.productTitle ?? ""),
          color: '',  // Product color
          price: CurrencyUtil.appendCurrency(itemDetail?.total.toString() ?? "0"),
        );
      },
    );
  }

  Widget _buildShippingDetailsCard() {
    return Container(
        padding: EdgeInsets.all(20),
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
              '${widget.selectedOrder?.cart?.shippingAddress?.address1}, '
                  '${widget.selectedOrder?.cart?.shippingAddress?.city},'
                  '${widget.selectedOrder?.cart?.shippingAddress?.postalCode}, '
                  '${widget.selectedOrder?.cart?.shippingAddress?.province ?? ''}',
            ),
            SizedBox(height: 8),
            Text('${widget.selectedOrder?.cart?.shippingAddress?.phone}'),
          ],
        ));
  }
}
