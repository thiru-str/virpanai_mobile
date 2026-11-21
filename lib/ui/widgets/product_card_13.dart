import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/widgets/home/theatre/theatre_sections.dart';
import 'package:waioz/ui/widgets/home/theatre/theatre_shared.dart';
import 'package:waioz/ui/widgets/login_prompt.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/cart_store.dart';

import '../../model/product_response.dart';

/// ProductCard13 ("productView13") — the THEATRE card on the product list, the
/// app twin of the web's productCard-52: the hardware whole on a pale stage
/// with the sound-wave rings, the maker in wide caps, the model, spec chips
/// read off the title, price in Indian grouping with the struck MRP, and Add
/// to cart (a product with several variants shows "Choose option" and opens
/// the options sheet). It is the same [TheatreTile] the home shelves draw.
class ProductCard13 extends StatelessWidget {
  final Product product;
  final VoidCallback onTapCard;

  const ProductCard13(
      {super.key, required this.product, required this.onTapCard});

  Variant? _cheapest() {
    Variant? best;
    double bestPrice = double.infinity;
    for (final v in product.variants ?? const <Variant>[]) {
      final p = double.tryParse(
          v.calculatedPrice?.calculatedAmount?.toString() ?? '');
      if (p != null && p < bestPrice) {
        best = v;
        bestPrice = p;
      }
    }
    return best ??
        ((product.variants?.isNotEmpty ?? false)
            ? product.variants!.first
            : null);
  }

  /// The tile reads the home payload's item shape; map the list product to it.
  LayoutDatum _asItem() {
    final v = _cheapest();
    return LayoutDatum.fromJson({
      'id': product.id,
      'title': product.title,
      'handle': product.handle,
      'image': product.cardThumbnail,
      'prices': {
        'selling_price': v?.calculatedPrice?.calculatedAmount?.toString() ?? '',
        'original_price': v?.calculatedPrice?.originalAmount?.toString() ?? '',
      },
      'variant_details': {'variant_id': v?.id ?? ''},
      'no_of_variants': product.variants?.length ?? 0,
    });
  }

  Future<void> _change(
      BuildContext context, int delta, String variantId) async {
    // A guest has no cart on the server; sign them in first.
    if (!await AppUtils.isLoggedIn()) {
      if (context.mounted)
        await showLoginPromptDialog(context,
            redirectPage: const BottomNavPage());
      return;
    }
    if (context.mounted)
      await CartStore.instance.changeVariantQuantity(context, variantId, delta);
  }

  @override
  Widget build(BuildContext context) {
    const colors =
        TheatreColors(kTheatrePaper, kTheatreAmber, kTheatrePlate, null);
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth.isFinite ? box.maxWidth : 170.0;
      // The width too: a sideways rail gives the card none of its own.
      return SizedBox(
        width: w,
        height: TheatreTile.heightFor(context, w),
        child: TheatreTile(
          item: _asItem(),
          colors: colors,
          onTap: onTapCard,
          onCartQtyChanged: (delta, variantId) =>
              _change(context, delta, variantId),
        ),
      );
    });
  }
}
