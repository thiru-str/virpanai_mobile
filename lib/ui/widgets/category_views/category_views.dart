import 'package:flutter/widgets.dart';
import 'package:waioz/model/product_categories_response.dart';

import 'category_grid_view.dart';
import 'category_list_view.dart';
import 'category_rail_view.dart';
import 'category_sections_view.dart';
import 'category_tabs_view.dart';
import 'category_view_shared.dart';

export 'category_view_shared.dart'
    show CategoryView, categoryViewFrom, categoryCoverImage;

/// The Categories tab body for the store's chosen [view].
Widget categoryViewBody(CategoryView view, List<ProductCategory> categories) {
  switch (view) {
    case CategoryView.categoryView2:
      return CategoryRailView(categories: categories);
    case CategoryView.categoryView3:
      return CategorySectionsView(categories: categories);
    case CategoryView.categoryView4:
      return CategoryListView(categories: categories);
    case CategoryView.categoryView5:
      return CategoryTabsView(categories: categories);
    case CategoryView.categoryView1:
      return CategoryGridView(categories: categories);
  }
}
