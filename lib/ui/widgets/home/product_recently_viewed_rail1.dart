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

/// ProductRecentlyViewedRail1 — a COMPACT "recently viewed" rail of small tiles
/// (~120px wide). Each tile is a small image (~120h), a single-line title, the
/// price, and a small circular "+" quick-add button that adds one to the cart.
/// Composed from the shared merch/product helpers so theming is inherited (no
/// hardcoded text colours). Guards empty → [SizedBox.shrink].
class ProductRecentlyViewedRail1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductRecentlyViewedRail1({
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
          // Fixed-height compact rail so the small tiles never overflow.
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _RecentTile(
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

class _RecentTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _RecentTile({
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
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 6),
            Text(
              data.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    CurrencyUtil.appendCurrency(sellingPrice),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: cmsCardText(context, AppColors.textColor),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Small circular quick-add "+" — adds one to the cart.
                GestureDetector(
                  onTap: () => onCartQtyChanged?.call(
                      cartQtyOf(data) + 1, variantId),
                  child: Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: cmsAccent(context, accent),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: cmsOn(cmsAccent(context, accent)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
