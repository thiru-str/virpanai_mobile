import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/sub_category_page.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import 'widgets/common_header_app_bar.dart';

class CategoryPage extends StatefulWidget {
  final bool isFromBottomNav;
  const CategoryPage({super.key,this.isFromBottomNav = false});

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
      appBar:
      CommonHeaderAppBar(
        title: "Categories",
        leading: widget.isFromBottomNav ? false : true,
        onBackTap: () {
          Navigator.pop(context,true);
        },
      ),
      backgroundColor: Colors.white,
      body: apiLoading? const Center(child: CircularProgressIndicator(color: AppColors.primary,),)
          :Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('All categories',style: FontUtils.circularStdStyle(fontSize: 16,color: AppColors.textColor)),
                ),
                const SizedBox(height: 10,),
                Expanded(
                  child: GridView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount:
                            productCategoriesResponse!.productCategories!.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                        ),
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
                                      ));
                                }
                                else{
                                  PageRouteUtils.pushWithFade(context, ProductPage(categoryId: productCategory.id!,));
                                }
                              });
                        },
                      ),
                ),
                  ],
            ),
          )
    );
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
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
