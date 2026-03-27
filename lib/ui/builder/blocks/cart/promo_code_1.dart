import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';

/// PromoCode1 - Discount code input with apply/remove.
/// Extracted from cart_page.dart promo code section
class PromoCode1Widget extends StatelessWidget {
  final List<String> appliedCodes;
  final VoidCallback onTap;
  final BlockConfig config;

  const PromoCode1Widget({
    super.key,
    required this.appliedCodes,
    required this.onTap,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final hasPromos = appliedCodes.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.discount_outlined,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasPromos ? appliedCodes.join(', ') : 'Enter Promo Code',
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 14,
                    color: hasPromos ? AppColors.textColor : AppColors.textColor50,
                    fontWeight: hasPromos ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                hasPromos ? 'Remove' : 'Apply',
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
