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

/// ProductFlashDealList1 — a vertical "flash deals" list. Each row shows an
/// 80x80 thumbnail, the title, a computed DISCOUNT % badge (from selling vs
/// original price), a price row, a thin "stock sold" progress bar (a static
/// value derived from the row index) and a trailing [AddStepper]. Non-scrolling
/// (shrinkWrap + NeverScrollableScrollPhysics) so it nests inside the page
/// scroll view. Composed from the shared merch/product helpers; theming
/// inherited (no hardcoded text colours).
class ProductFlashDealList1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductFlashDealList1({
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
              return _FlashDealRow(
                data: item,
                // Static, deterministic "sold" ratio derived from the row index
                // so the bar looks varied but stable across rebuilds.
                soldRatio: 0.45 + (index % 4) * 0.12,
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

class _FlashDealRow extends StatelessWidget {
  final LayoutDatum data;
  final double soldRatio;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _FlashDealRow({
    required this.data,
    required this.soldRatio,
    required this.onTap,
    this.onCartQtyChanged,
  });

  // Discount percentage computed from selling vs original price. Returns 0 when
  // there is no meaningful discount (missing/invalid/equal prices).
  int _discountPercent(String selling, String original) {
    final s = double.tryParse(selling) ?? 0;
    final o = double.tryParse(original) ?? 0;
    if (o <= 0 || s <= 0 || s >= o) return 0;
    return (((o - s) / o) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);
    final originalPrice = merchOriginalPrice(data);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;
    final discount = _discountPercent(sellingPrice, originalPrice);
    final variantId = variantIdOf(data);
    final ratio = soldRatio.clamp(0.05, 0.95);
    final accent = cmsAccent(context, AppColors.primary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          // Thumbnails align to the top so a tall middle column never pushes the
          // image off-centre or overflows.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: cmsCardText(context, AppColors.textColor),
                          ),
                        ),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-$discount%',
                            style: FontUtils.primaryFontStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: cmsOn(accent),
                            ),
                          ),
                        ),
                      ],
                    ],
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
                  const SizedBox(height: 8),
                  // Thin "stock sold" progress bar — a static ratio track with a
                  // filled accent portion.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 6,
                      width: double.infinity,
                      color: cmsText(context, AppColors.textColor50)
                          .withValues(alpha: 0.18),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: ratio,
                        child: Container(color: accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(ratio * 100).round()}% sold',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: cmsCardText(context, AppColors.textColor50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Trailing add-to-cart control.
            AddStepper(
              count: cartQtyOf(data),
              onInc: () => onCartQtyChanged?.call(1, variantId),
              onDec: () => onCartQtyChanged?.call(-1, variantId),
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}
