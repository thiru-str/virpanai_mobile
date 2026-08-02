import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

class Item14 extends StatelessWidget {
  final Content content;

  const Item14({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasViewAll = (content.layoutRedirectTitle ?? '').trim().isNotEmpty;
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title + View All
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      content.layoutTitle ?? '',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cmsCardText(context, AppColors.textColor),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (hasViewAll)
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
                              color: cmsCardText(context, AppColors.textColor),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Horizontal scroll
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0;
                        i < (content.layoutData?.length ?? 0);
                        i++) ...[
                      _Item14Card(
                        layoutData: content.layoutData![i],
                        onTap: () {
                          RedirectUtils.handleContentRedirect(
                            context: context,
                            layoutOption: content.layoutOption!,
                            layoutData: content.layoutData![i],
                          );
                        },
                      ),
                      if (i != content.layoutData!.length - 1)
                        const SizedBox(width: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item14Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Item14Card({
    Key? key,
    required this.layoutData,
    required this.onTap,
  }) : super(key: key);

  bool get _hasDiscount =>
      layoutData.prices?.discountedPrice != null &&
      layoutData.prices!.discountedPrice != "0";

  @override
  Widget build(BuildContext context) {
    final prices = layoutData.prices;
    final selling = double.tryParse(prices?.sellingPrice ?? "0") ?? 0;
    final original = double.tryParse(prices?.originalPrice ?? "0") ?? 0;
    final hasDiscount = original > selling && selling > 0;
    final percentOff =
        hasDiscount ? (((original - selling) / original) * 100).round() : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        color: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Product Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(0)),
              child: Container(
                height: 240,
                color: Colors.grey[100],
                child: (layoutData.image ?? '').isEmpty
                    ? const ImageFallbackWidget(
                        h: 240,
                        w: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : CachedNetworkImage(
                        imageUrl: layoutData.image!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        errorWidget: (c, u, e) => const ImageFallbackWidget(
                            h: 140, w: double.infinity),
                      ),
              ),
            ),

            const SizedBox(height: 8),

            // 🔹 Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                layoutData.title ?? "Write A Title Here",
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // 🔹 Price Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    CurrencyUtil.appendCurrency(selling.toStringAsFixed(0)),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (hasDiscount)
                    Text(
                      CurrencyUtil.appendCurrency(original.toStringAsFixed(0)),
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (percentOff != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "$percentOff% OFF",
                        style: FontUtils.primaryFontStyle(
                          fontSize: 10,
                          color: cmsCard(context, Colors.white),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
