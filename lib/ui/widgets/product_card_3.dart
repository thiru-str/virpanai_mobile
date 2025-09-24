import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

class ProductCard3 extends StatelessWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onAddToCart;

  const ProductCard3({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onAddToCart,
  }) : super(key: key);

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
    final calc = _lowestCalculated(product);
    final orig = _highestOriginal(product);
    final hasDiscount = _hasDiscount(orig, calc);
    final percentOff =
    (hasDiscount && orig != null && calc != null) ? _discountPercent(orig!, calc!) : null;

    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Image with "NEW" Tag ----
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Container(
                    height: 140,
                    color: Colors.grey[100],
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail??'',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorWidget: (c, u, e) =>
                      const ImageFallbackWidget(w: 80, h: 80),
                    ),
                  ),
                ),
                // "NEW" cut tag
                Positioned(
                  top: 0,
                  left: 0,
                  child: ClipPath(
                    clipper: _DiagonalClipper(),
                    child: Container(
                      width: 50,
                      height: 24,
                      color: Colors.green,
                      alignment: Alignment.center,
                      child: const Text(
                        "NEW",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ---- Rating with cut style ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.brown[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.brown),
                    const SizedBox(width: 4),
                    Text(
                      "${5 ?? 0} (${2 ?? 0})",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ---- Title ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                product.title ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // ---- Price Row ----
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
                  "$percentOff% OFF",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            // ---- Add to Cart Button ----
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.shopping_cart_outlined,
                      size: 16, color: Colors.brown),
                  label: const Text(
                    "ADD TO CART",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[50],
                    foregroundColor: Colors.brown,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Custom Clipper for NEW tag ----
class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 10, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


