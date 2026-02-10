import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_strings.dart';

import '../../../utility/app_assets.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Item9 extends StatelessWidget {
  final Content content;

  const Item9({
    Key? key,
    required this.content,
  }) : super(key: key);

  // Card height breakdown: 140(img) + 6 + 36(title) + 2 + 20(price) + 20(discount) + 4 + 2(border)
  static const double _cardHeight = 232;

  @override
  Widget build(BuildContext context) {
    final decoration = AppUtils.buildLayoutBackground(content);
    final hasDecoration = decoration != null;
    final horizontalPadding = hasDecoration ? 20.0 : 16.0;
    final itemSpacing = hasDecoration ? 20.0 : 16.0;
    final items = content.layoutData ?? [];

    return Container(
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Row ──
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: hasDecoration ? 12 : 0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    content.layoutTitle ?? '',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: hasDecoration ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                            fontSize: hasDecoration ? 15 : 14,
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
          ),

          // ── Horizontal Product List (virtualized) ──
          SizedBox(
            height: _cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: hasDecoration ? 5 : 0,
              ),
              itemCount: items.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              itemBuilder: (context, i) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < items.length - 1 ? itemSpacing : 0,
                  ),
                  child: _Item9Card(
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
    );
  }
}

class _Item9Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Item9Card({
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image + ADD button ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Container(
                    height: 140,
                    color: Colors.grey[100],
                    child: (layoutData.image ?? '').isEmpty
                        ? const ImageFallbackWidget(
                      h: 140,
                      w: double.infinity,
                      fit: BoxFit.contain,
                    )
                        : CachedNetworkImage(
                      imageUrl: layoutData.image!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      // ⬇️ Decode at display size, not full resolution
                      memCacheWidth: 320,  // 160 logical * 2x pixel ratio
                      memCacheHeight: 280, // 140 logical * 2x pixel ratio
                      fadeInDuration: Duration.zero, // skip fade animation
                      errorWidget: (c, u, e) =>
                      const ImageFallbackWidget(
                          h: 140,
                          w: double.infinity,
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
                // ADD button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.white),
                      foregroundColor:
                      WidgetStateProperty.all<Color>(AppColors.primary),
                      side: WidgetStateProperty.all<BorderSide>(
                          BorderSide(color: AppColors.primary, width: 1)),
                      shape:
                      WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4)),
                      minimumSize:
                      WidgetStateProperty.all<Size>(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: WidgetStateProperty.all<double>(0),
                    ),
                    child: Text(
                      "ADD",
                      style: FontUtils.primaryFontStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // --- Title ---
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Text(
                layoutData.title ?? '',
                style: FontUtils.primaryFontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 2),

            // --- Price row ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    CurrencyUtil.appendCurrency(
                      layoutData.prices?.sellingPrice ?? '0',
                    ),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (_hasDiscount)
                    Text(
                      CurrencyUtil.appendCurrency(
                        layoutData.prices?.originalPrice ?? '0',
                      ),
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),

            if (_hasDiscount)
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: Text(
                  'SAVE ${layoutData.prices!.discountPercentage ?? ''}',
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}


