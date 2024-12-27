import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../api/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
      appBar: AppBar(backgroundColor: Colors.white,
      title: Text('Categories',style: FontUtils.gabaritoStyle(fontWeight: FontWeight.bold,fontSize: 18),),centerTitle: true,),
      backgroundColor: Colors.white,
      body: apiLoading? const Center(child: CircularProgressIndicator(color: AppColors.primary,),)
          :Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              itemCount: productCategoriesResponse!.productCategories!.length,
              shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
              itemBuilder: (context, index) {
                final productCategory = productCategoriesResponse!.productCategories![index];
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
