import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/sub_category_page.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../api/api_service.dart';
import 'widgets/common_header_app_bar.dart';

class CategoryPage extends StatefulWidget {
  final bool isFromBottomNav;
  const CategoryPage({super.key, this.isFromBottomNav = false});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  ProductCategoriesResponse? productCategoriesResponse;
  bool apiLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategoriesApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeaderAppBar(
          title: AppStrings.categories,
          leading: widget.isFromBottomNav ? false : true,
          onBackTap: () {
            Navigator.pop(context, true);
          },
        ),
        backgroundColor: const Color(0xFFF9F9FB),
        body: apiLoading
            ? const CategoryPageSkeleton()
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(AppStrings.all_category,
                          style: UiTypography.cardTitle().copyWith(
                            fontSize: 20,
                            height: 1.25,
                            letterSpacing: -0.2,
                          )),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Expanded(
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        itemCount: productCategoriesResponse!
                            .productCategories!.length,
                        itemBuilder: (context, index) {
                          final productCategory = productCategoriesResponse!
                              .productCategories![index];

                          return CategoryCard(
                            imagePath: productCategory.image ?? '',
                            title: productCategory.name!,
                            onTap: () {
                              if (productCategory
                                  .categoryChildren!.isNotEmpty) {
                                PageRouteUtils.pushWithFade(
                                  context,
                                  SubCategoryPage(
                                    categoryTitle: productCategory.name!,
                                    productCategory:
                                        productCategory.categoryChildren!,
                                  ),
                                );
                              } else {
                                PageRouteUtils.pushWithFade(
                                  context,
                                  ProductPage(categoryId: productCategory.id!),
                                );
                              }
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ));
  }

  void getCategoriesApi() async {
    try {
      final ApiService apiService = ApiService();
      productCategoriesResponse = await apiService.productCategories(context);
      setState(() {
        apiLoading = false;
        productCategoriesResponse;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
