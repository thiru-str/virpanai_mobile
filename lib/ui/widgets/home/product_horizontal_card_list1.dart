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

/// ProductHorizontalCardList1 — a vertical list of FULL-WIDTH horizontal cards.
/// Each card is a 96x96 rounded image on the left and, on the right, the title
/// (max 2 lines), an optional badge chip + rating, a price row, and a trailing
/// [AddStepper]. The image row aligns to the top (CrossAxisAlignment.start) so a
/// tall right column never pushes the thumbnail off-centre. Best for
/// "Buy again" / dense browse. Non-scrolling (shrinkWrap +
/// NeverScrollableScrollPhysics) so it nests inside the page scroll view.
/// Composed from the shared merch/product helpers so theming is inherited.
class ProductHorizontalCardList1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductHorizontalCardList1({
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
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return _HorizontalCard(
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
      ),
    );
  }
}

class _HorizontalCard extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _HorizontalCard({
    required this.data,
    required this.onTap,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final badge = merchBadge(data);
    final rating = merchRating(data);
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
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          // Top-align so a two-line title never shifts the thumbnail or overflows.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 96,
                height: 96,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  width: 96,
                  height: 96,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  if (badge.isNotEmpty || rating.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (badge.isNotEmpty)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cmsAccent(context, AppColors.primary)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: cmsAccent(context, AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                        if (badge.isNotEmpty && rating.isNotEmpty)
                          const SizedBox(width: 6),
                        if (rating.isNotEmpty)
                          RatingChip(rating: rating, solid: true),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
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
                      const SizedBox(width: 8),
                      AddStepper(
                        count: cartQtyOf(data),
                        onInc: () =>
                            onCartQtyChanged?.call(cartQtyOf(data) + 1, variantId),
                        onDec: () =>
                            onCartQtyChanged?.call(cartQtyOf(data) - 1, variantId),
                        accent: cmsAccent(context, AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
