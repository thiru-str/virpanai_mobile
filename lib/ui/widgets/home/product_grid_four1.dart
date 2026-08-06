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

/// ProductGridFour1 — a dense 4-column grid of small square product tiles.
/// Each tile is a square image, a single-line title, the selling price, and a
/// small circular "+" add button that increments cart quantity by one. Sized
/// with a generous, width-independent [mainAxisExtent] so nothing overflows on
/// narrow phones. Non-scrolling (shrinkWrap + NeverScrollableScrollPhysics) so
/// it nests inside the page scroll view. Composed from the shared merch helpers.
class ProductGridFour1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductGridFour1({
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
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              // Generous, width-independent cell height for a square image +
              // one-line title + price + a small "+" button so nothing overflows
              // in a tight 4-across layout.
              mainAxisExtent: 180,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _GridFourTile(
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

class _GridFourTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _GridFourTile({
    required this.data,
    required this.onTap,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);
    final variantId = variantIdOf(data);
    final accent = cmsAccent(context, AppColors.primary);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Square image with an overlaid small circular "+" add button.
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: merchImageOrFallback(image, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: GestureDetector(
                    onTap: () => onCartQtyChanged?.call(
                        cartQtyOf(data) + 1, variantId),
                    child: Container(
                      height: 26,
                      width: 26,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.add, size: 16, color: cmsOn(accent)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: cmsCardText(context, AppColors.textColor),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyUtil.appendCurrency(sellingPrice),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: cmsCardText(context, AppColors.textColor),
            ),
          ),
        ],
      ),
    );
  }
}
