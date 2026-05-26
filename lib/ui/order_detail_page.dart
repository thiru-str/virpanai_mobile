import 'package:flutter/material.dart';
import 'package:waioz/ui/order_detail_item_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';
import 'widgets/common_header_app_bar.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  static const Color _kScaffoldBg = Color(0xFFF9F9FB);

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kScaffoldBg,
      appBar: CommonHeaderAppBar(
        title: AppStrings.orders,
        onBackTap: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Order Status'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: _cardDecoration,
              child: Column(
                children: [
                  _buildStatusTile('Delivered', false, '28 May', isLast: false),
                  _buildStatusTile('Shipped', true, '28 May', isLast: false),
                  _buildStatusTile('Order Confirmed', true, '28 May',
                      isLast: false),
                  _buildStatusTile('Order Placed', true, '28 May',
                      isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Order Items'),
            const SizedBox(height: 12),
            _buildOrderItemTile(),
            const SizedBox(height: 24),
            _buildSectionTitle('Shipping details'),
            const SizedBox(height: 12),
            _buildShippingDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTile(String status, bool isCompleted, String date,
      {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline marker + connector
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: isCompleted ? Colors.white : Colors.grey.shade400,
                  size: 12.0,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE5E7EC),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status,
                    style: UiTypography.cardTitle().copyWith(
                      fontSize: 16,
                      color: isCompleted
                          ? AppColors.textColor
                          : AppColors.textColor50,
                    ),
                  ),
                  Text(
                    date,
                    style: UiTypography.cardMeta(color: AppColors.textColor50),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  // Order Item Tile
  Widget _buildOrderItemTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              AppStrings.four_items,
              style: UiTypography.cardTitle().copyWith(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              PageRouteUtils.pushWithSlide(context, OrderDetailItemPage());
            },
            child: Text(
              AppStrings.view_all,
              style: UiTypography.cardAction(color: AppColors.primary)
                  .copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Shipping Details Card
  Widget _buildShippingDetailsCard() {
    return Container(
        padding: const EdgeInsets.all(18),
        width: double.infinity, // Full width
        decoration: _cardDecoration,
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
                    '2715 Ash Dr. San Jose, South Dakota 83475',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 14,
                      color: AppColors.textColor,
                    ).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '121-224-7890',
                    style: UiTypography.cardMeta(color: AppColors.textColor50),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
