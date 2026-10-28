import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/utility/cart_store.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

/// BASKET — the app side of the web storefront's supermarket / quick-commerce
/// family (web: modules/dynamic-components/basket-*.tsx). Same layout names,
/// same builder fields, same rules, so a store's web home can also be its app
/// home:
///
///  - PACKSHOTS ARE SHOWN WHOLE: contain-fit on a white inner tile; a tint is
///    only ever a frame around the white, never behind a white carton.
///  - PRICE IS THE HEADLINE OF A TILE: selling price bold, MRP struck, saving
///    as a "% OFF" corner badge in its own colour.
///  - ADD IS ONE TAP AND BECOMES A STEPPER, through the one live cart
///    (CartStore). A product with several variants opens its page instead of
///    adding one blindly.
///  - THREE COLOURS WITH JOBS: Primary = act (ADD, links), sun = offers,
///    blue = savings. Grounds stay light so the packshots carry the colour.

const Color kBasketGround = Color(0xFFF4F6F1);
const Color kBasketInk = Color(0xFF1B1F1D);
const Color kBasketLeaf = Color(0xFF0F7A3D);
const Color kBasketSun = Color(0xFFFFC93C);
const Color kBasketDeal = Color(0xFF2563EB);
const Color kBasketLine = Color(0xFFE3E7DF);

/// Soft frames for category squares — distinct enough to scan, never loud.
const List<Color> kBasketTints = [
  Color(0xFFE7F5EC),
  Color(0xFFFFF3D1),
  Color(0xFFE7F0FF),
  Color(0xFFFDEBE8),
  Color(0xFFEFE9FB),
  Color(0xFFE3F5F4),
  Color(0xFFFFEEDD),
  Color(0xFFEDF3DA),
];

/// Builder colours arrive as "#rrggbb", "rgb(r, g, b)" or a gradient string;
/// a gradient is not a flat colour, so it falls back.
Color? basketParseColor(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty || v.contains('gradient')) return null;
  final hex = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(v);
  if (hex != null) return Color(int.parse('FF${hex.group(1)}', radix: 16));
  final hex8 = RegExp(r'^#([0-9a-fA-F]{8})$').firstMatch(v);
  if (hex8 != null) return Color(int.parse(hex8.group(1)!, radix: 16));
  final rgb = RegExp(r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)').firstMatch(v);
  if (rgb != null) {
    return Color.fromARGB(255, int.parse(rgb.group(1)!), int.parse(rgb.group(2)!),
        int.parse(rgb.group(3)!));
  }
  return null;
}

Color basketOn(Color bg) => bg.computeLuminance() > 0.45 ? kBasketInk : Colors.white;

/// Style-tab colours of one section, mirroring basketColors() on the web.
/// Primary = action colour · Text = all type (auto-contrasts) · Card = tile
/// surface · Background = section ground.
class BasketColors {
  final Color bg;
  final Color accent;
  final Color card;
  final Color text;
  const BasketColors(this.bg, this.accent, this.card, this.text);

  Color get cardText => basketOn(card);
  Color get onAccent => basketOn(accent);

  factory BasketColors.of(Content c, {Color ground = kBasketGround}) {
    final bg = basketParseColor(c.layoutBgColor) ?? ground;
    return BasketColors(
      bg,
      basketParseColor(c.layoutPrimaryColor) ?? kBasketLeaf,
      basketParseColor(c.layoutCardColor) ?? Colors.white,
      basketParseColor(c.layoutSecondaryColor) ?? basketOn(bg),
    );
  }
}

