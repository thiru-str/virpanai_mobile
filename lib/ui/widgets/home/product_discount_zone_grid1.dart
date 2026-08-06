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

/// ProductDiscountZoneGrid1 — a 2-column "discount zone" grid where each tile
/// LEADS with a big discount % badge (computed from selling vs original price)
/// overlaid on the image, then title, an old/new price row and a full-width
/// [AddStepper]. Non-scrolling (shrinkWrap + NeverScrollableScrollPhysics) so it
/// nests inside the page scroll view. Composed from the shared merch/product
/// helpers so theming is inherited (no hardcoded text colours). Guards empty →
/// [SizedBox.shrink].
class ProductDiscountZoneGrid1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductDiscountZoneGrid1({
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
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // Generous, width-independent cell height for image + badge +
              // title + old/new price row + full-width stepper so nothing
              // overflows on narrow phones.
              mainAxisExtent: 290,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _DiscountTile(
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

class _DiscountTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _DiscountTile({
    required this.data,
    required this.onTap,
    this.onCartQtyChanged,
  });

  // Discount percentage from selling vs original price. 0 when not meaningful.
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
    final accent = cmsAccent(context, AppColors.primary);

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
            // Image with the LEADING big discount badge overlaid.
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: merchImageOrFallback(
                      image,
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.infinity,
                    ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$discount%',
                            style: FontUtils.primaryFontStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: cmsOn(accent),
                            ),
                          ),
                          Text(
                            'OFF',
                            style: FontUtils.primaryFontStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: cmsOn(accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
            const Spacer(),
            // Full-width add-to-cart bar.
            SizedBox(
              width: double.infinity,
              child: Center(
                child: AddStepper(
                  count: cartQtyOf(data),
                  onInc: () => onCartQtyChanged?.call(cartQtyOf(data) + 1, variantId),
                  onDec: () => onCartQtyChanged?.call(cartQtyOf(data) - 1, variantId),
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
