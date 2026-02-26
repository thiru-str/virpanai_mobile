import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';

class Item5 extends StatelessWidget {
  final Content content;

  const Item5({
    Key? key,
    required this.content,
  }) : super(key: key);

  static const double _railHeightWithDiscount = 384;
  static const double _railHeightWithoutDiscount = 366;

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
    final items = content.layoutData ?? [];
    final hasAnyDiscount = items.any(
      (item) =>
          item.prices?.discountedPrice != null &&
          item.prices!.discountedPrice != "0",
    );

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + View All
            Row(
              children: [
                Expanded(
                  child: Text(
                    content.layoutTitle ?? '',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 16,
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
                            fontSize: 14,
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

            const SizedBox(height: 12),

            // ── Virtualized horizontal list ──
            SizedBox(
              height: hasAnyDiscount
                  ? _railHeightWithDiscount
                  : _railHeightWithoutDiscount,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: items.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: i < items.length - 1 ? 16 : 0,
                    ),
                    child: _Item5Card(
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

class _Item5Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Item5Card({
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
      child: SizedBox(
        width: 200,
        child: Align(
          alignment: Alignment.topCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed-height image + overlays
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: (layoutData.image ?? '').isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: layoutData.image!,
                              height: 280,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              memCacheWidth: 400, // 200 logical × 2x
                              memCacheHeight: 560, // 280 logical × 2x
                              fadeInDuration: Duration.zero,
                              errorWidget: (c, u, e) =>
                                  const ImageFallbackWidget(
                                h: 280,
                              ),
                            )
                          : const ImageFallbackWidget(
                              h: 280,
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
                              '${layoutData.prices!.discountPercentage ?? ''} OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    layoutData.title ?? '',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 4),

                // Prices
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          CurrencyUtil.appendCurrency(
                            layoutData.prices?.sellingPrice ?? '0',
                          ),
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_hasDiscount)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              CurrencyUtil.appendCurrency(
                                layoutData.prices?.originalPrice ?? '0',
                              ),
                              style: FontUtils.primaryFontStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color:
                                    AppColors.textColor.withValues(alpha: 0.6),
                                decoration: TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