// ── Data helpers ────────────────────────────────────────────────────────────
double basketNumber(String? v) =>
    double.tryParse((v ?? '').replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;

/// "₹1,299" — whole rupees without ".00", paise only when there are some.
String basketAmount(String? v) {
  final n = basketNumber(v);
  if (n <= 0) return '';
  final f = NumberFormat(n % 1 == 0 ? '#,##,##0' : '#,##,##0.00', 'en_IN');
  return '${CurrencyUtil.getCurrencySymbol()}${f.format(n)}';
}

/// Whole-percent saving, or 0 when there is none worth showing.
int basketOff(LayoutDatum d) {
  final s = basketNumber(d.prices?.sellingPrice);
  final o = basketNumber(d.prices?.originalPrice);
  if (s <= 0 || o <= s) return 0;
  final pct = ((o - s) / o * 100).round();
  return pct >= 1 ? pct : 0;
}

String basketVariantId(LayoutDatum d) =>
    d.variantDetails?.variantId ?? d.cartDetails?.variantId ?? '';

int basketVariantCount(LayoutDatum d) {
  final listed = d.raw['product_variants'];
  final n = int.tryParse(d.rawString('no_of_variants')) ?? 0;
  return [n, listed is List ? listed.length : 0].reduce((a, b) => a > b ? a : b);
}

/// The products a custom item carries (BasketAisleTabs1's tab products).
List<LayoutDatum> basketMultiProducts(LayoutDatum d) {
  final list = d.raw['multi_product_data'];
  if (list is! List) return const [];
  return list.whereType<Map>().map((m) => LayoutDatum.fromJson(Map<String, dynamic>.from(m))).toList();
}

/// First non-empty of the item's custom string fields.
String basketField(LayoutDatum d, List<String> keys) {
  for (final k in keys) {
    final v = d.rawString(k).trim();
    if (v.isNotEmpty && v != 'null') return v;
  }
  return '';
}

/// Opens what a tile points at: a product's page, or the item's redirect.
void basketOpen(BuildContext context, Content content, LayoutDatum item) {
  final option = content.layoutOption ?? 'Custom';
  if (option == 'Product') {
    final id = item.id ?? '';
    if (id.isNotEmpty) PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: id));
    return;
  }
  RedirectUtils.handleContentRedirect(context: context, layoutOption: option, layoutData: item);
}

/// The section's own "See all" link (layout redirect).
VoidCallback? basketSeeAll(BuildContext context, Content content) {
  final r = content.redirectData;
  if ((content.layoutRedirectTitle ?? '').isEmpty || r == null || (r.redirectType ?? '').isEmpty) {
    return null;
  }
  return () => RedirectUtils.handleContentRedirectViewAll(context: context, redirectData: r);
}

// ── Images ──────────────────────────────────────────────────────────────────
/// Network image with a quiet load state. [debugProvider] lets the preview
/// harness render real packshots from disk (tests cannot reach the network).
class BasketImage extends StatelessWidget {
  static ImageProvider Function(String url)? debugProvider;

  final String? url;
  final BoxFit fit;
  const BasketImage({super.key, this.url, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    final u = (url ?? '').trim();
    if (u.isEmpty) return const ColoredBox(color: Color(0xFFF1F3EF));
    final override = debugProvider;
    if (override != null) return Image(image: override(u), fit: fit);
    return CachedNetworkImage(
      imageUrl: u,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, __) => const ColoredBox(color: Color(0xFFF4F5F2)),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.image_outlined, size: 20, color: Color(0x401B1F1D)),
      ),
    );
  }
}

// ── Section frame + head ────────────────────────────────────────────────────
/// The family's vertical rhythm: a grocery home is a long scroll of short
/// shelves, so sections sit close.
class BasketSection extends StatelessWidget {
  final Color bg;
  final Widget child;
  final EdgeInsetsGeometry padding;
  const BasketSection({
    super.key,
    required this.bg,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) =>
      Container(width: double.infinity, color: bg, padding: padding, child: child);
}

/// Title (+ optional kicker) left, "See all ›" right.
class BasketSectionHead extends StatelessWidget {
  final Content content;
  final BasketColors colors;
  final VoidCallback? onSeeAll;
  const BasketSectionHead({super.key, required this.content, required this.colors, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle ?? '';
    final kicker = content.layoutSubTitle ?? '';
    final cta = content.layoutRedirectTitle ?? '';
    if (title.isEmpty && kicker.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (kicker.isNotEmpty)
              Text(kicker.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.secondaryFontStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: colors.text.withValues(alpha: 0.55))),
            if (title.isNotEmpty)
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: colors.text)),
          ]),
        ),
        if (cta.isNotEmpty && onSeeAll != null) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('$cta ›',
                  style: FontUtils.primaryFontStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: colors.accent)),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Product tile ────────────────────────────────────────────────────────────
/// One product, built to be bought from the shelf: square white image tile
/// (packshot whole), "% OFF" badge, two-line name, price + struck MRP, and
/// ADD → stepper on the live cart. Width comes from the parent.
class BasketTile extends StatefulWidget {
  final LayoutDatum item;
  final BasketColors colors;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const BasketTile({super.key, required this.item, required this.colors, this.onCartQtyChanged});

  /// Tile height for a given width: square image + name + price row, plus a
  /// line for the pack size only when a product on the shelf has one — so
  /// rails and grids size rows without measuring and leave no empty band.
  static double heightFor(double width, {bool pack = false}) => width + 82 + (pack ? 16 : 0);

  static bool anyPack(Iterable<LayoutDatum> items) =>
      items.any((d) => basketField(d, ['product_sub_title', 'feature_text']).isNotEmpty);

