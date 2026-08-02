import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// Shared building blocks for the supermarket / grocery component family.
// Kept compact and dense — the way grocery apps (Blinkit, Zepto, BigBasket)
// present fast-moving daily items. A fresh-green add button signals grocery.

const Color kFresh = Color(0xFF1BA672); // fresh grocery accent
const Color kInk = Color(0xFF1A1A1A);

class GroceryAddButton extends StatelessWidget {
  final bool compact;
  const GroceryAddButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 28 : 32,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kFresh.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kFresh.withOpacity(0.35)),
      ),
      child: Text(
        'ADD',
        style: FontUtils.primaryFontStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: kFresh,
        ),
      ),
    );
  }
}

// Compact grocery product tile: square image, name, unit/weight, price + ADD.
class GroceryTile extends StatelessWidget {
  final LayoutDatum data;
  final double width; // 0 => flexible (grid cell)
  const GroceryTile({super.key, required this.data, this.width = 120});

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final unit = data.featureText ?? '';
    final selling = merchSellingPrice(data);
    final original = merchOriginalPrice(data);
    final hasDiscount = original != '0' && original != selling;
    final badge = merchBadge(data);

    final tile = Container(
      decoration: BoxDecoration(
        color: cmsCard(context, Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kInk.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: merchImageOrFallback(image,
                      fit: BoxFit.cover, fallbackFit: BoxFit.contain),
                ),
              ),
              if (badge.isNotEmpty)
                Positioned(
                  left: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: kFresh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cmsCardText(context, AppColors.textColor),
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: cmsCardText(context, AppColors.textColor50),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  CurrencyUtil.appendCurrency(selling),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: cmsCardText(context, AppColors.textColor),
                  ),
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    CurrencyUtil.appendCurrency(original),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: cmsCardText(context, AppColors.textColor50),
                    ).copyWith(decoration: TextDecoration.lineThrough),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          const SizedBox(width: double.infinity, child: GroceryAddButton(compact: true)),
        ],
      ),
    );

    if (width <= 0) return tile;
    return SizedBox(width: width, child: tile);
  }
}
