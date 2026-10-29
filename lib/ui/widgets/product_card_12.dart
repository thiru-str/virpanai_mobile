import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/ui/widgets/login_prompt.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/cart_store.dart';

import '../../model/product_response.dart';

/// ProductCard12 ("productView12") — the BASKET shelf card on the product
/// list: packshot shown whole on a white tile, two-line name, price + struck
/// MRP with a "% OFF" corner, and ADD → stepper on the live cart (a product
/// with several variants shows OPTIONS and opens its page instead). It is the
/// same [BasketTile] the home shelves draw, so the list and the home match.
class ProductCard12 extends StatelessWidget {
  final Product product;
  final VoidCallback onTapCard;

  const ProductCard12({super.key, required this.product, required this.onTapCard});

  Variant? _cheapest() {
    Variant? best;
    double bestPrice = double.infinity;
    for (final v in product.variants ?? const <Variant>[]) {
      final p = double.tryParse(v.calculatedPrice?.calculatedAmount?.toString() ?? '');
      if (p != null && p < bestPrice) {
        best = v;
        bestPrice = p;
      }
    }
    return best ?? ((product.variants?.isNotEmpty ?? false) ? product.variants!.first : null);
  }

  /// The tile reads the home payload's item shape; map the list product to it.
  LayoutDatum _asItem() {
    final v = _cheapest();
    return LayoutDatum.fromJson({
      'id': product.id,
      'title': product.title,
      'image': product.thumbnail ?? '',
      'prices': {
        'selling_price': v?.calculatedPrice?.calculatedAmount?.toString() ?? '',
        'original_price': v?.calculatedPrice?.originalAmount?.toString() ?? '',
      },
      'variant_details': {'variant_id': v?.id ?? ''},
      'no_of_variants': product.variants?.length ?? 0,
    });
  }

  Future<void> _change(BuildContext context, int delta, String variantId) async {
    // A guest has no cart on the server; sign them in first.
    if (!await AppUtils.isLoggedIn()) {
      if (context.mounted) await showLoginPromptDialog(context, redirectPage: const BottomNavPage());
      return;
    }
    if (context.mounted) await CartStore.instance.changeVariantQuantity(context, variantId, delta);
  }

  @override
  Widget build(BuildContext context) {
    final colors = BasketColors(Colors.white, AppColors.primary, Colors.white, kBasketInk);
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth.isFinite ? box.maxWidth : 170.0;
      return GestureDetector(
        onTap: onTapCard,
        child: SizedBox(
          height: BasketTile.heightFor(w),
          child: BasketTile(
            item: _asItem(),
            colors: colors,
            onCartQtyChanged: (delta, variantId) => _change(context, delta, variantId),
          ),
        ),
      );
    });
  }
}
