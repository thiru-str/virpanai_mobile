import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

/// ProductCard6 — "Horizontal / List"
/// A full-width list row: square image on the LEFT, title/description/price
/// and rating stacked on the RIGHT. Ideal for vertical scrolling lists.
class ProductCard6 extends StatefulWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final bool isFavorite;

  const ProductCard6({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<ProductCard6> createState() => _ProductCard6State();
}

class _ProductCard6State extends State<ProductCard6> {
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
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT: image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 104,
                height: 104,
                color: AppColors.secondary,
                child: imageUrl.isEmpty
                    ? const ImageFallbackWidget(h: 104, w: 104, fit: BoxFit.contain)
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const ImageFallbackWidget(w: 40, h: 40),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            // RIGHT: details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title ?? '',
                          style: UiTypography.cardTitle(color: AppColors.textColor)
                              .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.onTapFavorite != null)
                        GestureDetector(
                          onTap: widget.onTapFavorite,
                          child: Icon(
                            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: widget.isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                    ],
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: UiTypography.cardSubtitle(color: AppColors.textColor50),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Rating chip
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star, size: 14, color: Colors.green),
                      SizedBox(width: 3),
                      Text(
                        '4.5',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(23)',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _fmt(calc ?? orig ?? 0),
                        style: UiTypography.cardPrice(color: AppColors.primary),
                      ),
                      if (hasDiscount && orig != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _fmt(orig),
                          style: UiTypography.cardMeta(color: Colors.grey).copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      if (percentOff != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '$percentOff% Off',
                          style: UiTypography.cardMeta(color: const Color(0xFF1FA971))
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
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
