import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/ui_typography.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.isFavorite = false,
  });

  // ---- Helpers -------------------------------------------------------------

  double? _lowestCalculated(Product p) {
    if (p.variants?.isEmpty ?? true) return null;
    final vals = p.variants!
        .map((v) => double.tryParse(
              v.calculatedPrice?.calculatedAmount?.toString() ?? '',
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
              v.calculatedPrice?.originalAmount?.toString() ?? '',
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
        ? _discountPercent(orig, calc)
        : null;

    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    color: AppColors.secondary,
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail ?? '',
                      height: 225,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 350),
                      placeholderFadeInDuration:
                          const Duration(milliseconds: 150),
                      placeholder: (context, url) => const AppShimmer(
                        child: ShimmerBox(
                          height: 225,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const ImageFallbackWidget(w: 60, h: 60),
                    ),
                  ),
                ),

                // Favorite
                if (onTapFavorite != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onTapFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),

                // Discount badge
                if (hasDiscount && percentOff != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F7F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$percentOff% OFF',
                        style: UiTypography.cardMeta(
                          color: const Color(0xFF1FA971),
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                product.title ?? '',
                style: UiTypography.cardTitle(color: AppColors.textColor)
                    .copyWith(fontSize: 15, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Price row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Text(
                    _fmt(calc ?? orig ?? 0), // show calc, else original
                    style: UiTypography.cardPrice(color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  if (hasDiscount && orig != null)
                    Text(
                      _fmt(orig),
                      style: UiTypography.cardMeta().copyWith(
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
