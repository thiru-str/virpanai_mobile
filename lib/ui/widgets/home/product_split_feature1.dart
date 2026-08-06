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

/// ProductSplitFeature1 — a hero-plus-grid layout. The FIRST item is rendered as
/// a large feature card (tall ~190h image, title, price + struck MRP,
/// [RatingChip] and a full-width [AddStepper]); the next up-to-4 items follow in
/// a compact 2-column grid below. Non-scrolling (shrinkWrap +
/// NeverScrollableScrollPhysics) so it nests inside the page scroll view.
/// Composed from the shared merch/product helpers; theming inherited.
class ProductSplitFeature1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductSplitFeature1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final hero = items.first;
    // Up to four supporting products for the compact grid below the hero.
    final rest = items.length > 1 ? items.sublist(1).take(4).toList() : [];

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
              layoutData: hero,
            ),
          ),
          const SizedBox(height: 14),
          _HeroCard(
            data: hero,
            onTap: () => RedirectUtils.handleContentRedirect(
              context: context,
              layoutOption: content.layoutOption ?? '',
              layoutData: hero,
            ),
            onCartQtyChanged: onCartQtyChanged,
          ),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: rest.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Generous, width-independent cell height for image + title +
                // price + a full-width stepper so nothing overflows.
                mainAxisExtent: 250,
              ),
              itemBuilder: (context, index) {
                final item = rest[index];
                return _CompactTile(
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
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _HeroCard({
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
    final rating = merchRating(data);
    final variantId = variantIdOf(data);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 190,
                width: double.infinity,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  height: 190,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            if (rating.isNotEmpty) ...[
              const SizedBox(height: 6),
              RatingChip(rating: rating, solid: true),
            ],
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          CurrencyUtil.appendCurrency(sellingPrice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: cmsCardText(context, AppColors.textColor),
                          ),
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            CurrencyUtil.appendCurrency(originalPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 13,
                              color: cmsCardText(context, AppColors.textColor50),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AddStepper(
                  count: cartQtyOf(data),
                  onInc: () => onCartQtyChanged?.call(1, variantId),
                  onDec: () => onCartQtyChanged?.call(-1, variantId),
                  accent: cmsAccent(context, AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _CompactTile({
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 104,
                width: double.infinity,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  height: 104,
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
            SizedBox(
              width: double.infinity,
              child: Center(
                child: AddStepper(
                  count: cartQtyOf(data),
                  onInc: () => onCartQtyChanged?.call(1, variantId),
                  onDec: () => onCartQtyChanged?.call(-1, variantId),
                  accent: cmsAccent(context, AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
