import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';
import 'cms_text_color.dart';

class Item7 extends StatelessWidget {
  final Content content;

  const Item7({Key? key, required this.content}) : super(key: key);

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
            // 🔹 Title + redirect (same as Item3)
            Visibility(
              visible: content.layoutTitle?.isNotEmpty == true,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        content.layoutTitle ?? "",
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cmsCardText(context, AppColors.textColor),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if ((content.layoutRedirectTitle ?? "").isNotEmpty)
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
                              content.layoutRedirectTitle ?? "",
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                color: cmsCardText(context, AppColors.textColor),
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 🔹 Auto-height horizontal scroll (new)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(
                  content.layoutData?.length ?? 0,
                  (index) {
                    final layoutData = content.layoutData![index];
                    return GestureDetector(
                      onTap: () {
                        RedirectUtils.handleContentRedirect(
                          context: context,
                          layoutOption: content.layoutOption!,
                          layoutData: layoutData,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right:
                              index == content.layoutData!.length - 1 ? 0 : 16,
                        ),
                        child: _Item7Card(layoutData: layoutData),
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

class _Item7Card extends StatelessWidget {
  final LayoutDatum layoutData;

  const _Item7Card({Key? key, required this.layoutData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? "";

    return Container(
      width: 150, // You can also make this dynamic if needed
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipOval(
              child: Container(
                width: 60,
                height: 60,
                color: cmsCard(context, Colors.white),
                child: imageUrl.isNotEmpty
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
          Text(
            layoutData.title ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cmsCardText(context, AppColors.textColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            layoutData.subTitle ?? "",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
              fontSize: 13,
              color: cmsCardText(context, AppColors.textColor).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
