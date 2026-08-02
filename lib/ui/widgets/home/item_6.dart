import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';
import 'cms_text_color.dart';

class Item6 extends StatelessWidget {
  final Content content;

  const Item6({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      content?.layoutTitle ?? '',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cmsCardText(context, AppColors.textColor),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Allow up to 2 lines for the title
                    ),
                  ),
                  const SizedBox(
                      width: 4), // Add some spacing between title and redirect
                  Visibility(
                    visible: (content?.layoutRedirectTitle ?? '').isNotEmpty,
                    child: GestureDetector(
                      onTap: () {
                        // Handle section-level redirection if needed
                        RedirectUtils.handleContentRedirectViewAll(
                          context: context,
                          redirectData: content!.redirectData!,
                        );
                      },
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // Prevent redirect from expanding
                        children: [
                          Text(
                            content?.layoutRedirectTitle ?? '',
                            style: FontUtils.primaryFontStyle(
                              fontSize: 14,
                              color: cmsCardText(context, AppColors.textColor),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0;
                        i < (content.layoutData?.length ?? 0);
                        i++) ...[
                      _Item6Card(
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

class _Item6Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Item6Card({
    Key? key,
    required this.layoutData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220, // similar to item5 width
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: (imageUrl.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const ImageFallbackWidget(
                          h: 60,
                          w: 60,
                        ),
                      )
                    : const ImageFallbackWidget(h: 60, w: 60),
              ),
            ),
            const SizedBox(width: 10),

            // Title + optional price or subtitle if needed
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    layoutData.title ?? '',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      color: cmsCardText(context, AppColors.textColor),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
