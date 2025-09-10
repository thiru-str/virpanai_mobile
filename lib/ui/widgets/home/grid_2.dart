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
                          fontSize: 15,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: MasonryGridView.count(
            crossAxisCount: 5,
            mainAxisSpacing: 16,
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
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CachedNetworkImage(
                          imageUrl: layoutData.image??'',
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _fallbackWidget(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 60,
                        height: MediaQuery.of(context).size.shortestSide < 360 ? 32 : 30,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            layoutData.title ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  )
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
