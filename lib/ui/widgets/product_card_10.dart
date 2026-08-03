import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

/// ProductCard10 — "Bold Deal"
/// Loud, sales-driven card: a prominent corner discount badge, big price with
/// strikethrough original, and a full-width solid ADD button.
class ProductCard10 extends StatefulWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final bool isFavorite;

  const ProductCard10({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<ProductCard10> createState() => _ProductCard10State();
}

class _ProductCard10State extends State<ProductCard10> {
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
    final percentOff = hasDiscount ? ((orig - calc) / orig * 100).round() : null;

    return GestureDetector(
      onTap: widget.onTapCard,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 190,
                    width: double.infinity,
                    color: AppColors.secondary,
                    child: imageUrl.isEmpty
                        ? const ImageFallbackWidget(h: 190, w: double.infinity, fit: BoxFit.contain)
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (context, url, error) =>
                                const ImageFallbackWidget(w: 60, h: 60),
                          ),
                  ),
                ),

                // Prominent discount badge (top-left)
                if (percentOff != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      child: Text(
                        '$percentOff% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                // Wishlist button (top-right)
                if (widget.onTapFavorite != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: widget.onTapFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: widget.isFavorite ? Colors.red : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                product.title ?? '',
                style: UiTypography.cardTitle(color: AppColors.textColor)
                    .copyWith(fontSize: 15, height: 1.2, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 6),

            // Bold price with strikethrough
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _fmt(calc ?? orig ?? 0),
                    style: UiTypography.cardPrice(color: const Color(0xFFE53935))
                        .copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  if (hasDiscount && orig != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      _fmt(orig),
                      style: UiTypography.cardMeta(color: Colors.grey).copyWith(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Full-width solid ADD button
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onTapCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ADD TO CART',
                    style: UiTypography.cardAction(color: Colors.white)
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w800),
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
