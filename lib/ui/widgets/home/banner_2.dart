import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/item_video_tile.dart';
import 'package:waioz/utility/app_strings.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Banner2 extends StatelessWidget {
  final Content? content;

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
                  content?.layoutTitle ?? "",
                  style: FontUtils.secondaryFontStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor),
                ),
                Visibility(
                  visible: content?.layoutRedirectTitle?.isNotEmpty ?? false,
                  child: GestureDetector(
                    onTap: () {
                      RedirectUtils.handleContentRedirectViewAll(
                        context: context,
                        redirectData: content?.redirectData,
                      );
                    },
                    child: Text(
                      content?.layoutRedirectTitle ?? "",
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
              itemCount: content?.layoutData?.length ?? 0,
              shrinkWrap: true,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                LayoutDatum? layoutData = content?.layoutData?[index];
                return GestureDetector(
                    onTap: () {
                      RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content?.layoutOption ?? "",
                        layoutData: layoutData,
                      );
                    },
                    child: ItemVideoTile(
                      videoUrl: layoutData!.image!,
                      title: layoutData.subTitle!,
                    ));
              },
            ),
          )
        ],
      ),
    );
  }
}
