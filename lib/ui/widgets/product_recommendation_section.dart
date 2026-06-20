import 'package:flutter/material.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/product_view.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

class ProductRecommendationSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final Future<void> Function(Product product)? onReturnFromProductDetail;
  final bool isLoggedIn;
  final FavouriteListConfig? favConfig;
  final Set<String> savedProductIds;

  const ProductRecommendationSection({
    super.key,
    required this.title,
    required this.products,
    this.onReturnFromProductDetail,
    this.isLoggedIn = false,
    this.favConfig,
    this.savedProductIds = const {},
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            title,
            style: UiTypography.cardTitle(
              color: AppColors.textColor,
            ).copyWith(
              fontSize: 16,
            ),
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
                  child: ProductView(
                    product: product,
                    isLoggedIn: isLoggedIn,
                    favConfig: favConfig,
                    isFavorite: savedProductIds.contains(product.id ?? ''),
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
