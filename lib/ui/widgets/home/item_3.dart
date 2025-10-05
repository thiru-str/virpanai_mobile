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

class Item3 extends StatelessWidget {
  final Content? content;

  const Item3({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
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
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: content?.layoutData?.length ?? 0,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                LayoutDatum? layoutData = content?.layoutData?[index];
                return GestureDetector(
                  onTap: () {
                    RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: content?.layoutOption ?? "",
                      layoutData: layoutData!,
                    );
                  },
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: (layoutData?.image == null ||
                                    (layoutData?.image?.isEmpty ?? false))
                                ? ImageFallbackWidget(h: 75, w: 75)
                                : CachedNetworkImage(
                                    imageUrl: layoutData!.image!,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        ImageFallbackWidget(h: 75, w: 75),
                                  ),
                          ),
                        ),
                        // ),
                        const SizedBox(height: 8),
                        Text(
                          textAlign: TextAlign.center,
                          layoutData?.title ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
