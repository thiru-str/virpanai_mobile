import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../../utility/app_utils.dart';

class Banner1 extends StatelessWidget {
  final Content content;

  const Banner1({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      child: Padding(
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
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: content.layoutData!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final layoutData = content.layoutData![index];
                  return GestureDetector(
                    onTap: () {
                      RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content.layoutOption!,
                        layoutData: layoutData,
                      );
                    },
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 150,
                              height: 150,
                              child: CachedNetworkImage(
                                imageUrl: layoutData.image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            layoutData.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
