import 'package:flutter/material.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/order_detail_item_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../utility/app_assets.dart';
import '../utility/page_route_utils.dart';

class OrderPlacedPage extends StatelessWidget {
  String? orderId;
  OrderPlacedPage({super.key,required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image/Illustration
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4, // Adjust image height
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.place_order), // Replace with your image asset
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // White Container with Rounded Corners
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.5, // Ensure this container fills the space
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Order Placed Title
                  const SizedBox(height: 40),
                  Text(
                    AppStrings.order_placed_success,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 28, // Adjusted font size for responsiveness
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // Subtext
                  Text(
                    AppStrings.email_confirmation,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14, // Adjusted font size
                      color: AppColors.textColor50,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle button tap
                        PageRouteUtils.pushAndRemoveUntil(context, const BottomNavPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: Text(
                        AppStrings.see_more_product,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle button tap
                        PageRouteUtils.pushAndRemoveUntil(context, OrderDetailItemPage(orderId: orderId,));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: Text(
                        'View details',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );


  }
}