  @override
  State<BasketTile> createState() => _BasketTileState();
}

class _BasketTileState extends State<BasketTile> {
  StreamSubscription<CartStateEvent>? _sub;

  @override
  void initState() {
    super.initState();
    // Steppers follow every add, change and rollback from any screen.
    _sub = eventBus.on<CartStateEvent>().listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _open() {
    final id = widget.item.id ?? '';
    if (id.isNotEmpty) PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: id));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.item;
    final c = widget.colors;
    final ink = c.cardText;
    final off = basketOff(d);
    final selling = basketAmount(d.prices?.sellingPrice ?? d.subTitle);
    final mrp = basketAmount(d.prices?.originalPrice);
    final pack = basketField(d, ['product_sub_title', 'feature_text']);
    final variantId = basketVariantId(d);
    final count = CartStore.instance.quantityForVariant(variantId) ?? d.cartDetails?.quantity ?? 0;
    final multi = basketVariantCount(d) > 1;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBasketLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: _open,
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(fit: StackFit.expand, children: [
                ColoredBox(
                  color: Colors.white,
                  child: Padding(padding: const EdgeInsets.all(6), child: BasketImage(url: d.image)),
                ),
                if (off > 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                      decoration: const BoxDecoration(
                        color: kBasketDeal,
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                      ),
                      child: Text('$off%\nOFF',
                          textAlign: TextAlign.center,
                          style: FontUtils.primaryFontStyle(
                                  fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white)
                              .copyWith(height: 1.05)),
                    ),
                  ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _open,
          child: SizedBox(
            height: 34,
            child: Text(d.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: ink)
                    .copyWith(height: 1.25)),
          ),
        ),
        if (pack.isNotEmpty)
          SizedBox(
            height: 16,
            child: Text(pack,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.secondaryFontStyle(fontSize: 11.5, color: ink.withValues(alpha: 0.55))),
          ),
        const Spacer(),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              if (selling.isNotEmpty)
                Text(selling,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: ink)),
              if (off > 0 && mrp.isNotEmpty)
                Text(mrp,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.secondaryFontStyle(
                        fontSize: 11,
                        color: ink.withValues(alpha: 0.45),
                        decoration: TextDecoration.lineThrough)),
            ]),
          ),
          const SizedBox(width: 6),
          if (multi)
            _BasketPill(label: 'OPTIONS', colors: c, onTap: _open)
          else if (variantId.isNotEmpty && widget.onCartQtyChanged != null)
            BasketStepper(
              count: count,
              colors: c,
              onInc: () => widget.onCartQtyChanged!(1, variantId),
              onDec: () => widget.onCartQtyChanged!(-1, variantId),
            ),
        ]),
      ]),
    );
  }
}

class _BasketPill extends StatelessWidget {
  final String label;
  final BasketColors colors;
  final VoidCallback onTap;
  const _BasketPill({required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.accent, width: 1.2),
          ),
          child: Text(label,
              style: FontUtils.primaryFontStyle(
                  fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: colors.accent)),
        ),
      );
}

/// ADD (outlined) → filled −/n/+ stepper in the section's action colour.
class BasketStepper extends StatelessWidget {
  final int count;
  final BasketColors colors;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const BasketStepper(
      {super.key, required this.count, required this.colors, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return _BasketPill(label: 'ADD', colors: colors, onTap: onInc);
    final on = colors.onAccent;
    Widget btn(IconData icon, VoidCallback tap) => GestureDetector(
          onTap: tap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(width: 26, height: 30, child: Icon(icon, size: 15, color: on)),
        );
    return Container(
      height: 30,
      decoration: BoxDecoration(color: colors.accent, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn(Icons.remove_rounded, onDec),
        Text('$count', style: FontUtils.primaryFontStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: on)),
        btn(Icons.add_rounded, onInc),
      ]),
    );
  }
}

/// A horizontal shelf of [BasketTile]s, 148pt wide like the web rail.
class BasketTileRail extends StatelessWidget {
  final List<LayoutDatum> items;
  final BasketColors colors;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const BasketTileRail({super.key, required this.items, required this.colors, this.onCartQtyChanged});

  static const double tileWidth = 148;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return SizedBox(
      height: BasketTile.heightFor(tileWidth, pack: BasketTile.anyPack(items)) + 18 * (scale - 1) * 3,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(
          width: tileWidth,
          child: BasketTile(item: items[i], colors: colors, onCartQtyChanged: onCartQtyChanged),
        ),
      ),
    );
  }
}
