import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

/// ProductTwoRowScroll1 — a horizontally-scrolling area showing TWO ROWS of
/// small compact tiles (Amazon "keep shopping" feel). A horizontal
/// [GridView.builder] with crossAxisCount:2 lays items into two rows; the
/// `mainAxisExtent` controls the TILE WIDTH along the horizontal scroll.
/// Each tile is a compact image + title + price composed from shared helpers.
class ProductTwoRowScroll1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductTwoRowScroll1({
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
          SizedBox(
            height: 360,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // In a horizontal grid the main axis is the scroll (horizontal)
                // axis, so mainAxisExtent fixes the TILE WIDTH; the two rows
                // split the 360px height, giving overflow-safe tile heights.
                mainAxisExtent: 160,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _CompactTile(
                  data: item,
                  onTap: () => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: item,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;

  const _CompactTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 108,
                width: double.infinity,
                color: AppColors.secondary,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  fallbackFit: BoxFit.contain,
                  height: 108,
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            const Spacer(),
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
          ],
        ),
      ),
    );
  }
}
