import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../model/home_page_response.dart';
import '../../../utility/app_assets.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';

class Grid2 extends StatelessWidget {
  final Content content;

  const Grid2({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<LayoutDatum> items =
        content.layoutData!.take(15).toList(); // Max 5x3 = 15 items
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
            // 🔹 Title & Redirect Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      content.layoutTitle ?? '',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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
                              fontSize: 15,
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
            const SizedBox(height: 16),

            // 🔹 Responsive Grid (keeps strict left-to-right list order)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final isSmallScreen = screenWidth < 360;

                  // Dynamically adjust grid spacing & columns
                  final crossAxisCount = isSmallScreen ? 4 : 5;
                  final crossAxisSpacing = isSmallScreen ? 8.0 : 12.0;
                  final itemWidth = (screenWidth -
                          (crossAxisSpacing * (crossAxisCount - 1))) /
                      crossAxisCount;

                  return Wrap(
                    spacing: crossAxisSpacing,
                    runSpacing: 10,
                    children: List.generate(items.length, (index) {
                      final layoutData = items[index];
                      return SizedBox(
                        width: itemWidth,
                        child: _Grid2Card(
                          layoutData: layoutData,
                          isSmallScreen: isSmallScreen,
                          onTap: () {
                            RedirectUtils.handleContentRedirect(
                              context: context,
                              layoutOption: content.layoutOption!,
                              layoutData: layoutData,
                            );
                          },
                        ),
                      );
                    }),
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

class _Grid2Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final bool isSmallScreen;
  final VoidCallback onTap;

  const _Grid2Card({
    Key? key,
    required this.layoutData,
    required this.isSmallScreen,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Fixed image height (ensures all rows align properly)
          SizedBox(
            width: isSmallScreen ? 56 : 60,
            height: isSmallScreen ? 56 : 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (imageUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _fallbackWidget(),
                    )
                  : _fallbackWidget(),
            ),
          ),

          const SizedBox(height: 6),

          // ✅ Responsive title (auto height, no clip, keeps grid aligned)
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 30 : 34,
              maxHeight: isSmallScreen ? 40 : 44, // 2 lines max
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                layoutData.title ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: isSmallScreen ? 10.5 : 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackWidget() {
    return Container(
      color: AppColors.secondary,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.ic_no_image,
        width: 32,
        height: 32,
      ),
    );
  }
}
