import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_views/category_view_shared.dart';
import 'package:waioz/ui/widgets/floating_cart.dart';
import 'package:waioz/utility/app_strings.dart';

/// categoryView3: one long scroll. Each category with sub-categories is a
/// heading ("See all" opens everything under it) over a grid of its
/// sub-categories. Categories without sub-categories are gathered into one
/// grid at the end, or make up the whole page when the catalogue is flat.
class CategorySectionsView extends StatelessWidget {
  final List<ProductCategory> categories;
  const CategorySectionsView({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final grouped =
        categories.where((c) => categoryChildrenOf(c).isNotEmpty).toList();
    final single =
        categories.where((c) => categoryChildrenOf(c).isEmpty).toList();
    const columns = 4;

    Widget section(Widget heading, Widget grid) => Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [heading, const SizedBox(height: 12), grid],
          ),
        );

    return ColoredBox(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, FloatingCart.clearance),
        children: [
          for (final c in grouped)
            section(
              CategoryHeading(
                title: c.name ?? '',
                onSeeAll: () => openCategoryProducts(context, c),
              ),
              CategoryTileGrid(
                categories: categoryChildrenOf(c),
                columns: columns,
                spacing: 10,
                fontSize: 11.5,
              ),
            ),
          if (single.isNotEmpty)
            section(
              CategoryHeading(
                title: grouped.isEmpty
                    ? AppStrings.all_category
                    : 'More categories',
              ),
              CategoryTileGrid(
                categories: single,
                columns: columns,
                spacing: 10,
                fontSize: 11.5,
              ),
            ),
        ],
      ),
    );
  }
}
