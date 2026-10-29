import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

/// MAISON — a premium APP-NATIVE home family. Where ATELIER mirrors the web
/// boutique section for section (a store can copy its web home to the app),
/// MAISON uses the same catalogue data but patterns that only feel right on a
/// phone: full-bleed photography with story progress, story rings that open a
/// full-screen viewer, a snapping 3D carousel, a staggered editorial grid,
/// full-screen vertical reels, and a colour sheet that adds the exact colour
/// to the bag without leaving the feed.
///
///  - TWO COLOURS WITH JOBS (same as ATELIER): Card Background
///    (layout_card_color) is the "deep" — buttons, the bag, inverted bands;
///    Primary (layout_primary_color) is the "metal" — kickers, rings, rules.
///  - ONE DISPLAY SERIF (Cormorant Garamond, bundled) for titles and names,
///    the store's own font for everything else.
///  - Soft 20–26pt corners and a long, low shadow: the language of a
///    luxury app, not of a web page.

const String kMaisonSerif = 'CormorantGaramond';
const Color kMaisonIvory = Color(0xFFFBF6EF);
const Color kMaisonInk = Color(0xFF241A1C);
const Color kMaisonGold = Color(0xFFD9B97A);
const Color kMaisonWine = Color(0xFF6E1224);

class MaisonColors {
  final Color bg;
  final Color metal;
  final Color deep;
  const MaisonColors(this.bg, this.metal, this.deep);

  Color get ink => basketOn(bg) == Colors.white ? Colors.white : kMaisonInk;
  Color get onDeep => basketOn(deep);

  factory MaisonColors.of(Content c, {Color ground = kMaisonIvory}) => MaisonColors(
        basketParseColor(c.layoutBgColor) ?? ground,
        basketParseColor(c.layoutPrimaryColor) ?? kMaisonGold,
        basketParseColor(c.layoutCardColor) ?? kMaisonWine,
      );
}

// ── Type ────────────────────────────────────────────────────────────────────
TextStyle maisonSerif(Color color, {double size = 30, FontWeight weight = FontWeight.w500, bool italic = false}) => TextStyle(
      fontFamily: kMaisonSerif,
      fontSize: size,
      fontWeight: weight,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: 1.08,
      letterSpacing: -0.2,
      color: color,
    );

TextStyle maisonCaps(Color color, {double size = 10.5}) =>
    FontUtils.secondaryFontStyle(fontSize: size, fontWeight: FontWeight.w600, letterSpacing: size * 0.24, color: color);

TextStyle maisonBody(Color color, {double size = 13.5}) =>
    FontUtils.secondaryFontStyle(fontSize: size, color: color).copyWith(height: 1.55);

// ── Data helpers ────────────────────────────────────────────────────────────
String maisonField(LayoutDatum d, List<String> keys) {
  for (final k in keys) {
    final v = d.rawString(k).trim();
    if (v.isNotEmpty && v != 'null') return v;
  }
  return '';
}

String maisonRaw(Content c, String key) {
  final v = c.rawString(key).trim();
  return v == 'null' ? '' : v;
}

Color? _hex(String? v) => basketParseColor(v);

/// One buyable colour (or size) of a product, from the item's product_variants.
class MaisonVariant {
  final String id;
  final String name;
  final Color? swatch;
  final String image;
  final String price;
  const MaisonVariant(this.id, this.name, this.swatch, this.image, this.price);
}

List<MaisonVariant> maisonVariants(LayoutDatum d) {
  final list = d.raw['product_variants'];
  final out = <MaisonVariant>[];
  final seen = <String>{};
  if (list is List) {
    for (final v in list.whereType<Map>()) {
      final id = (v['variant_id'] ?? v['id'] ?? '').toString();
      if (id.isEmpty || !seen.add(id)) continue;
      final opts = v['variant_options'];
      final first = opts is List && opts.isNotEmpty && opts.first is Map ? opts.first as Map : const {};
      final name = (first['option_value'] ?? v['variant_title'] ?? '').toString();
      out.add(MaisonVariant(
        id,
        name.isEmpty ? 'Option ${out.length + 1}' : name,
        _hex(first['hex_color_value']?.toString()),
        (v['variant_thumbnail'] ?? '').toString(),
        (v['variant_price'] ?? '').toString(),
      ));
    }
  }
  return out;
}

