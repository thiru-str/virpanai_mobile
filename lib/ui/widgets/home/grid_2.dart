import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';

import '../../../model/home_page_response.dart';
import '../../../utility/app_assets.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';

class Grid2 extends StatelessWidget {
  final Content content;

  const Grid2({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<LayoutDatum> items = content.layoutData!.take(15).toList(); // Max 5x3 = 15 items

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Title & redirect section
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

        // 🔹 Responsive Masonry Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isSmallScreen = screenWidth < 360;

              // Dynamically adjust grid spacing & columns
              final crossAxisCount = isSmallScreen ? 4 : 5;
              final mainAxisSpacing = isSmallScreen ? 12.0 : 16.0;
              final crossAxisSpacing = isSmallScreen ? 8.0 : 12.0;

              return MasonryGridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final layoutData = items[index];

                  return GestureDetector(
                    onTap: () {
                      RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content.layoutOption!,
                        layoutData: layoutData,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Fixed image area (keeps row alignment consistent)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: layoutData.image ?? '',
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  _fallbackWidget(),
                            ),
                          ),
                        ),

                        // ✅ Dynamic title area (adapts to screen & wraps safely)
                        const SizedBox(height: 6),
                        Padding(
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
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );

  }



  Widget _fallbackWidget() {
    return Container(
      color: AppColors.secondary,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.ic_no_image,
        width: 48,
        height: 48,
      ),
    );
  }
}
