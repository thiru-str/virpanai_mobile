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

/// A dense, grocery-style 2-column quick-add grid. Each cell is a compact tile
/// composed from the shared merch helpers (thumb, title, price row) with a
/// prominent [AddStepper] wired to add-to-cart. Theming is inherited via the
/// cms* helpers, so no colours are hardcoded.
class ProductQuickAddGrid1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductQuickAddGrid1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: backgroundDecoration,
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
              // Tight, width-independent cell height for the compact thumb +
              // title + price + stepper tile.
              mainAxisExtent: 236,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _QuickAddTile(
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

class _QuickAddTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _QuickAddTile({
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
                height: 96,
                width: double.infinity,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  height: 96,
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
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyUtil.appendCurrency(sellingPrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: cmsCardText(context, AppColors.textColor),
                        ),
                      ),
                      if (hasDiscount)
                        Text(
                          CurrencyUtil.appendCurrency(originalPrice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 11,
                            color: cmsCardText(context, AppColors.textColor50),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                AddStepper(
                  count: cartQtyOf(data),
                  onInc: () => onCartQtyChanged?.call(1, variantId),
                  onDec: () => onCartQtyChanged?.call(-1, variantId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
