import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/redirect_utils.dart';

class Item9 extends StatelessWidget {
  final Content content;

  const Item9({
    Key? key,
    required this.content,
  }) : super(key: key);

  static const double _railHeightWithDiscount = 252;
  static const double _railHeightWithoutDiscount = 236;

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
            // ── Title Row ──
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      content.layoutTitle ?? '',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 16,
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
            ),

            // ── Horizontal Product List (virtualized) ──
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
      child: SizedBox(
        width: 160,
        child: Align(
          alignment: Alignment.topCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                memCacheWidth: 320,
                                memCacheHeight: 280,
                                fadeInDuration: Duration.zero,
                                errorWidget: (c, u, e) =>
                                    const ImageFallbackWidget(
                                  h: 140,
                                  w: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                    ),
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
                            BorderSide(color: AppColors.primary, width: 1),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          padding: WidgetStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          minimumSize: WidgetStateProperty.all<Size>(Size.zero),
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
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 6),
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
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (_hasDiscount)
                        Flexible(
                          child: Text(
                            CurrencyUtil.appendCurrency(
                              layoutData.prices?.originalPrice ?? '0',
                            ),
                            style: FontUtils.secondaryFontStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_hasDiscount)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2),
                    child: Text(
                      'SAVE ${layoutData.prices!.discountPercentage ?? ''}',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                if (_hasDiscount) const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
