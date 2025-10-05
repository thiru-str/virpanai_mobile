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
  final Content? content;

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
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: content?.layoutData?.length ?? 0,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final layoutData = content?.layoutData?[index];
              return GestureDetector(
                onTap: () {
                  RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content?.layoutOption ?? "",
                    layoutData: layoutData,
                  );
                },
                child: SizedBox(
                  width: 90,
                  height: 120, // extra height to accommodate badge + image
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Rounded card with image & title
                      Positioned(
                        top: 10, // Push image down to leave space for badge
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: layoutData!.image!,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                  const    ImageFallbackWidget(
                                    h: 80,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              layoutData.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: FontUtils.primaryFontStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Discount badge floating on top
                      if (layoutData.prices != null &&
                          layoutData.prices?.discountedPrice != null &&
                          layoutData.prices?.discountedPrice != "0")
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade800,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            layoutData.prices?.discountPercentage ?? '',
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
            },
          ),
        ),
      ],
    );
  }
}
