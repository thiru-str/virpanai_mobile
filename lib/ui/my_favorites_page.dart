import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/product_card.dart';

import '../utility/app_colors.dart';
import '../utility/app_strings.dart';

class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {

  bool apiLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.my_favorites,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: apiLoading? const Center(child: CircularProgressIndicator(color: AppColors.primary,),)
          :Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          itemCount: 2,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            // final productCategory = productCategoriesResponse!.productCategories![index];
            return GestureDetector(
              onTap: () {},
              child: ProductCard(imageUrl: "imageUrl", title: "title", price: "200", onTapFavorite: (){
              }, onTapCard: (){
              }),
            );
          },
        ),
      ),
    );
  }
}
