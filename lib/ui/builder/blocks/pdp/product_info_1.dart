import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';
import '../../../../utility/currency_util.dart';

/// ProductInfo1 - Title, price, rating, badges.
/// Extracted from product_detail_page.dart buildProductDetails()
class ProductInfo1Widget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? currentPrice;
  final String? originalPrice;
  final double? rating;
  final int? reviewCount;
  final String? brand;
  final BlockConfig config;

  const ProductInfo1Widget({
    super.key,
    required this.title,
    required this.config,
    this.subtitle,
    this.currentPrice,
    this.originalPrice,
    this.rating,
    this.reviewCount,
    this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          if (config.getBool('show_brand', defaultValue: true) && brand != null && brand!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                brand!,
                style: FontUtils.secondaryFontStyle(
                  fontSize: 12,
                  color: AppColors.textColor50,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Title
          Text(
            title,
            style: FontUtils.primaryFontStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Price row
          if (currentPrice != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyUtil.appendCurrency(currentPrice!),
                  style: FontUtils.primaryFontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColor,
                  ),
                ),
                if (originalPrice != null &&
                    originalPrice != currentPrice) ...[
                  const SizedBox(width: 8),
                  Text(
                    CurrencyUtil.appendCurrency(originalPrice!),
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 14,
                      color: AppColors.textColor50,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildDiscountBadge(),
                ],
              ],
            ),

          // Rating
          if (config.getBool('show_rating', defaultValue: true) &&
              rating != null &&
              rating! > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating!.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
                if (reviewCount != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($reviewCount)',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 12,
                      color: AppColors.textColor50,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscountBadge() {
    if (!config.getBool('show_discount_badge', defaultValue: true)) {
      return const SizedBox.shrink();
    }

    final current = double.tryParse(currentPrice ?? '0') ?? 0;
    final original = double.tryParse(originalPrice ?? '0') ?? 0;
    if (original <= 0 || current >= original) return const SizedBox.shrink();

    final discount = ((original - current) / original * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$discount% OFF',
        style: FontUtils.secondaryFontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.green[700]!,
        ),
      ),
    );
  }
}