/// The colour dots a card shows (from product_options' hex values).
List<Color> maisonSwatches(LayoutDatum d, {int max = 5}) {
  final opts = d.raw['product_options'];
  if (opts is List) {
    for (final o in opts.whereType<Map>()) {
      final hexes = o['hex_values'];
      if (hexes is List && hexes.isNotEmpty) {
        return hexes.map((h) => _hex(h?.toString())).whereType<Color>().take(max).toList();
      }
    }
  }
  return maisonVariants(d).map((v) => v.swatch).whereType<Color>().take(max).toList();
}

void maisonOpenProduct(BuildContext context, LayoutDatum item) {
  final id = item.id ?? '';
  if (id.isNotEmpty) PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: id));
}

void maisonOpenItem(BuildContext context, Content content, LayoutDatum item) => RedirectUtils.handleContentRedirect(
    context: context, layoutOption: content.layoutOption ?? 'Custom', layoutData: item);

VoidCallback? maisonSeeAll(BuildContext context, Content content) => basketSeeAll(context, content);

/// Add to bag: one-colour products go straight in; several colours open the
/// colour sheet so the shopper picks the exact one without leaving the feed.
Future<void> maisonAdd(BuildContext context, LayoutDatum item, MaisonColors colors,
    void Function(int delta, String variantId)? onCartQtyChanged) async {
  if (onCartQtyChanged == null) return maisonOpenProduct(context, item);
  final variants = maisonVariants(item);
  if (variants.length <= 1) {
    final id = basketVariantId(item).isNotEmpty ? basketVariantId(item) : (variants.isEmpty ? '' : variants.first.id);
    if (id.isEmpty) return maisonOpenProduct(context, item);
    HapticFeedback.lightImpact();
    onCartQtyChanged(1, id);
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MaisonColourSheet(item: item, variants: variants, colors: colors, onAdd: (id) => onCartQtyChanged(1, id)),
  );
}

// ── Pieces ──────────────────────────────────────────────────────────────────
/// Left-aligned head: kicker in the metal, serif title, optional round arrow.
class MaisonHeader extends StatelessWidget {
  final Content content;
  final MaisonColors colors;
  final Color? ink;
  final VoidCallback? onSeeAll;
  const MaisonHeader({super.key, required this.content, required this.colors, this.ink, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle ?? '';
    final kicker = content.layoutSubTitle ?? '';
    if (title.isEmpty && kicker.isEmpty) return const SizedBox.shrink();
    final c = ink ?? colors.ink;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (kicker.isNotEmpty) ...[
              Text(kicker.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: maisonCaps(colors.metal)),
              const SizedBox(height: 6),
            ],
            if (title.isNotEmpty) Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: maisonSerif(c, size: 31)),
          ]),
        ),
        if (onSeeAll != null) ...[
          const SizedBox(width: 12),
          MaisonRoundButton(icon: Icons.arrow_forward_rounded, color: c, onTap: onSeeAll!),
        ],
      ]),
    );
  }
}

class MaisonRoundButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;
  final double size;
  const MaisonRoundButton({super.key, required this.icon, required this.color, required this.onTap, this.filled = false, this.size = 40});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: filled ? null : Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Icon(icon, size: size * 0.45, color: filled ? basketOn(color) : color),
        ),
      );
}

/// A pill button in a solid colour.
class MaisonPill extends StatelessWidget {
  final String label;
  final Color fill;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  const MaisonPill({super.key, required this.label, required this.fill, this.onTap, this.icon, this.height = 46});

