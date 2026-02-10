import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/redirect_utils.dart';

class Item4 extends StatelessWidget {
  final Content content;

  const Item4({
    Key? key,
    required this.content,
  }) : super(key: key);

  // 230(img) + 8 + 34(title) + 4 + 35(price) = ~311
  static const double _cardHeight = 314;

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + View All
            Row(
              children: [
                Expanded(
                  child: Text(
                    content.layoutTitle ?? '',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 4),
                if ((content.layoutRedirectTitle ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      RedirectUtils.handleContentRedirectViewAll(
                        context: context,
                        redirectData: content.redirectData!,
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          content.layoutRedirectTitle!,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Virtualized horizontal list ──
            SizedBox(
              height: _cardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: i < items.length - 1 ? 16 : 0,
                    ),
                    child: _Item4Card(
                      layoutData: items[i],
                      onTap: () {
                        RedirectUtils.handleContentRedirect(
                          context: context,
                          layoutOption: content.layoutOption!,
                          layoutData: items[i],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item4Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Item4Card({
    Key? key,
    required this.layoutData,
    required this.onTap,
  }) : super(key: key);

  bool get _hasDiscount =>
      layoutData.prices?.discountedPrice != null &&
          layoutData.prices!.discountedPrice != "0";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed-height image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: layoutData.image ?? '',
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: 320,   // 160 logical × 2x
                    memCacheHeight: 460,  // 230 logical × 2x
                    fadeInDuration: Duration.zero,
                    errorWidget: (c, u, e) => const ImageFallbackWidget(
                      h: 230,
                      w: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (_hasDiscount)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 6,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                        ),
                      ),
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          layoutData.prices!.discountPercentage ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                layoutData.title ?? '',
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // Prices
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    CurrencyUtil.appendCurrency(
                        layoutData.prices?.sellingPrice ?? '0'),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                  if (_hasDiscount)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        CurrencyUtil.appendCurrency(
                            layoutData.prices?.originalPrice ?? '0'),
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor.withValues(alpha: 0.6),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
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

