import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../model/home_page_response.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Item3 extends StatelessWidget {
  final Content content;

  const Item3({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title + redirect
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if ((content?.layoutRedirectTitle ?? '').isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        RedirectUtils.handleContentRedirectViewAll(
                          context: context,
                          redirectData: content!.redirectData!,
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            content?.layoutRedirectTitle ?? '',
                            style: FontUtils.primaryFontStyle(
                              fontSize: 14,
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
            const SizedBox(height: 4),

            // 🔹 Horizontal Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(
                  content?.layoutData?.length ?? 0,
                      (i) {
                    final layoutData = content!.layoutData![i];
                    return GestureDetector(
                      onTap: () {
                        RedirectUtils.handleContentRedirect(
                          context: context,
                          layoutOption: content.layoutOption!,
                          layoutData: content.layoutData![i],
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i == content.layoutData!.length - 1 ? 0 : 16,
                        ),
                        child: _AlignedItemCard(layoutData: layoutData),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}

class _AlignedItemCard extends StatelessWidget {
  final LayoutDatum layoutData;
  const _AlignedItemCard({super.key, required this.layoutData});

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 360;

    return Container(
      width: isSmallScreen ? 64 : 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ FIXED image zone ensures all aligned perfectly
          SizedBox(
            width: isSmallScreen ? 64 : 72,
            height: isSmallScreen ? 64 : 72,
            child: ClipOval(
              child: Container(
                color: AppColors.secondary.withOpacity(0.15),
                child: (imageUrl.isNotEmpty)
                    ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      ImageFallbackWidget(h: 70, w: 70),
                )
                    : ImageFallbackWidget(h: 70, w: 70),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ✅ Flexible text zone (auto height but doesn’t affect image alignment)
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 32 : 36, // reserve space for 2 lines
              maxHeight: isSmallScreen ? 40 : 44, // allows wrapping without clipping
            ),
            child: Text(
              layoutData.title ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: isSmallScreen ? 11 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