  @override
  Widget build(BuildContext context) {
    final on = basketOn(fill);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(height / 2)),
        child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 17, color: on), const SizedBox(width: 8)],
          Text(label, style: FontUtils.primaryFontStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: on, letterSpacing: 0.3)),
        ]),
      ),
    );
  }
}

/// Colour dots (with a +n when there are more).
class MaisonSwatches extends StatelessWidget {
  final List<Color> colors;
  final int total;
  final Color ink;
  const MaisonSwatches({super.key, required this.colors, required this.total, required this.ink});

  @override
  Widget build(BuildContext context) {
    if (colors.length < 2) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (final c in colors)
        Container(
          width: 11,
          height: 11,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: ink.withValues(alpha: 0.18))),
        ),
      if (total > colors.length) Text('+${total - colors.length}', style: maisonCaps(ink.withValues(alpha: 0.55), size: 9.5)),
    ]);
  }
}

/// Soft, long, low shadow — the family's lift.
List<BoxShadow> maisonShadow([double alpha = 0.16]) => [
      // tucked inside the card's footprint (spread −12, drop 10): only the blur
      // shows, so nothing reads as a hard band on any renderer
      BoxShadow(color: Colors.black.withValues(alpha: alpha), blurRadius: 26, spreadRadius: -12, offset: const Offset(0, 10)),
    ];

// ── The colour sheet ────────────────────────────────────────────────────────
/// Pick the exact colour, see it, add it — a native bottom sheet in place of a
/// trip to the product page.
class MaisonColourSheet extends StatefulWidget {
  final LayoutDatum item;
  final List<MaisonVariant> variants;
  final MaisonColors colors;
  final void Function(String variantId) onAdd;
  const MaisonColourSheet({super.key, required this.item, required this.variants, required this.colors, required this.onAdd});

  @override
  State<MaisonColourSheet> createState() => _MaisonColourSheetState();
}

class _MaisonColourSheetState extends State<MaisonColourSheet> {
  int _picked = 0;

  @override
  Widget build(BuildContext context) {
    final v = widget.variants;
    final picked = v[_picked];
    final deep = widget.colors.deep;
    final price = basketAmount(picked.price.isNotEmpty ? picked.price : widget.item.prices?.sellingPrice);
    final image = picked.image.isNotEmpty ? picked.image : widget.item.image;
    return Container(
      decoration: const BoxDecoration(color: kMaisonIvory, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(width: 40, height: 4, decoration: BoxDecoration(color: kMaisonInk.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 18),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(width: 92, height: 115, child: BasketImage(url: image, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.item.title ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: maisonSerif(kMaisonInk, size: 21)),
              const SizedBox(height: 8),
              if (price.isNotEmpty)
                Text(price, style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kMaisonInk)),
              const SizedBox(height: 4),
              Text('Colour · ${picked.name}', style: maisonBody(kMaisonInk.withValues(alpha: 0.65), size: 12.5)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        Text('CHOOSE YOUR COLOUR', style: maisonCaps(kMaisonInk.withValues(alpha: 0.55))),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: v.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final on = i == _picked;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _picked = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: on ? deep : Colors.transparent, width: 1.6),
                  ),
                  child: Column(children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(fit: StackFit.expand, children: [
                          ColoredBox(color: v[i].swatch ?? const Color(0xFFE9E1D6)),
                          if (v[i].image.isNotEmpty) BasketImage(url: v[i].image, fit: BoxFit.cover),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(v[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: maisonCaps(on ? deep : kMaisonInk.withValues(alpha: 0.6), size: 8.5).copyWith(letterSpacing: 0.8)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: MaisonPill(
            label: 'Add to bag',
            icon: Icons.shopping_bag_outlined,
            fill: deep,
            height: 52,
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onAdd(picked.id);
              Navigator.of(context).pop();
            },
          ),
        ),
      ]),
    );
  }
}
