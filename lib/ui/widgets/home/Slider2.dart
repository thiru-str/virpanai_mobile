import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../model/home_page_response.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Slider2 extends StatelessWidget {
  final Content content;

  const Slider2({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  content?.layoutTitle ?? '',
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              if ((content?.layoutRedirectTitle ?? '').isNotEmpty)
                GestureDetector(
                  onTap: () {
                    // Handle redirection
                    RedirectUtils.handleContentRedirectViewAll(
                      context: context,
                      redirectData: content!.redirectData!,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        content?.layoutRedirectTitle ?? "",
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18)
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < (content.layoutData?.length ?? 0); i++) ...[
                  _Slider2Card(
                    layoutData: content.layoutData![i],
                    onTap: () {
                      RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content.layoutOption ?? "",
                        layoutData: content.layoutData![i],
                      );
                    },
                  ),
                  if (i != content.layoutData!.length - 1)
                    const SizedBox(width: 12), // spacing between items
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Slider2Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Slider2Card({
    Key? key,
    required this.layoutData,
    required this.onTap,
  }) : super(key: key);

  bool get _hasDiscount =>
      layoutData.prices?.discountedPrice != null &&
          layoutData.prices?.discountedPrice != "0";

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        height: 120,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Card with image + title
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: (imageUrl.isNotEmpty)
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                        const ImageFallbackWidget(h: 80),
                      )
                          : const ImageFallbackWidget(h: 80),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      layoutData.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: FontUtils.primaryFontStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Discount badge
            if (_hasDiscount)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${layoutData.prices?.discountPercentage ?? ''} OFF',
                  style: FontUtils.primaryFontStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

