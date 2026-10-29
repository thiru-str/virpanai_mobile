import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';
import '../../utility/ui_typography.dart';

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
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                  width: double.infinity,
                  height: 187,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      '',
                      style: UiTypography.cardMeta(
                        color: Colors.black,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
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
                style: UiTypography.cardTitle(
                  color: const Color(0xFF272727),
                ).copyWith(
                  fontSize: 15,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
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
                    style: UiTypography.cardPrice(color: AppColors.primary),
                  ),
                  Text(
                    _fmt(orig ?? calc ?? 0),
                    style: UiTypography.cardMeta(
                      color: Colors.grey,
                    ).copyWith(
                      fontSize: 13,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    percentOff != null ? '$percentOff% off' : '',
                    style: UiTypography.cardMeta(
                      color: const Color(0xFF1FA971),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
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
                      style: UiTypography.cardMeta(
                        color: const Color(0xFF6D758F),
                      ).copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      totalReviews.isNotEmpty ? '$totalReviews Ratings' : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTypography.cardMeta(
                        color: Colors.black,
                      ).copyWith(
                        fontSize: 11,
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
                style: UiTypography.cardMeta(
                  color: Colors.black.withOpacity(0.8),
                ).copyWith(
                  fontWeight: FontWeight.w600,
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
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Add to Cart',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  UiTypography.cardAction(color: AppColors.primary)
                                      .copyWith(fontWeight: FontWeight.w700),
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
