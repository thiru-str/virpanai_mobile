import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';
import '../../utility/ui_typography.dart';
import 'product_card_variant_chips.dart';

class ProductCard8 extends StatelessWidget {
  final Product product;
  final VoidCallback onTapCard;

  const ProductCard8({
    Key? key,
    required this.product,
    required this.onTapCard,
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
      product.metadata?.reviewSummary?.averageRating ?? '',
    );

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
        width: 113,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Container(
                    width: double.infinity,
                    height: 141,
                    color: AppColors.secondary,
                    child: images.isEmpty
                        ? const Center(
                            child: ImageFallbackWidget(
                                w: 40, h: 40, fit: BoxFit.contain),
                          )
                        : CachedNetworkImage(
                            imageUrl: images.first.url ?? '',
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorWidget: (context, url, error) => const Center(
                              child: ImageFallbackWidget(
                                  w: 40, h: 40, fit: BoxFit.contain),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    height: 17,
                    width: 60,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      '',
                      style: UiTypography.cardMeta(
                        color: Colors.black,
                      ).copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.description ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UiTypography.cardMeta(
                              color: Colors.white,
                            ).copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (rating != null && rating.isFinite && rating > 0)
                          Container(
                            height: 16,
                            width: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              rating.toStringAsFixed(1),
                              style: UiTypography.cardMeta(
                                color: const Color(0xFF6D758F),
                              ).copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 9, 7, 0),
              child: Text(
                product.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: UiTypography.cardTitle(
                  color: const Color(0xFF272727),
                ),
              ),
            ),
            // ---- Variant chips ----
            Builder(builder: (_) {
              final info = variantInfo(product);
              if (info.variant == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(7, 4, 7, 0),
                child: buildVariantChips(info.variant!, info.count - 1),
              );
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 6, 7, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _fmt(calc ?? orig ?? 0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTypography.cardPrice(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 2, 7, 6),
              child: Wrap(
                spacing: 4,
                runSpacing: 1,
                children: [
                  Text(
                    _fmt(orig ?? calc ?? 0),
                    style: UiTypography.cardMeta(
                      color: const Color(0xFFB1B5B8),
                    ).copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    percentOff != null ? '$percentOff% OFF' : '',
                    style: UiTypography.cardMeta(
                      color: const Color(0xFF1FA971),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
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
