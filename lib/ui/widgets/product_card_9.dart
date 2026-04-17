import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

class ProductCard9 extends StatelessWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final VoidCallback? onAddToCart;
  final bool isFavorite;

  const ProductCard9({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.onAddToCart,
    this.isFavorite = false,
  }) : super(key: key);

  Variant? _cheapestVariant(Product p) {
    if (p.variants?.isEmpty ?? true) return null;

    Variant? cheapest;
    for (final v in p.variants!) {
      final calc = double.tryParse(
        v.calculatedPrice?.calculatedAmount?.toString() ?? '',
      );
      if (calc == null) continue;
      if (cheapest == null) {
        cheapest = v;
      } else {
        final cheapestCalc = double.tryParse(
              cheapest.calculatedPrice?.calculatedAmount?.toString() ?? '',
            ) ??
            double.infinity;
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
    final images = product.images ?? [];
    final cheapest = _cheapestVariant(product);
    final rating = double.tryParse(
      product.metadata?.reviewSummary?.averageRating?.toString() ?? '',
    );
    final totalReviews = product.metadata?.reviewSummary?.totalReviews ?? '';

    final calc = cheapest != null
        ? double.tryParse(
            cheapest.calculatedPrice?.calculatedAmount?.toString() ?? '',
          )
        : null;

    final orig = cheapest != null
        ? double.tryParse(
            cheapest.calculatedPrice?.originalAmount?.toString() ?? '',
          )
        : null;

    final hasDiscount = (orig != null && calc != null && orig > calc);
    final percentOff =
        hasDiscount ? ((orig - calc) / orig * 100).round() : null;

    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        width: 195,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(6, 5, 6, 0),
                  width: double.infinity,
                  height: 187,
                  color: const Color(0xFFE1E4ED),
                  child: images.isEmpty
                      ? const Center(
                          child: ImageFallbackWidget(
                              w: 70, h: 70, fit: BoxFit.contain),
                        )
                      : CachedNetworkImage(
                          imageUrl: images.first.url ?? '',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorWidget: (context, url, error) => const Center(
                            child: ImageFallbackWidget(
                                w: 70, h: 70, fit: BoxFit.contain),
                          ),
                        ),
                ),
                Positioned(
                  top: 5,
                  right: 6,
                  child: Container(
                    width: 84,
                    height: 23,
                    color: const Color(0xFFD4D5D8),
                    alignment: Alignment.center,
                    child: Text(
                      '',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
              child: Text(
                product.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF272727),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
              child: Wrap(
                spacing: 5,
                runSpacing: 2,
                children: [
                  Text(
                    _fmt(calc ?? orig ?? 0),
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    _fmt(orig ?? calc ?? 0),
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 13,
                      color: const Color(0xFF7E7D7D),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    percentOff != null ? '$percentOff% off' : '',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
              child: Row(
                children: [
                  Container(
                    width: 39,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1E4ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (rating != null ? rating.toStringAsFixed(1) : '4.2'),
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6D758F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      totalReviews.isNotEmpty ? '$totalReviews Ratings' : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
              child: Text(
                '',
                style: FontUtils.secondaryFontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton(
                            onPressed: onAddToCart,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Add to Cart',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onTapFavorite,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite,
                          size: 24,
                          color:
                              isFavorite ? Colors.red : const Color(0xFFB4B4B4),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
