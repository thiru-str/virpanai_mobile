import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

import '../../../utility/app_assets.dart';

class Grid1 extends StatelessWidget {
  final Content content;

  const Grid1({super.key, required this.content});

  static const double _railHeightWithDiscount = 308;
  static const double _railHeightWithoutDiscount = 292;

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
    final items = content.layoutData ?? [];
    final hasAnyDiscount = items.any(
      (item) => (item.prices?.discountPercentage ?? '').isNotEmpty,
    );

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

            // ── Banner Image ──
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
              child: CachedNetworkImage(
                imageUrl: content.layoutBannerImage ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.contain,
                memCacheHeight: 300,
                fadeInDuration: Duration.zero,
                errorWidget: (context, url, error) => _bannerFallback(),
              ),
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
                      right: i < items.length - 1 ? 12 : 0,
                    ),
                    child: _Grid1Card(
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

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _bannerFallback() {
    return Container(
      height: 150,
      color: AppColors.secondary,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.ic_no_image,
        width: 48,
        height: 48,
      ),
    );
  }
}

class _Grid1Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Grid1Card({required this.layoutData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Align(
          alignment: Alignment.topCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image + badges ──
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: CachedNetworkImage(
                        imageUrl: layoutData.image ?? '',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        memCacheWidth: 300, // 150 × 2x
                        memCacheHeight: 360, // 180 × 2x
                        fadeInDuration: Duration.zero,
                        errorWidget: (context, url, error) =>
                            _cardImageFallback(),
                      ),
                    ),
                    // Sales badge
                    if ((layoutData.salesText ?? '').isNotEmpty)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            layoutData.salesText ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    // Feature + rating bar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                layoutData.featureText ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 10, color: Colors.green),
                                  const SizedBox(width: 2),
                                  Text(
                                    (layoutData.rating ?? 0).toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ── Title ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    layoutData.title ?? '',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // ── Dotted Line ──
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: DottedLine(
                    dashLength: 4,
                    dashGapLength: 3,
                    lineThickness: 1,
                    dashColor: Colors.grey,
                  ),
                ),

                // ── Price ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    CurrencyUtil.appendCurrency(
                      layoutData.prices?.sellingPrice ?? '',
                    ),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // ── Original Price + % Off ──
                if (layoutData.prices?.discountPercentage?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            CurrencyUtil.appendCurrency(
                              layoutData.prices?.originalPrice ?? '',
                            ),
                            style: FontUtils.primaryFontStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            layoutData.prices?.discountPercentage ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _cardImageFallback() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.secondary,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.ic_no_image,
        width: 48,
        height: 48,
      ),
    );
  }
}
