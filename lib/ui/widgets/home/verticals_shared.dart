import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

// Shared building blocks for the multi-vertical component family
// (electronics, food, pharmacy, beauty, home) so a single storefront can mix
// collections from different verticals.

// A large rounded shortcut tile for a whole vertical (super-app switcher).
class VerticalTile extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final Color color;
  const VerticalTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.subLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textColor),
          ),
          if (subLabel.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ],
      ),
    );
  }
}

// Restaurant / food dish tile: veg-nonveg indicator, rating pill, price + add.
class RestaurantTile extends StatelessWidget {
  final LayoutDatum data;
  final double width;
  const RestaurantTile({super.key, required this.data, this.width = 168});

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final rating = merchRating(data);
    final selling = merchSellingPrice(data);
    // salesText encodes veg/nonveg: 'veg' or 'nonveg'
    final isVeg = (data.salesText ?? 'veg').toLowerCase() != 'nonveg';
    final vegColor = isVeg ? const Color(0xFF1BA672) : const Color(0xFFD64545);

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kInk.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 11,
                child: ImageFallbackWidget(fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  height: 14, width: 14,
                  decoration: BoxDecoration(
                    border: Border.all(color: vegColor, width: 1.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Center(
                    child: Container(
                      height: 6, width: 6,
                      decoration: BoxDecoration(color: vegColor, shape: BoxShape.circle),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textColor),
                  ),
                ),
              ],
            ),
            if (rating.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1BA672),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rating,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, size: 9, color: Colors.white),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    CurrencyUtil.appendCurrency(selling),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textColor),
                  ),
                ),
                const SizedBox(width: 6),
                const GroceryAddButton(compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
