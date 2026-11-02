import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

/// ProductCircleThumbRail1 — a boutique-feel horizontal rail of circular
/// product thumbnails, each with a one-line title and price centred below.
/// Tapping a thumb redirects via the shared RedirectUtils; theming and the
/// merch image/price helpers are reused so it matches the other product
/// widgets. Deliberately tap-to-shop (no inline stepper) for a clean, curated
/// look.
class ProductCircleThumbRail1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductCircleThumbRail1({
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
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return _CircleThumb(
                  item: item,
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

class _CircleThumb extends StatelessWidget {
  final LayoutDatum item;
  final VoidCallback onTap;

  const _CircleThumb({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sellingPrice = merchSellingPrice(item);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                height: 96,
                width: 96,
                color: AppColors.secondary,
                child: merchImageOrFallback(
                  merchImage(item),
                  fit: BoxFit.cover,
                  height: 96,
                  width: 96,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyUtil.appendCurrency(sellingPrice),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(
                fontSize: 12,
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
