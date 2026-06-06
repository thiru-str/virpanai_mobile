import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';
import 'wishlist_heart_button.dart';

class ProductCard1 extends StatefulWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final bool isFavorite;
  final bool isLoggedIn;
  /// wishlist_item.id when product's first variant is already saved
  final String? initialSavedId;

  const ProductCard1({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.isFavorite = false,
    this.isLoggedIn = false,
    this.initialSavedId,
  }) : super(key: key);

  @override
  State<ProductCard1> createState() => _ProductCard1State();
}

class _ProductCard1State extends State<ProductCard1> {
  int _currentIndex = 0;

  Variant? _cheapestVariant(Product p) {
    if (p.variants?.isEmpty ?? true) return null;

    Variant? cheapest;
    for (final v in p.variants!) {
      final calc = double.tryParse(v.calculatedPrice?.calculatedAmount?.toString() ?? '');
      if (calc == null) continue;
      if (cheapest == null) {
        cheapest = v;
      } else {
        final cheapestCalc = double.tryParse(cheapest.calculatedPrice?.calculatedAmount?.toString() ?? '') ?? double.infinity;
        if (calc < cheapestCalc) {
          cheapest = v;
        }
      }
    }
    return cheapest;
  }

  String _fmt(double v) => CurrencyUtil.appendCurrency(v.toStringAsFixed(0));

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images ?? [];
    final description = (product.description ?? '').trim();
    final cheapest = _cheapestVariant(product);

    final calc = cheapest != null
        ? double.tryParse(cheapest.calculatedPrice?.calculatedAmount?.toString() ?? '')
        : null;

    final orig = cheapest != null
        ? double.tryParse(cheapest.calculatedPrice?.originalAmount?.toString() ?? '')
        : null;

    final hasDiscount = (orig != null && calc != null && orig > calc);
    final percentOff = hasDiscount ? ((orig - calc) / orig * 100).round() : null;

    return GestureDetector(
      onTap: widget.onTapCard,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // Image carousel
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: SizedBox(
                    height: 225,
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: images[index].url ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (context, url, error) =>
                          const ImageFallbackWidget(w: 60, h: 60),
                        );
                      },
                    ),
                  ),
                ),

                if (images.length > 1)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(images.length, (index) {
                          final isActive = _currentIndex == index;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.black : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),


                // ✅ Brand tag top-left (flat left, rounded right)
                // Positioned(
                //   top: 8,
                //   left: 0,
                //   child: Container(
                //     padding:
                //     const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: const BoxDecoration(
                //       color: Colors.yellow,
                //       borderRadius: BorderRadius.only(
                //         topRight: Radius.circular(12),
                //         bottomRight: Radius.circular(12),
                //       ),
                //     ),
                //     child: Text(
                //       "Westside",
                //       style: const TextStyle(
                //         fontSize: 10,
                //         fontWeight: FontWeight.w500,
                //         color: Colors.black87,
                //       ),
                //     ),
                //   ),
                // ),

                // Wishlist heart — self-contained: tap → API → state.
                // Hidden for guests + when product has no variant.
                if (widget.isLoggedIn &&
                    (widget.product.variants?.isNotEmpty ?? false))
                  Positioned(
                    top: 8,
                    right: 8,
                    child: WishlistHeartButton(
                      variantId: widget.product.variants!.first.id ?? '',
                      productId: widget.product.id ?? '',
                      initialSavedId: widget.initialSavedId,
                      isLoggedIn: widget.isLoggedIn,
                      size: 18,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                product.title ?? '',
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Subtitle / Description
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2),
                child: Text(
                  description,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    color: AppColors.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Price row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fmt(calc ?? orig ?? 0),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  if (hasDiscount && orig != null) ...[
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _fmt(orig),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        if (percentOff != null)
                          Text(
                            '$percentOff% Off',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (!hasDiscount && percentOff != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$percentOff% Off',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Ratings row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "4.5",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.star, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "(23)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

}
