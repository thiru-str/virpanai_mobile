import 'package:cached_network_image/cached_network_image.dart';
import 'package:waioz/ui/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/sub_category_page.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';

import '../api/api_service.dart';
import '../model/product_categories_response.dart';
import '../utility/app_colors.dart';
import '../utility/app_strings.dart';
import '../utility/page_route_utils.dart';

class CategoryPage1 extends StatefulWidget {
  final bool isFromBottomNav;
  const CategoryPage1({super.key, this.isFromBottomNav = false});

  @override
  State<CategoryPage1> createState() => _CategoryPage1State();
}

class _CategoryPage1State extends State<CategoryPage1> {
  ProductCategoriesResponse? productCategoriesResponse;
  bool apiLoading = true;
  int selectedIndex = 0; // Track which main category is selected

  @override
  void initState() {
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
      backgroundColor: Colors.white,
      body: apiLoading
          ? const AppLoader()
          : Row(
              children: [
                // LEFT MAIN CATEGORY LIST
                Container(
                  width: 100,
                  color: Color(0xFFF5FEF2),
                  child: ListView.builder(
                    itemCount:
                        productCategoriesResponse!.productCategories!.length,
                    itemBuilder: (context, index) {
                      final mainCategory =
                          productCategoriesResponse!.productCategories![index];
                      final isSelected = index == selectedIndex;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Color(0xFFF5FEF2),
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 4, // Blue indicator width
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (mainCategory.image != null &&
                                  mainCategory.image!.isNotEmpty)
                                CachedNetworkImage(
                                    imageUrl: mainCategory.image!,
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain),
                              const SizedBox(height: 6),
                              Text(
                                mainCategory.name ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // RIGHT SUBCATEGORY GRID
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Builder(
                      builder: (_) {
                        final selectedCategory = productCategoriesResponse!
                            .productCategories![selectedIndex];

                        final subCategories =
                            selectedCategory.categoryChildren ?? [];

                        if (subCategories.isEmpty) {
                          return Center(
                            child: Text(AppStrings.no_subcategories_found),
                          );
                        }

                        return MasonryGridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          itemCount: subCategories.length,
                          itemBuilder: (context, index) {
                            final subCategory = subCategories[index];

                            return SubCategoryTile(
                              imagePath: subCategory.image ?? '',
                              title: subCategory.name ?? '',
                              onTap: () {
                                if (subCategory.categoryChildren != null &&
                                    subCategory.categoryChildren!.isNotEmpty) {
                                  PageRouteUtils.pushWithFade(
                                    context,
                                    SubCategoryPage(
                                      categoryTitle: subCategory.name!,
                                      productCategory:
                                          subCategory.categoryChildren!,
                                    ),
                                  );
                                } else {
                                  PageRouteUtils.pushWithFade(
                                    context,
                                    ProductPage(categoryId: subCategory.id!),
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
    );
  }

  void getCategoriesApi() async {
    try {
      final ApiService apiService = ApiService();
      productCategoriesResponse = await apiService.productCategories(context);
      setState(() {
        apiLoading = false;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}

class SubCategoryTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const SubCategoryTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grey Rounded Image Container
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5FEF2), // light grey background
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 70,
              width: 70,
              child: imagePath.isNotEmpty
                  ? CachedNetworkImage(imageUrl: imagePath, fit: BoxFit.contain)
                  : const Icon(Icons.image_not_supported, size: 40),
            ),
          ),
          const SizedBox(height: 6),

          // Title outside container
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
