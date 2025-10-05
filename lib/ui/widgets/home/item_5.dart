import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_strings.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Item5 extends StatelessWidget {
  final Content content;

  const Item5({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasViewAll = (content.layoutRedirectTitle ?? '').trim().isNotEmpty;

    return Column(
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
                  _Item5Card(
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
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed-height image + overlays
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: (layoutData.image??'').isNotEmpty?Image(
                    image: CachedNetworkImageProvider(layoutData.image??''),
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) => _imageFallback(),
                  ):_imageFallback(),
                ),
                // Positioned(
                //   top: 8,
                //   right: 8,
                //   child: Icon(
                //     Icons.favorite_border,
                //     color: AppColors.secondary,
                //   ),
                // ),
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
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, ),
              child: Text(
                layoutData.title ?? '',
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
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
                      layoutData.prices?.sellingPrice ?? '0',
                    ),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                  if (_hasDiscount)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        CurrencyUtil.appendCurrency(
                          layoutData.prices?.originalPrice ?? '0',
                        ),
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor.withOpacity(0.6),
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

