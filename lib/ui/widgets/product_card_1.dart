import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';

class ProductCard1 extends StatefulWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final bool isFavorite;

  const ProductCard1({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onTapFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<ProductCard1> createState() => _ProductCard1State();
}

class _ProductCard1State extends State<ProductCard1> {
  int _currentIndex = 0;

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

  ({Variant? variant, int count}) _variantInfo(Product p) {
    final variants = (p.variants ?? [])
        .where((v) =>
            v.title != null &&
            v.title!.isNotEmpty &&
            v.title != 'Default Title' &&
            v.title != 'Default variant')
        .toList();
    if (variants.isEmpty) return (variant: null, count: 0);
    Variant? cheapest;
    double? minPrice;
    for (final v in variants) {
      final price = double.tryParse(v.calculatedPrice?.calculatedAmount?.toString() ?? '');
      if (price != null && (minPrice == null || price < minPrice)) {
        minPrice = price;
        cheapest = v;
      }
    }
    return (variant: cheapest ?? variants.first, count: variants.length);
  }

  String _fmt(double v) => CurrencyUtil.appendCurrency(v.toStringAsFixed(0));

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images ?? [];
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
                // Image carousel
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 225,
                    color: AppColors.secondary,
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: images[index].url ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (context, url, error) =>
                          const ImageFallbackWidget(w: 60, h: 60),
                        );
                      },
                    ),
                  ),
                ),

                if (images.length > 1)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(images.length, (index) {
                          final isActive = _currentIndex == index;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.black : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),


                // ✅ Brand tag top-left (flat left, rounded right)
                // Positioned(
                //   top: 8,
                //   left: 0,
                //   child: Container(
                //     padding:
                //     const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: const BoxDecoration(
                //       color: Colors.yellow,
                //       borderRadius: BorderRadius.only(
                //         topRight: Radius.circular(12),
                //         bottomRight: Radius.circular(12),
                //       ),
                //     ),
                //     child: Text(
                //       "Westside",
                //       style: const TextStyle(
                //         fontSize: 10,
                //         fontWeight: FontWeight.w500,
                //         color: Colors.black87,
                //       ),
                //     ),
                //   ),
                // ),

                // ✅ Wishlist button top-right
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onTapFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color:
                        widget.isFavorite ? Colors.red : Colors.grey[700],
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
                product.title ?? '',
                style: UiTypography.cardTitle(color: AppColors.textColor)
                    .copyWith(fontSize: 15, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Subtitle / Description
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2),
                child: Text(
                  description,
                  style: UiTypography.cardSubtitle(color: AppColors.textColor50),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Variant label (cheapest non-default variant name + remaining count)
            Builder(builder: (_) {
              final info = _variantInfo(product);
              if (info.variant == null) return const SizedBox.shrink();
              final remaining = info.count - 1;
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        info.variant!.title!,
                        style: UiTypography.cardMeta(color: Colors.grey.shade600)
                            .copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (remaining > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '+$remaining',
                        style: UiTypography.cardMeta(color: AppColors.primary)
                            .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              );
            }),

            // Price row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fmt(calc ?? orig ?? 0),
                    style: UiTypography.cardPrice(color: AppColors.primary),
                  ),
                  if (hasDiscount && orig != null) ...[
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _fmt(orig),
                          style: UiTypography.cardMeta(color: Colors.grey)
                              .copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        if (percentOff != null)
                          Text(
                            '$percentOff% Off',
                            style: UiTypography.cardMeta(
                                    color: const Color(0xFF1FA971))
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                      ],
                    ),
                  ],
                  if (!hasDiscount && percentOff != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$percentOff% Off',
                      style: UiTypography.cardMeta(color: const Color(0xFF1FA971))
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),

            // Ratings row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "4.5",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.star, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "(23)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

}
