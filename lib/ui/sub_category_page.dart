import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

import '../api/api_service.dart';

class SubCategoryPage extends StatefulWidget {
  final List<ProductCategory> productCategory;

  const SubCategoryPage({super.key,required this.productCategory});

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
            child: GridView.builder(
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
                  child: CategoryCard(imagePath: productCategory.image??'', title: productCategory.name!, onTap: (){
                  }),
                );
              },
            ),
          )
    );
  }

}
