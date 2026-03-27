import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../model/block_config.dart';
import '../../../widgets/product_view.dart';
import '../../../widgets/app_shimmer.dart';

/// ProductGrid1 - Default masonry grid layout.
/// Extracted from product_page.dart product grid section
class ProductGrid1Widget extends StatelessWidget {
  final List<dynamic> products;
  final bool isLoading;
  final bool isPaginating;
  final ScrollController scrollController;
  final Function(dynamic product)? onProductTap;
  final BlockConfig config;

  const ProductGrid1Widget({
    super.key,
    required this.products,
    required this.isLoading,
    required this.isPaginating,
    required this.scrollController,
    required this.config,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final columns = config.getInt('columns', defaultValue: 2);

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.count(
          crossAxisCount: columns,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context, index) => AppShimmer(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No Products',
                style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        controller: scrollController,
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: products.length + (isPaginating ? columns : 0),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            return AppShimmer(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }

          final product = products[index];
          return AppReveal(
            index: index,
            child: ProductView(
              product: product,
              onTapCard: () => onProductTap?.call(product),
            ),
          );
        },
      ),
    );
  }
}
