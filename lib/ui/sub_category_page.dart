import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

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
        backgroundColor: const Color(0xFFF9F9FB),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(AppStrings.all_category,
                        style: UiTypography.cardMeta(color: Colors.grey.shade600)
                            .copyWith(fontSize: 14)),
                    Icon(Icons.chevron_right,
                        size: 18, color: Colors.grey.shade400),
                    Text(widget.categoryTitle,
                        style: UiTypography.cardTitle().copyWith(
                          fontSize: 20,
                          height: 1.25,
                          letterSpacing: -0.2,
                          color: AppColors.primary,
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 14,
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
