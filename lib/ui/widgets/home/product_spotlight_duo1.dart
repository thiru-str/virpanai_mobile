import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';
import 'product_cards_shared.dart';

/// ProductSpotlightDuo1 — exactly TWO medium spotlight product cards placed side
/// by side (the first two items). Each card is an [Expanded] column of image
/// (~150h), title, price + struck MRP and a FULL-WIDTH [AddStepper]. When only a
/// single item is present the one card renders full width. Composed from the
/// shared merch/product helpers so theming is inherited (no hardcoded text
/// colours). Guards empty → [SizedBox.shrink].
class ProductSpotlightDuo1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductSpotlightDuo1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    // Spotlight only the first two items.
    final duo = items.take(2).toList();

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? '',
            ctaText: content.layoutRedirectTitle ?? '',
            onTap: () => RedirectUtils.handleContentRedirect(
              context: context,
              layoutOption: content.layoutOption ?? '',
              layoutData: items.first,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < duo.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: _SpotlightCard(
                    data: duo[i],
                    onTap: () => RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: content.layoutOption ?? '',
                      layoutData: duo[i],
                    ),
                    onCartQtyChanged: onCartQtyChanged,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _SpotlightCard({
    required this.data,
    required this.onTap,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);
    final originalPrice = merchOriginalPrice(data);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;
    final variantId = variantIdOf(data);
    final accent = cmsAccent(context, AppColors.primary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  height: 150,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    CurrencyUtil.appendCurrency(sellingPrice),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: cmsCardText(context, AppColors.textColor),
                    ),
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      CurrencyUtil.appendCurrency(originalPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 11,
                        color: cmsCardText(context, AppColors.textColor50),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Full-width add-to-cart bar.
            SizedBox(
              width: double.infinity,
              child: Center(
                child: AddStepper(
                  count: cartQtyOf(data),
                  onInc: () =>
                      onCartQtyChanged?.call(cartQtyOf(data) + 1, variantId),
                  onDec: () =>
                      onCartQtyChanged?.call(cartQtyOf(data) - 1, variantId),
                  accent: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
