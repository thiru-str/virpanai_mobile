import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

class CheckoutFooter extends StatelessWidget {
  final String svgPath;
  final String paymentMethod;
  final VoidCallback onPaymentTap;
  final VoidCallback onInfoTap;
  final String amount;
  final VoidCallback onPlaceOrder;
  final bool isLoading;

  const CheckoutFooter({
    Key? key,
    required this.svgPath,
    required this.paymentMethod,
    required this.onPaymentTap,
    required this.onInfoTap,
    required this.amount,
    required this.onPlaceOrder,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onPaymentTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      svgPath,
                      colorFilter:
                          ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                      height: 24,
                      width: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Pay Using",
                              style: UiTypography.cardMeta(color: Colors.black54)
                                  .copyWith(fontSize: 10),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              paymentMethod,
                              style: UiTypography.cardAction(
                                color: Colors.black,
                              ).copyWith(fontSize: 12),
                            ),
                            const SizedBox(width: 2),
                            GestureDetector(
                              onTap: onInfoTap,
                              child: const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onPlaceOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey("loader"),
                        height: 32,
                        child: Center(
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        "$amount\nPlace Order",
                        key: const ValueKey("text"),
                        textAlign: TextAlign.center,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ).copyWith(height: 1.3),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
