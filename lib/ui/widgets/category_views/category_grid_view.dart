import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/ui/widgets/category_views/category_view_shared.dart';
import 'package:waioz/ui/widgets/floating_cart.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/ui_typography.dart';

/// categoryView1: two columns of cover cards. The original Categories page,
/// and the layout every store gets until it picks another.
class CategoryGridView extends StatelessWidget {
  final List<ProductCategory> categories;
  const CategoryGridView({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          const SizedBox(height: 14),
          Expanded(
            child: MasonryGridView.count(
              padding: const EdgeInsets.only(bottom: FloatingCart.clearance),
              crossAxisCount: 2,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final c = categories[index];
                return CategoryCard(
                  imagePath: categoryCoverImage(c),
                  title: c.name ?? '',
                  onTap: () => openCategory(context, c),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
