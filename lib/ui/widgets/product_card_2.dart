import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

class ProductCard2 extends StatefulWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final VoidCallback? onAddToCart;
  final bool isFavorite;

  const ProductCard2({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.onAddToCart,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<ProductCard2> createState() => _ProductCard2State();
}

class _ProductCard2State extends State<ProductCard2> {

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
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // ---- Image / Carousel ----
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 160,
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

                // ---- Discount Badge ----
                // ---- Discount Badge ----
                if (percentOff != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: const ShapeDecoration(
                        color: Colors.indigo,
                        shape: StarBorder.polygon(
                          sides: 10, // makes a scalloped/seal-like shape
                          pointRounding: 0.1, // controls curve softness
                        ),
                      ),
                      child: Text(
                        "$percentOff%\nOFF",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),


                // ---- Wishlist ----
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onTapFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
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

            // ---- Title ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                product.title ?? "Write A Title Here",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ---- Subtitle ----
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Text(
                product.description ?? "Add a short section",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ---- Price ----
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                _fmt(calc ?? orig ?? 0),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),

            // ---- Ratings ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: List.generate(5, (index) {
                  double rating = 3.0 ?? 3.0;
                  return Icon(
                    index < rating.floor()
                        ? Icons.star
                        : (index < rating ? Icons.star_half : Icons.star_border),
                    color: AppColors.primary,
                    size: 16,
                  );
                }),
              ),
            ),

            const SizedBox(height: 8),

            // ---- Add to Cart ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onAddToCart,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Add To Cart",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
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

