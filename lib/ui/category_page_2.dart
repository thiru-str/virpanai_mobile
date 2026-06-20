import 'package:cached_network_image/cached_network_image.dart';
import 'package:waioz/ui/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/sub_category_page.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';

import '../api/api_service.dart';
import '../model/product_categories_response.dart';
import '../utility/app_assets.dart';
import '../utility/app_colors.dart';
import '../utility/app_strings.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';
import '../utility/ui_typography.dart';

class CategoryPage2 extends StatefulWidget {
  final bool isFromBottomNav;
  const CategoryPage2({super.key, this.isFromBottomNav = false});

  @override
  State<CategoryPage2> createState() => _CategoryPage2State();
}

class _CategoryPage2State extends State<CategoryPage2> {
  ProductCategoriesResponse? productCategoriesResponse;
  bool apiLoading = true;

  List<ProductCategory> get _categories =>
      productCategoriesResponse?.productCategories ?? const <ProductCategory>[];

  @override
  void initState() {
    super.initState();
    getCategoriesApi();
  }

  // Toned, consistent section surfaces (softened from harsh random colors
  // for legibility). Very low-saturation tints that read as a single calm
  // surface family.
  int _currentColorIndex = 0;

  Color getRandomBgColor() {
    const colors = [
      Color(0xFFF3F0FB), // soft lavender (primary family)
      Color(0xFFEFF4FB), // soft blue
      Color(0xFFEFF7F2), // soft green
      Color(0xFFFBF2EF), // soft peach
      Color(0xFFF6F0F7), // soft mauve
      Color(0xFFF1F4F8), // soft slate
    ];

    final color = colors[_currentColorIndex];
    _currentColorIndex = (_currentColorIndex + 1) % colors.length;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeaderAppBar(
        title: AppStrings.categories,
        leading: widget.isFromBottomNav ? false : true,
        onBackTap: () => Navigator.pop(context, true),
      ),
      backgroundColor: const Color(0xFFF9F9FB),
      body: apiLoading
          ? const AppLoader()
          : _categories.isEmpty
              ? NoOrdersWidget(
                  message: AppStrings.no_categories_found,
                  buttonText: AppStrings.explore_categories,
                  iconPath: AppAssets.ic_cart_empty,
                  showExplore: widget.isFromBottomNav,
                  onButtonTap: () {},
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      /// 1. Horizontal parent list
                      SizedBox(
                        height: 124,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final parent = _categories[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: InkWell(
                                onTap: () {
                                  if (parent.categoryChildren != null &&
                                      parent.categoryChildren!.isNotEmpty) {
                                    PageRouteUtils.pushWithFade(
                                      context,
                                      SubCategoryPage(
                                        categoryTitle: parent.name!,
                                        productCategory:
                                            parent.categoryChildren!,
                                      ),
                                    );
                                  } else {
                                    PageRouteUtils.pushWithFade(
                                      context,
                                      ProductPage(categoryId: parent.id!),
                                    );
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 72,
                                      width: 72,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 18,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: parent.image != null &&
                                              parent.image!.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: parent.image!,
                                              fit: BoxFit.cover)
                                          : Icon(Icons.image_not_supported,
                                              color: Colors.grey.shade400),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 76,
                                      child: Text(
                                        parent.name ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: FontUtils.primaryFontStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 2. Vertical parent sections

                      Column(
                        children: _categories.map((parent) {
                          final bgColor = getRandomBgColor();
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Parent Title
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    parent.name ?? '',
                                    style: UiTypography.cardTitle().copyWith(
                                      fontSize: 18,
                                      height: 1.25,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                /// Subcategories horizontal list
                                SizedBox(
                                  height:
                                      148, // taller so image + text fit inside
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    itemCount:
                                        parent.categoryChildren?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      final sub =
                                          parent.categoryChildren![index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: InkWell(
                                          onTap: () {
                                            if (sub.categoryChildren != null &&
                                                sub.categoryChildren!
                                                    .isNotEmpty) {
                                              PageRouteUtils.pushWithFade(
                                                context,
                                                SubCategoryPage(
                                                  categoryTitle: sub.name!,
                                                  productCategory:
                                                      sub.categoryChildren!,
                                                ),
                                              );
                                            } else {
                                              PageRouteUtils.pushWithFade(
                                                context,
                                                ProductPage(
                                                    categoryId: sub.id!),
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 98,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 18,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: sub.image != null &&
                                                          sub.image!.isNotEmpty
                                                      ? CachedNetworkImage(
                                                          imageUrl: sub.image!,
                                                          fit: BoxFit.contain)
                                                      : Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          color: Colors
                                                              .grey.shade400),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  sub.name ?? '',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: FontUtils
                                                      .primaryFontStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
