import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Item7 extends StatelessWidget {
  final Content content;

  const Item7({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  maxLines: 2, // Allow up to 2 lines for the title
                ),
              ),
              const SizedBox(width: 4), // Add some spacing between title and redirect
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
                    mainAxisSize: MainAxisSize.min, // Prevent redirect from expanding
                    children: [
                      Text(
                        content?.layoutRedirectTitle??'',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: content?.layoutData?.length ?? 0,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final layoutData = content!.layoutData![index];
                return _Item7Card(
                  layoutData: layoutData,
                  onTap: () {
                    RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: content.layoutOption ?? "",
                      layoutData: layoutData,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Item7Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Item7Card({
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
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circle Image
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: (imageUrl.isNotEmpty)
                      ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                    const ImageFallbackWidget(h: 60, w: 60),
                  )
                      : const ImageFallbackWidget(h: 60, w: 60),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              layoutData.title ?? '',
              style: FontUtils.primaryFontStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Subtitle or price
            Text(
              layoutData.subTitle?.isNotEmpty == true
                  ? layoutData.subTitle!
                  : '',
              style: FontUtils.primaryFontStyle(
                fontSize: 13,
                color: AppColors.textColor.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

