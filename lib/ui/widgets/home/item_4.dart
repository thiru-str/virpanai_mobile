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

class Item4 extends StatelessWidget {
  final Content? content;

  const Item4({
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
            height: 320,
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
                      layoutData: layoutData,
                    );
                  },
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                                height: 230,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: CachedNetworkImage(
                                    imageUrl: layoutData!.image!,
                                    height: 230,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: ImageFallbackWidget(
                                        h: 120,
                                      ),
                                    ),
                                  ),
                                )
                                ),
                            Visibility(
                              visible: layoutData.prices != null &&
                                  layoutData.prices?.discountedPrice != null &&
                                  layoutData.prices?.discountedPrice != "0",
                              child: Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 6),
                                  decoration: const BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: RotatedBox(
                                    quarterTurns: -1,
                                    child: Text(
                                      layoutData.prices?.discountPercentage ??
                                          "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            layoutData.title ?? "",
                            style: FontUtils.primaryFontStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                CurrencyUtil.appendCurrency(
                                    layoutData.prices?.sellingPrice ?? ""),
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Visibility(
                                visible: layoutData.prices != null &&
                                    layoutData.prices?.discountedPrice !=
                                        null &&
                                    layoutData.prices?.discountedPrice != "0",
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    CurrencyUtil.appendCurrency(
                                        layoutData.prices?.originalPrice ?? ""),
                                    style: FontUtils.primaryFontStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          AppColors.textColor.withOpacity(0.6),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}
