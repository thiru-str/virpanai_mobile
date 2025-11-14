import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

class ProductCard1 extends StatefulWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final bool isFavorite;

  const ProductCard1({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.isFavorite = false,
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
      final calc = double.tryParse(v.calculatedPrice?.rawCalculatedAmount?.value ?? '');
      if (calc == null) continue;
      if (cheapest == null) {
        cheapest = v;
      } else {
        final cheapestCalc = double.tryParse(cheapest.calculatedPrice?.rawCalculatedAmount?.value ?? '') ?? double.infinity;
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
    final cheapest = _cheapestVariant(product);

    final calc = cheapest != null
        ? double.tryParse(cheapest.calculatedPrice?.rawCalculatedAmount?.value ?? '')
        : null;

    final orig = cheapest != null
        ? double.tryParse(cheapest.calculatedPrice?.rawOriginalAmount?.value ?? '')
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
                Positioned(
                  top: 8,
                  left: 0,
                  child: Visibility(
                    visible: false,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Westside",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),

                // ✅ Wishlist button top-right
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onTapFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color:
                        widget.isFavorite ? Colors.red : Colors.grey[700],
                      ),
                    ),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Subtitle / Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Text(
                product.description ?? '',
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
              child: Row(
                children: [
                  Text(
                    _fmt(calc ?? orig ?? 0),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (hasDiscount && orig != null)
                    Text(
                      _fmt(orig),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (percentOff != null) ...[
                    const SizedBox(width: 6),
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


