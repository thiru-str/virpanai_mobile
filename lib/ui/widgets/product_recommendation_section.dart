import 'package:flutter/material.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/product_card_4.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

class ProductRecommendationSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final Future<void> Function(Product product)? onReturnFromProductDetail;

  const ProductRecommendationSection({
    super.key,
    required this.title,
    required this.products,
    this.onReturnFromProductDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: FontUtils.secondaryFontStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              products.length,
              (index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ProductCard4(
                    product: product,
                    onTapCard: () async {
                      await PageRouteUtils.pushWithSlide(
                        context,
                        ProductDetailPage(productId: product.id ?? ''),
                      );
                      if (onReturnFromProductDetail != null) {
                        await onReturnFromProductDetail!(product);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
