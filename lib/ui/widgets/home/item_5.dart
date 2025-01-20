import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Item5 extends StatelessWidget {
  final Content content;

  const Item5({
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
                style: FontUtils.gabaritoStyle(
                    fontSize: 16,
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
                    style: FontUtils.circularStdStyle(
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
          height: 350,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: content.layoutData!.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              LayoutDatum layoutData = content.layoutData![index];
              return GestureDetector(
                onTap: () {
                  switch (content.layoutOption!) {
                    case "Category":
                      PageRouteUtils.pushWithFade(context, ProductPage(categoryId: layoutData.id!));
                    case "Product":
                      PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: layoutData.id!));
                    case "Brand":
                      PageRouteUtils.pushWithSlide(context, ProductPage(categoryId: layoutData.id!,isFromBrand: true,));
                  }
                },
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 280,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(layoutData.image!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          layoutData.title!,
                          style: FontUtils.circularStdStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          CurrencyUtil.appendCurrency(layoutData.subTitle!),
                          style: FontUtils.circularStdStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
