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

/// ProductRankedList1 — a native "Top picks" vertical list. Each row leads with
/// a BIG rank numeral (1, 2, 3…) for instant social-proof scanning, then a small
/// rounded thumb, title + rating + price, and a compact [AddStepper] on the
/// right. Composes the shared merch/cart helpers so theming, redirection and
/// add-to-cart match the other product widgets.
class ProductRankedList1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductRankedList1({
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
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _RankedRow(
                rank: index + 1,
                item: item,
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

class _RankedRow extends StatelessWidget {
  final int rank;
  final LayoutDatum item;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _RankedRow({
    required this.rank,
    required this.item,
    required this.onTap,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final title = item.title ?? '';
    final rating = merchRating(item);
    final sellingPrice = merchSellingPrice(item);
    final originalPrice = merchOriginalPrice(item);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;
    final variantId = variantIdOf(item);
    final count = cartQtyOf(item);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BIG rank numeral — the defining social-proof element.
            SizedBox(
              width: 34,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: FontUtils.primaryFontStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: cmsCardText(context, AppColors.textColor),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 68,
                width: 68,
                color: AppColors.secondary,
                child: merchImageOrFallback(
                  merchImage(item),
                  width: 68,
                  height: 68,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cmsCardText(context, AppColors.textColor),
                    ),
                  ),
                  if (rating.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    RatingChip(rating: rating),
                  ],
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
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            CurrencyUtil.appendCurrency(originalPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 12,
                              color: cmsCardText(context, AppColors.textColor50),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Align(
              alignment: Alignment.centerRight,
              child: variantId.isEmpty || onCartQtyChanged == null
                  ? const SizedBox.shrink()
                  : AddStepper(
                      count: count,
                      accent: cmsAccent(context, Colors.black),
                      onInc: () => onCartQtyChanged!.call(1, variantId),
                      onDec: () => onCartQtyChanged!.call(-1, variantId),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
