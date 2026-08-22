import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../../model/product_response.dart';
import '../../utility/currency_util.dart';
import 'product_card_variant_chips.dart';

class ProductCard3 extends StatelessWidget {
  final Product product;
  final VoidCallback onTapCard;
  final VoidCallback? onAddToCart;

  ProductCard3({
    Key? key,
    required this.product,
    required this.onTapCard,
    this.onAddToCart,
  }) : super(key: key);

  Variant? _cheapestVariant(Product p) {
    if (p.variants?.isEmpty ?? true) return null;

    Variant? cheapest;
    for (final v in p.variants!) {
      final calc = double.tryParse(
          v.calculatedPrice?.calculatedAmount?.toString() ?? '');
      if (calc == null) continue;
      if (cheapest == null) {
        cheapest = v;
      } else {
        final cheapestCalc = double.tryParse(
                cheapest.calculatedPrice?.calculatedAmount?.toString() ?? '') ??
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
    final cheapest = _cheapestVariant(product);
    final rating = double.tryParse(
      product.metadata?.reviewSummary?.averageRating ?? '',
    );
    final totalReviews = int.tryParse(
      product.metadata?.reviewSummary?.totalReviews ?? '',
    );

    final calc = cheapest != null
        ? double.tryParse(
            cheapest.calculatedPrice?.calculatedAmount?.toString() ?? '')
        : null;

    final orig = cheapest != null
        ? double.tryParse(
            cheapest.calculatedPrice?.originalAmount?.toString() ?? '')
        : null;

    final hasDiscount = (orig != null && calc != null && orig > calc);
    final percentOff =
        hasDiscount ? ((orig - calc) / orig * 100).round() : null;

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
          children: [
            // ---- Image with "NEW" Tag ----
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 140,
                    color: AppColors.secondary,
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail ?? '',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorWidget: (c, u, e) =>
                          const ImageFallbackWidget(w: 80, h: 80),
                    ),
                  ),
                ),
                // "NEW" cut tag
                Positioned(
                  top: 0,
                  left: 0,
                  child: ClipPath(
                    clipper: _DiagonalClipper(),
                    child: Container(
                      width: 50,
                      height: 24,
                      color: const Color(0xFF1FA971),
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.new_tag,
                        style: UiTypography.cardMeta(color: Colors.white)
                            .copyWith(
                                fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ---- Rating with cut style ----
            if (rating != null && rating.isFinite && rating > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        totalReviews != null && totalReviews > 0
                            ? '${rating.toStringAsFixed(1)} ($totalReviews)'
                            : rating.toStringAsFixed(1),
                        style: UiTypography.cardMeta(color: Colors.black87)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],

            // ---- Title ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                product.title ?? '',
                style: UiTypography.cardTitle().copyWith(
                  fontSize: 15,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ---- Variant chips ----
            Builder(builder: (_) {
              final info = variantInfo(product);
              if (info.variant == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: buildVariantChips(info.variant!, info.count - 1),
              );
            }),

            const SizedBox(height: 4),

            // ---- Price Row ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _fmt(calc ?? orig ?? 0),
                    style: UiTypography.cardPrice(color: Colors.black),
                  ),
                  if (hasDiscount && orig != null)
                    Text(
                      _fmt(orig),
                      style: UiTypography.cardMeta(color: Colors.grey).copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),

            if (percentOff != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: Text(
                  "$percentOff% OFF",
                  style: UiTypography.cardMeta(color: const Color(0xFF1FA971))
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            // ---- Add to Cart Button ----
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: onAddToCart,
                  icon: Icon(Icons.shopping_cart_outlined,
                      size: 16, color: AppColors.primary),
                  label: Text(
                    AppStrings.add_to_cart,
                    style: UiTypography.cardAction(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
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

// ---- Custom Clipper for NEW tag ----
class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 10, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
