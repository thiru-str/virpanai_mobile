import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import 'widgets/common_header_app_bar.dart';

class SubCategoryPage extends StatefulWidget {
  final List<ProductCategory> productCategory;
  final String categoryTitle;

  const SubCategoryPage(
      {super.key, required this.categoryTitle, required this.productCategory});

  @override
  State<SubCategoryPage> createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  ProductCategoriesResponse? productCategoriesResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeaderAppBar(
          title: AppStrings.categories,
          onBackTap: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('${AppStrings.all_category} > ',
                        style: FontUtils.primaryFontStyle(
                            fontSize: 16, color: AppColors.textColor)),
                    Text('${widget.categoryTitle}',
                        style: FontUtils.primaryFontStyle(
                            fontSize: 16, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  scrollDirection: Axis.vertical,
                  itemCount: widget.productCategory.length,
                  itemBuilder: (context, index) {
                    final productCategory = widget.productCategory[index];
                    return GestureDetector(
                      onTap: () {},
                      child: CategoryCard(
                          imagePath: productCategory.image ?? '',
                          title: productCategory.name!,
                          onTap: () {
                            PageRouteUtils.pushWithFade(
                                context,
                                ProductPage(
                                  categoryId: productCategory.id!,
                                ));
                          }),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
