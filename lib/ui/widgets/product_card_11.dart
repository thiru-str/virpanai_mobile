import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

/// ProductCard11 — "Compact Grid"
/// Tight, small, dense cell for high-density grids: short image, one-line
/// title, price and a small circular + add button on the price row.
class ProductCard11 extends StatefulWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final bool isFavorite;

  const ProductCard11({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<ProductCard11> createState() => _ProductCard11State();
}

class _ProductCard11State extends State<ProductCard11> {
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
    final imageUrl = images.isNotEmpty ? (images.first.url ?? '') : '';
    final cheapest = _cheapestVariant(product);

    final calc = cheapest != null
        ? double.tryParse(cheapest.calculatedPrice?.calculatedAmount?.toString() ?? '')
        : null;

    final orig = cheapest != null
        ? double.tryParse(cheapest.calculatedPrice?.originalAmount?.toString() ?? '')
        : null;

    final hasDiscount = (orig != null && calc != null && orig > calc);

    return GestureDetector(
      onTap: widget.onTapCard,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEEF1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.secondary,
                    child: imageUrl.isEmpty
                        ? const ImageFallbackWidget(h: 120, w: double.infinity, fit: BoxFit.contain)
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (context, url, error) =>
                                const ImageFallbackWidget(w: 40, h: 40),
                          ),
                  ),
                ),
                if (widget.onTapFavorite != null)
                  Positioned(
                    top: 5,
                    right: 5,
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
                          size: 14,
                          color: widget.isFavorite ? Colors.red : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // One-line title
                  Text(
                    product.title ?? '',
                    style: UiTypography.cardTitle(color: AppColors.textColor)
                        .copyWith(fontSize: 12.5, height: 1.15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Price + compact add button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _fmt(calc ?? orig ?? 0),
                              style: UiTypography.cardPrice(color: AppColors.primary)
                                  .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            if (hasDiscount && orig != null)
                              Text(
                                _fmt(orig),
                                style: UiTypography.cardMeta(color: Colors.grey).copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Compact add button
                      GestureDetector(
                        onTap: widget.onTapCard,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
