import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Item7 extends StatelessWidget {
  final Content? content;

  const Item7({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  content?.layoutTitle ?? "",
                  style: FontUtils.secondaryFontStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor),
                ),
              ),
              Visibility(
                visible: content?.layoutRedirectTitle?.isNotEmpty ?? false,
                child: GestureDetector(
                  onTap: () {
                    RedirectUtils.handleContentRedirectViewAll(
                      context: context,
                      redirectData: content!.redirectData!,
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
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: content?.layoutData?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
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
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: layoutData!.image!,
                              fit: BoxFit.cover,
                               errorWidget: (context, url, error) =>
                                ImageFallbackWidget(
                              h: 120,
                            ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        layoutData.title ?? "",
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyUtil.appendCurrency(layoutData.subTitle ?? ""),
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
