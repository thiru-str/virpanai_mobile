import 'package:flutter/material.dart';
import 'package:waioz/ui/order_detail_item_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'widgets/common_header_app_bar.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.orders,
        onBackTap: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTile(AppStrings.delivered, false, '28 May'),
            _buildStatusTile(AppStrings.shipped, true, '28 May'),
            _buildStatusTile(AppStrings.order_confirmed, true, '28 May'),
            _buildStatusTile(AppStrings.order_placed, true, '28 May'),
            const SizedBox(height: 20),
            _buildSectionTitle(AppStrings.order_items),
            const SizedBox(height: 15),
            _buildOrderItemTile(),
            const SizedBox(height: 20),
            _buildSectionTitle(AppStrings.shipping_details),
            const SizedBox(height: 20),
            _buildShippingDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTile(String status, bool isCompleted, String date) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color:
          isCompleted ? AppColors.primary : AppColors.primary.withAlpha(50),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: isCompleted ? AppColors.secondary : Colors.grey[500],
          size: 12.0,
        ),
      ),
      title: Text(
        status,
        style: FontUtils.circularStdStyle(fontSize: 17),
      ),
      trailing: Text(
        date,
        style: FontUtils.circularStdStyle(fontSize: 17),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: FontUtils.circularStdStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Order Item Tile
  Widget _buildOrderItemTile() {
    return Container(
      padding: EdgeInsets.only(left: 8, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary, // Background color
        borderRadius:
        BorderRadius.circular(8), // Border radius for rounded corners
      ),
      child: ListTile(
        leading: Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
        title: Text(
          AppStrings.four_items,
          style: FontUtils.circularStdStyle(fontSize: 16.0),
        ),
        trailing: Row(
          mainAxisSize:
          MainAxisSize.min, // Ensure only the trailing part takes up space
          children: [
            TextButton(
              onPressed: () {
                PageRouteUtils.pushWithSlide(context, OrderDetailItemPage());
              },
              child: Text(AppStrings.view_all,
                  style: FontUtils.circularStdStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Shipping Details Card
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
            Text('2715 Ash Dr. San Jose, South Dakota 83475'),
            SizedBox(height: 8),
            Text('121-224-7890'),
          ],
        ));
  }
}
