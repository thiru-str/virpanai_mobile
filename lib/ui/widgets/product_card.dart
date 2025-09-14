import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final bool isFavorite;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  // ---- Helpers -------------------------------------------------------------

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
    return original > calc; // show only when strictly greater
  }

  int _discountPercent(double original, double calc) {
    final pct = ((original - calc) / original) * 100.0;
    return pct.round();
  }

  String _fmt(double v) => CurrencyUtil.appendCurrency(v.toStringAsFixed(0));

  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final calc = _lowestCalculated(product);
    final orig = _highestOriginal(product);
    final hasDiscount = _hasDiscount(orig, calc);
    final percentOff = (hasDiscount && orig != null && calc != null)
        ? _discountPercent(orig!, calc!)
        : null;

    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnail ?? '',
                    height: 225,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const ImageFallbackWidget(w: 60, h: 60),
                  ),
                ),

                // Favorite
                if (onTapFavorite != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onTapFavorite,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ),

                // (Optional) % OFF ribbon – keep/remove as you prefer
                if (hasDiscount && percentOff != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 6),
                      decoration: const BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                        ),
                      ),
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          '$percentOff% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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
                product.title??'',
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Price row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _fmt(calc ?? orig ?? 0), // show calc, else original
                    style: FontUtils.primaryFontStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hasDiscount && orig != null)
                    Text(
                      _fmt(orig),
                      style: FontUtils.secondaryFontStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
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
