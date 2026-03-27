import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';
import '../../../../utility/app_theme.dart';
import '../../../../utility/currency_util.dart';

/// CheckoutCta1 - Sticky checkout button with total.
/// Extracted from cart_page.dart checkout footer
class CheckoutCta1Widget extends StatelessWidget {
  final String? totalAmount;
  final bool isLoading;
  final VoidCallback onCheckout;
  final VoidCallback? onContinueShopping;
  final BlockConfig config;

  const CheckoutCta1Widget({
    super.key,
    required this.onCheckout,
    required this.isLoading,
    required this.config,
    this.totalAmount,
    this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    final ctaText = config.getString('cta_text', defaultValue: 'Proceed to Checkout');
    final showTotal = config.getBool('show_total_in_cta', defaultValue: true);
    final continueText = config.getString('continue_shopping_text', defaultValue: 'Continue Shopping');

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : onCheckout,
                style: AppTheme.primaryButtonStyle.copyWith(
                  minimumSize: const WidgetStatePropertyAll(Size(0, 50)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (showTotal && totalAmount != null)
                            Text(
                              CurrencyUtil.appendCurrency(totalAmount!),
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          Text(
                            ctaText,
                            style: FontUtils.primaryFontStyle(
                              fontSize: showTotal ? 11 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (continueText.isNotEmpty && onContinueShopping != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onContinueShopping,
                child: Text(
                  continueText,
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
