import 'package:flutter/material.dart';
import '../../model/block_config.dart';
import 'block_dispatcher.dart';
import 'blocks/plp/search_bar_1.dart';
import 'blocks/plp/product_grid_1.dart';

/// Dispatches PLP blocks to their component widgets.
class PlpBlockDispatcher extends BlockDispatcher {
  // Search state
  TextEditingController searchController = TextEditingController();
  Function(String)? onSearchChanged;
  VoidCallback? onFilterTap;
  bool isFilterApplied = false;

  // Grid state
  List<dynamic> products = [];
  bool isLoading = false;
  bool isPaginating = false;
  ScrollController scrollController = ScrollController();
  Function(dynamic)? onProductTap;

  @override
  Widget buildBlock(BlockConfig block) {
    switch (block.component) {
      case 'SearchBar1':
        return SearchBar1Widget(
          controller: searchController,
          onChanged: onSearchChanged ?? (_) {},
          onFilterTap: onFilterTap,
          isFilterApplied: isFilterApplied,
          config: block,
        );

      case 'FilterBar1':
        // FilterBar is currently handled by the filter page navigation
        // This block enables/disables the filter button in SearchBar
        return const SizedBox.shrink();

      case 'SortBar1':
        // Sort is currently handled inside the filter page
        return const SizedBox.shrink();

      case 'ProductGrid1':
        return Expanded(
          child: ProductGrid1Widget(
            products: products,
            isLoading: isLoading,
            isPaginating: isPaginating,
            scrollController: scrollController,
            onProductTap: onProductTap,
            config: block,
          ),
        );

      case 'EmptyState1':
        // Handled inside ProductGrid1Widget when products is empty
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }
}
