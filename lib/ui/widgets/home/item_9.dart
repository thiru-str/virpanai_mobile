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

  @override
  Widget build(BuildContext context) {
    final hasViewAll = (content.layoutRedirectTitle ?? '').trim().isNotEmpty;

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + View All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // Allow up to 2 lines for the title
                  ),
                ),
                const SizedBox(width: 4), // Add some spacing between title and redirect
                Visibility(
                  visible: (content.layoutRedirectTitle ?? '').isNotEmpty,
                  child: GestureDetector(
                    onTap: () {
                      // Handle section-level redirection if needed
                      RedirectUtils.handleContentRedirectViewAll(
                        context: context,
                        redirectData: content.redirectData!,
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Prevent redirect from expanding
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
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Horizontal scroller without fixed height
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < (content.layoutData?.length ?? 0); i++) ...[
                    _Item9Card(
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
            // --- Image + wishlist + add button ---
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
                      MaterialStateProperty.all<Color>(Colors.white),
                      foregroundColor:
                      MaterialStateProperty.all<Color>(AppColors.primary),
                      side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: AppColors.primary, width: 1)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4)),
                      minimumSize:
                      MaterialStateProperty.all<Size>(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: MaterialStateProperty.all<double>(0),
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

  Widget _imageFallback() {
    return Container(
      height: 280,
      width: double.infinity,
      color:AppColors.secondary, // light grey background
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.ic_no_image, // <- your SVG path
        width: 56,
        height: 56,
        // optional tint to match your UI
      ),
    );
  }
}


