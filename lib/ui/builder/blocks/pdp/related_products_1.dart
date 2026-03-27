import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';
import '../../../widgets/product_view.dart';

/// RelatedProducts1 - Horizontal scroll of related product cards.
/// Extracted from product_detail_page.dart buildRelatedProducts()
class RelatedProducts1Widget extends StatelessWidget {
  final List<dynamic> products; // Product objects from RelatedProductsResponse
  final Function(String productId)? onProductTap;
  final BlockConfig config;

  const RelatedProducts1Widget({
    super.key,
    required this.products,
    required this.config,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final title = config.getString('title', defaultValue: 'You may also like');
    final count = config.getInt('count', defaultValue: 6);
    final displayProducts = products.take(count).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: FontUtils.primaryFontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: displayProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = displayProducts[index];
                return SizedBox(
                  width: 160,
                  child: ProductView(
                    product: product,
                    onTapCard: () {
                      onProductTap?.call(product.id ?? '');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
