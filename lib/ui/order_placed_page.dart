import 'package:flutter/material.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/order_detail_item_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../utility/page_route_utils.dart';

class OrderPlacedPage extends StatelessWidget {
  String? orderId;
  OrderPlacedPage({super.key, required this.orderId});

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
          PageRouteUtils.pushAndRemoveUntil(context, BottomNavPage());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      // Celebratory success check
                      Center(
                        child: Container(
                          height: 104,
                          width: 104,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F7F0),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              height: 72,
                              width: 72,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1FA971),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        AppStrings.order_placed_success.replaceAll('\n', ' '),
                        textAlign: TextAlign.center,
                        style: UiTypography.cardTitle().copyWith(
                          fontSize: 22,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtext
                      Text(
                        AppStrings.email_confirmation,
                        textAlign: TextAlign.center,
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 14,
                          color: AppColors.textColor50,
                          fontWeight: FontWeight.w400,
                        ).copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Order summary card
                      Container(
                        padding: const EdgeInsets.all(18),
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
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your order is confirmed',
                              textAlign: TextAlign.center,
                              style: UiTypography.cardTitle().copyWith(
                                fontSize: 16,
                                height: 1.25,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'We\'ll keep you updated on the delivery status. You can track it anytime from your orders.',
                              textAlign: TextAlign.center,
                              style: UiTypography.cardSubtitle().copyWith(
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sticky bottom actions
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primary CTA — View details
                    ElevatedButton.icon(
                      onPressed: () {
                        PageRouteUtils.pushAndRemoveUntil(
                          context,
                          OrderDetailItemPage(orderId: orderId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        'View details',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Secondary CTA — Continue shopping
                    OutlinedButton(
                      onPressed: () {
                        PageRouteUtils.pushAndRemoveUntil(
                            context, const BottomNavPage());
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppStrings.see_more_product,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
