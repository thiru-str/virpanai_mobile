import 'package:flutter/material.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

import '../utility/app_assets.dart';
import '../utility/page_route_utils.dart';

class OrderPlacedPage extends StatelessWidget {
  const OrderPlacedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image/Illustration
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                height: 500,
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
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Order Placed Title
                    const SizedBox(height: 40,),
                     Text(
                      "Order Placed \n Successfully",
                      style:FontUtils.circularStdStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),

                    // Subtext
                    Text(
                      "You will receive an email confirmation",
                      style: FontUtils.circularStdStyle(
                        fontSize: 16,
                        color: AppColors.textColor50,
                        fontWeight: FontWeight.w400
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
                          "See More Products",
                          style: FontUtils.circularStdStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    );
  }
}
