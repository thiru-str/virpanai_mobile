import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';

class SubCategoryPage extends StatefulWidget {
  final List<ProductCategory> productCategory;
  final String categoryTitle;

  const SubCategoryPage({super.key,required this.categoryTitle,required this.productCategory});

  @override
  State<SubCategoryPage> createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {

  ProductCategoriesResponse? productCategoriesResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
      title: Text('Categories',style: FontUtils.gabaritoStyle(fontWeight: FontWeight.bold,fontSize: 18),),centerTitle: true,),
      backgroundColor: Colors.white,
      body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('All categories > ${widget.categoryTitle}',style: FontUtils.circularStdStyle(fontSize: 16,color: AppColors.textColor)),
                ),
                const SizedBox(height: 10,),
                GridView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: widget.productCategory.length,
                  shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                  itemBuilder: (context, index) {
                    final productCategory =  widget.productCategory[index];
                    return GestureDetector(
                      onTap: () {},
                      child: CategoryCard(imagePath: productCategory.image??'', title: productCategory.name!, onTap: (
                          ){
                        PageRouteUtils.push(context, ProductPage());
                      }),
                    );
                  },
                ),
              ],
            ),
          )
    );
  }

}
