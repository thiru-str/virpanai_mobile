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

/// ProductTallCardRail1 — a horizontally scrolling rail of TALL PORTRAIT cards.
/// Each ~160px-wide card leads with a large 3:4-ish image (~230h), then title,
/// price + struck MRP, and a FULL-WIDTH [AddStepper] bar pinned at the base.
/// Composed from the shared merch/product helpers so theming is inherited (no
/// hardcoded text colours). Guards empty → [SizedBox.shrink].
class ProductTallCardRail1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductTallCardRail1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
              ctaText: content.layoutRedirectTitle ?? '',
              onTap: () => RedirectUtils.handleContentRedirect(
                context: context,
                layoutOption: content.layoutOption ?? '',
                layoutData: items.first,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Fixed-height rail so the tall cards never overflow vertically.
          SizedBox(
            height: 350,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _TallCard(
                  data: item,
                  onTap: () => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: item,
                  ),
                  onCartQtyChanged: onCartQtyChanged,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TallCard extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _TallCard({
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
        width: 160,
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
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large portrait image (~3:4).
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 230,
                width: double.infinity,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  height: 230,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    CurrencyUtil.appendCurrency(sellingPrice),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
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
            const Spacer(),
            // Full-width add-to-cart bar pinned to the base of the tall card.
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
