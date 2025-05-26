import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../../model/home_page_response.dart';
import '../../../utility/page_route_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Item3 extends StatelessWidget {
  final Content content;

  const Item3({
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
              Text(
                content.layoutTitle!,
                style: FontUtils.secondaryFontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor
                ),
              ),
              if (content.layoutRedirectTitle!.isNotEmpty)
                GestureDetector(
                  onTap: (){

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
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: content.layoutData!.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              LayoutDatum layoutData = content.layoutData![index];
              return GestureDetector(
                onTap: () {
                  if ((content.layoutOption== 'Custom') && layoutData.redirectData?.redirectType == 'Search') {
                    PageRouteUtils.pushWithSlide(
                      context,
                      ProductPage(
                        categoryId: layoutData.redirectData?.redirectSearchData?.category ?? '',
                      ),
                    );
                  }
                  else {
                    switch (content.layoutOption!) {
                      case AppStrings.category:
                        PageRouteUtils.pushWithFade(
                            context, ProductPage(categoryId: layoutData.id!));
                      case AppStrings.product:
                        PageRouteUtils.pushWithSlide(context,
                            ProductDetailPage(productId: layoutData.id!));
                      case AppStrings.brand:
                        PageRouteUtils.pushWithSlide(context, ProductPage(
                          categoryId: layoutData.id!, isFromBrand: true,));
                      case AppStrings.custom:
                        switch (layoutData.redirectData?.redirectType) {
                          case AppStrings.reDirectSearch:
                            PageRouteUtils.pushWithSlide(
                              context,
                              ProductPage(
                                categoryId: layoutData.redirectData
                                        ?.redirectSearchData?.category ??
                                    '',
                              ),
                            );
                          case AppStrings.reDirectProduct:
                            PageRouteUtils.pushWithSlide(
                              context,
                              ProductDetailPage(
                                productId: layoutData.redirectData
                                        ?.redirectProductData?.productId ??
                                    '',
                              ),
                            );
                          case AppStrings.reDirectLink:
                            launchExternalBrowser(layoutData.redirectData?.redirectUrlData?.url??'');
                        }
                    }
                  }
                },
                child: SizedBox(
                  width: 70,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 80,
                        child: CachedNetworkImage(imageUrl: layoutData.image!,fit: BoxFit.cover,),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        layoutData.title!,
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
    );
  }

  Future<void> launchExternalBrowser(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // This opens in external browser
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
