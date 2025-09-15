import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

class ProductCard4 extends StatefulWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final VoidCallback? onAddToCart;
  final bool isFavorite;

  const ProductCard4({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.onAddToCart,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<ProductCard4> createState() => _ProductCard4State();
}

class _ProductCard4State extends State<ProductCard4> {
  int _currentIndex = 0;

  double? _lowestCalculated(Product p) {
    if (p.variants?.isEmpty ?? true) return null;
    final vals = p.variants!
        .map((v) => double.tryParse(
      v.calculatedPrice?.rawCalculatedAmount?.value ?? '',
    ))
        .whereType<double>()
        .toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a < b ? a : b);
  }

  double? _highestOriginal(Product p) {
    if (p.variants?.isEmpty ?? true) return null;
    final vals = p.variants!
        .map((v) => double.tryParse(
      v.calculatedPrice?.rawOriginalAmount?.value ?? '',
    ))
        .whereType<double>()
        .toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a > b ? a : b);
  }

  bool _hasDiscount(double? original, double? calc) {
    if (original == null || calc == null) return false;
    return original > calc;
  }

  int _discountPercent(double original, double calc) {
    final pct = ((original - calc) / original) * 100.0;
    return pct.round();
  }

  String _fmt(double v) => CurrencyUtil.appendCurrency(v.toStringAsFixed(0));

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images ?? [];
    final calc = _lowestCalculated(product);
    final orig = _highestOriginal(product);
    final hasDiscount = _hasDiscount(orig, calc);
    final percentOff =
    (hasDiscount && orig != null && calc != null) ? _discountPercent(orig!, calc!) : null;

    return GestureDetector(
      onTap: widget.onTapCard,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Image with ADD button + wishlist ----
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Container(
                    height: 140,
                    color: Colors.grey[100],
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
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          width: double.infinity,
                          errorWidget: (c, u, e) =>
                          const ImageFallbackWidget(w: 80, h: 80),
                        );
                      },
                    ),
                  ),
                ),

                // Wishlist button

                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: widget.onTapFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),


                // ADD button inside image container (Zepto style)
                // ADD button inside image container (Zepto style)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ElevatedButton(
                    onPressed: widget.onAddToCart,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // solid white
                      foregroundColor: MaterialStateProperty.all<Color>(AppColors.primary),   // red text/icon
                      overlayColor: MaterialStateProperty.all<Color>(AppColors.primary.withOpacity(0.1)), // ripple
                      shadowColor: MaterialStateProperty.all<Color>(Colors.transparent), // no shadow
                      surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
                      side: MaterialStateProperty.all<BorderSide>(
                        BorderSide(color: AppColors.primary, width: 1),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: MaterialStateProperty.all<double>(0),
                    ),
                    child: const Text(
                      "ADD",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),


              ],
            ),

            const SizedBox(height: 6),

            // ---- Price row ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    _fmt(calc ?? orig ?? 0),
                    style: const TextStyle(
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
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),

            if (percentOff != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: Text(
                  "SAVE ₹${(orig! - calc!).toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),

            // ---- Title ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Text(
                product.title ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

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

            // ---- Ratings row (instead of mins) ----

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      "${4.5} (${3})",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}



