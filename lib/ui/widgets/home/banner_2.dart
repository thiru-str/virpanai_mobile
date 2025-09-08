import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/item_video_tile.dart';
import 'package:waioz/utility/app_strings.dart';

import '../../../utility/app_assets.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Banner2 extends StatelessWidget {
  final Content content;

  const Banner2({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  content.layoutTitle??'',
                  style: FontUtils.secondaryFontStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor),
                ),
                Visibility(
                  visible: (content.layoutRedirectTitle??'').isNotEmpty,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      content.layoutRedirectTitle??'',
                      style: FontUtils.primaryFontStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor),
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
              itemCount: content.layoutData?.length ?? 0,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final layoutData = content.layoutData?[index];
                final mediaUrl = layoutData?.image ?? '';
                final isVideo = mediaUrl.toLowerCase().endsWith('.mp4');

                return GestureDetector(
                  onTap: () {
                    RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: content.layoutOption??'',
                      layoutData: layoutData!,
                    );
                  },
                  child: isVideo
                      ? ItemVideoTile(
                    videoUrl: mediaUrl,
                    title: layoutData?.subTitle ?? '',
                  )
                      : SizedBox(
                    width: 160,
                    child: mediaUrl.isEmpty
                        ?  const ImageFallbackWidget(h: 160, w:180) // empty → fallback
                        : CachedNetworkImage(
                      imageUrl: mediaUrl,
                      fit: BoxFit.cover,
                      width: 160,
                      height: 180,
                      errorWidget: (context, url, error) =>
                          const ImageFallbackWidget(h: 160, w:180),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
