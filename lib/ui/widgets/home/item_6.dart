import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Item6 extends StatelessWidget {
  final Content content;

  const Item6({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  content.layoutTitle!,
                  style: FontUtils.secondaryFontStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor
                  ),
                ),
                Visibility(
                  visible: content.layoutRedirectTitle!.isNotEmpty,
                  child: GestureDetector(
                    onTap: (){
                      RedirectUtils.handleContentRedirectViewAll(
                        context: context,
                        redirectData: content.redirectData!,
                      );
                    },
                    child: Text(
                      content.layoutRedirectTitle!,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: content.layoutData!.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
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
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration:  BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(child: CachedNetworkImage(imageUrl:layoutData.image!,fit: BoxFit.cover,),),
                        ),
                        const SizedBox(width: 8), // Horizontal spacing
                        Flexible( // Constrain the Text widget
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              layoutData.title!,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis, // Adds ellipsis
                            ),
                          ),
                        ),
                      ],
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

