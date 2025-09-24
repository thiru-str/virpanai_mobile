import 'dart:math';
import 'package:flutter/material.dart';

import '../model/product_categories_response.dart';

import 'dart:math';
import 'package:flutter/material.dart';

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

class CategoryPage2 extends StatefulWidget {
  final bool isFromBottomNav;
  const CategoryPage2({super.key, this.isFromBottomNav = false});

  @override
  State<CategoryPage2> createState() => _CategoryPage2State();
}

class _CategoryPage2State extends State<CategoryPage2> {
  ProductCategoriesResponse? productCategoriesResponse;
  bool apiLoading = true;

  @override
  void initState() {
    super.initState();
    getCategoriesApi();
  }

  // Randomized background colors for parent sections
  int _currentColorIndex = 0;

  Color getRandomBgColor() {
    final colors = [
      Colors.orange.shade100,
      Colors.pink.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.purple.shade100,
      Colors.red.shade100,
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
      backgroundColor: Colors.white,
      body: apiLoading
          ? Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Horizontal parent list
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                productCategoriesResponse!.productCategories!.length,
                itemBuilder: (context, index) {
                  final parent =
                  productCategoriesResponse!.productCategories![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
                      onTap: () {
                        if (parent.categoryChildren != null &&
                            parent.categoryChildren!.isNotEmpty) {
                          PageRouteUtils.pushWithFade(
                            context,
                            SubCategoryPage(
                              categoryTitle: parent.name!,
                              productCategory: parent.categoryChildren!,
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
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade200,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: parent.image != null &&
                                parent.image!.isNotEmpty
                                ? Image.network(parent.image!,
                                fit: BoxFit.cover)
                                : const Icon(Icons.image_not_supported),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 70,
                            child: Text(
                              parent.name ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
              children: productCategoriesResponse!.productCategories!.map((parent) {
                final bgColor = getRandomBgColor();
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Parent Title inside top-right
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          parent.name ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// Subcategories horizontal list
                      SizedBox(
                        height: 140, // taller so image + text fit inside
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: parent.categoryChildren?.length ?? 0,
                          itemBuilder: (context, index) {
                            final sub = parent.categoryChildren![index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: InkWell(
                                onTap: () {
                                  if (sub.categoryChildren != null &&
                                      sub.categoryChildren!.isNotEmpty) {
                                    PageRouteUtils.pushWithFade(
                                      context,
                                      SubCategoryPage(
                                        categoryTitle: sub.name!,
                                        productCategory: sub.categoryChildren!,
                                      ),
                                    );
                                  } else {
                                    PageRouteUtils.pushWithFade(
                                      context,
                                      ProductPage(categoryId: sub.id!),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: sub.image != null &&
                                            sub.image!.isNotEmpty
                                            ? Image.network(sub.image!,
                                            fit: BoxFit.contain)
                                            : const Icon(Icons.image_not_supported),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        sub.name ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
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

