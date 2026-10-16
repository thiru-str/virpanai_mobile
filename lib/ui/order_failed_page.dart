import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/checkout_completion.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

/// Shown when checkout could not place the order: no order exists, and an
/// online payment has been refunded (or needed none). Wording matches the web
/// storefront's transaction-failed page.
class OrderFailedPage extends StatelessWidget {
  final CompletionFailure failure;

  const OrderFailedPage({super.key, required this.failure});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = failure.reason == 'out_of_stock' || failure.isOutOfStock;
    final refund = refundNotice(failure.refundStatus);
    // A payment failure's message already states the refund; stock failures
    // explain the refund separately.
    final detail = !isOutOfStock && failure.message.isNotEmpty ? failure.message : null;
    final notice = detail == null ? refund : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        height: 104,
                        width: 104,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDECEC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFB42318),
                          size: 56,
                          semanticLabel: 'Order not placed',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isOutOfStock ? 'Item unavailable — order not placed' : 'Payment Failed',
                      textAlign: TextAlign.center,
                      style: UiTypography.cardTitle().copyWith(
                        fontSize: 22,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isOutOfStock
                          ? 'One or more items went out of stock before your order could be placed.'
                          : 'We couldn\'t process your transaction at the moment. Don\'t worry — your order hasn\'t been placed yet.',
                      textAlign: TextAlign.center,
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 14,
                        color: AppColors.textColor50,
                        fontWeight: FontWeight.w400,
                      ).copyWith(height: 1.5),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 20),
                      _MessageBox(
                        text: detail,
                        background: const Color(0xFFFDECEC),
                        foreground: const Color(0xFFB42318),
                      ),
                    ],
                    if (notice != null) ...[
                      const SizedBox(height: 20),
                      _MessageBox(
                        text: notice,
                        background: Colors.white,
                        foreground: AppColors.textColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isOutOfStock ? 'Back to cart' : 'Try Again',
                  style: FontUtils.primaryFontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _MessageBox({
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EC)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: FontUtils.primaryFontStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: foreground,
        ).copyWith(height: 1.4),
      ),
    );
  }
}
