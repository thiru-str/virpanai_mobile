import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

/// ProductCard5 — "Minimal"
/// Clean single image, generous whitespace, title, price and a subtle
/// text-only rating. No borders, no heavy shadows — airy and understated.
class ProductCard5 extends StatefulWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final bool isFavorite;

  const ProductCard5({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<ProductCard5> createState() => _ProductCard5State();
}

class _ProductCard5State extends State<ProductCard5> {
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
        width: 170,
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clean airy image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: const Color(0xFFF6F6F7),
                    child: imageUrl.isEmpty
                        ? const ImageFallbackWidget(h: 200, w: double.infinity, fit: BoxFit.contain)
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (context, url, error) =>
                                const ImageFallbackWidget(w: 60, h: 60),
                          ),
                  ),
                ),
                if (widget.onTapFavorite != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: widget.onTapFavorite,
                      child: Icon(
                        widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: widget.isFavorite ? Colors.red : Colors.black45,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              product.title ?? '',
              style: UiTypography.cardTitle(color: AppColors.textColor)
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w500, height: 1.25),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _fmt(calc ?? orig ?? 0),
                  style: UiTypography.cardPrice(color: AppColors.textColor)
                      .copyWith(fontWeight: FontWeight.w600),
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
              ],
            ),

            const SizedBox(height: 6),

            // Subtle rating
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 13, color: Color(0xFFF5A623)),
                const SizedBox(width: 3),
                Text(
                  '4.5',
                  style: UiTypography.cardMeta(color: AppColors.textColor50),
                ),
                const SizedBox(width: 4),
                Text(
                  '(23)',
                  style: UiTypography.cardMeta(color: AppColors.textColor50),
                ),
              ],
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
