import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';

class Grid2 extends StatelessWidget {
  final Content? content;

  const Grid2({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<LayoutDatum>? items =
        content?.layoutData?.take(15).toList(); // Max 5x3 = 15 items

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                content?.layoutTitle ?? '',
                style: FontUtils.secondaryFontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Visibility(
                visible: (content?.layoutRedirectTitle ?? '').isNotEmpty,
                child: GestureDetector(
                  onTap: () {
                    // Handle section-level redirection if needed
                  },
                  child: Row(
                    children: [
                      Text(
                        content?.layoutRedirectTitle ?? "",
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
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items?.length ?? 0,
            itemBuilder: (context, index) {
              final layoutData = items?[index];
              return GestureDetector(
                onTap: () {
                  RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content?.layoutOption ?? "",
                    layoutData: layoutData,
                  );
                },
                child: Column(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CachedNetworkImage(
                        imageUrl: layoutData!.image!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            ImageFallbackWidget(
                          h: 60,
                          w: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      layoutData.title ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(fontSize: 11),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
