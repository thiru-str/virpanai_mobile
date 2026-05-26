import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/sub_category_page.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';

import '../api/api_service.dart';
import '../model/product_categories_response.dart';
import '../utility/app_colors.dart';
import '../utility/app_strings.dart';
import '../utility/font_utils.dart';
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
      backgroundColor: const Color(0xFFF9F9FB),
      body: apiLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT MAIN CATEGORY LIST
                Container(
                  width: 112,
                  color: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF9F9FB)
                                : Colors.white,
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (mainCategory.image != null &&
                                  mainCategory.image!.isNotEmpty)
                                Container(
                                  height: 48,
                                  width: 48,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.08)
                                        : const Color(0xFFF4F4F4),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: CachedNetworkImage(
                                      imageUrl: mainCategory.image!,
                                      fit: BoxFit.contain),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                mainCategory.name ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(width: 1, color: const Color(0xFFE5E7EC)),

                // RIGHT SUBCATEGORY GRID
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Builder(
                      builder: (_) {
                        final selectedCategory = productCategoriesResponse!
                            .productCategories![selectedIndex];

                        final subCategories =
                            selectedCategory.categoryChildren ?? [];

                        if (subCategories.isEmpty) {
                          return Center(
                            child: Text(
                              AppStrings.no_subcategories_found,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        }

                        return MasonryGridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
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
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rounded image surface (premium card)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: AspectRatio(
              aspectRatio: 1,
              child: imagePath.isNotEmpty
                  ? CachedNetworkImage(imageUrl: imagePath, fit: BoxFit.contain)
                  : Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 10),

          // Title outside container
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
