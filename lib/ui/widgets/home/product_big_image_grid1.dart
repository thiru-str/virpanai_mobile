import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

/// ProductBigImageGrid1 — a spacious 2-column grid of LARGE image-forward tiles
/// (HomeMerchEditorialCard-style content: big rounded image on top, then title +
/// price below). Non-scrolling (lives inside the page scroll). A fixed
/// `mainAxisExtent` keeps each cell overflow-safe on narrow phones.
class ProductBigImageGrid1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductBigImageGrid1({
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
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              // Big image (210) + title (2 lines) + price, with slack — a fixed
              // cell height keeps it width-independent and overflow-safe.
              mainAxisExtent: 300,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _BigImageTile(
                data: item,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BigImageTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;

  const _BigImageTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final badge = merchBadge(data);
    final sellingPrice = merchSellingPrice(data);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  height: 210,
                  width: double.infinity,
                  color: AppColors.secondary,
                  child: merchImageOrFallback(
                    image,
                    fit: BoxFit.cover,
                    fallbackFit: BoxFit.contain,
                    height: 210,
                    width: double.infinity,
                  ),
                ),
                if (badge.isNotEmpty)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 4),
          Text(
            CurrencyUtil.appendCurrency(sellingPrice),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: cmsCardText(context, AppColors.textColor),
            ),
          ),
        ],
      ),
    );
  }
}
