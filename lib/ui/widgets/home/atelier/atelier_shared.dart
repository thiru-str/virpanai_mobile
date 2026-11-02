import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/utility/cart_store.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

/// ATELIER — the app side of the web storefront's premium boutique family
/// (web: modules/dynamic-components/atelier-*.tsx). Same layout names, same
/// builder fields, so a store's web home can also be its app home.
///
///  - THE ARCH: every portrait sits in a frame whose top is a true
///    semicircle, with a thin keyline arch inset over the photograph.
///  - TWO COLOURS WITH JOBS: Card Background (layout_card_color) is the
///    "deep" — type, buttons, inverted bands; Primary (layout_primary_color)
///    is the "metal" — kickers, keylines, the rose rule, prices on dark.
///  - QUIET TYPE: letter-spaced small caps over a light display title, a
///    hairline · rose · hairline rule under it.
///  - ONE ACTION PER CARD: a one-colour piece adds straight to the bag (and
///    becomes a stepper on the live cart); several colours/sizes open the
///    product page to choose.

const Color kAtelierTeal = Color(0xFF0E4A45);
const Color kAtelierGold = Color(0xFFC9AD7A);
const Color kAtelierIvory = Color(0xFFFAF6EE);

const List<String> kAtelierNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];

/// Style-tab colours of one Atelier section, mirroring atelierAccent /
/// atelierDeep on the web.
class AtelierColors {
  final Color bg;
  final Color accent;
  final Color deep;
  const AtelierColors(this.bg, this.accent, this.deep);

  factory AtelierColors.of(Content c, {Color ground = kAtelierIvory}) => AtelierColors(
        basketParseColor(c.layoutBgColor) ?? ground,
        basketParseColor(c.layoutPrimaryColor) ?? kAtelierGold,
        basketParseColor(c.layoutCardColor) ?? kAtelierTeal,
      );
}

// ── Data helpers ────────────────────────────────────────────────────────────
/// The category / fabric line. For product items the store transform puts the
/// PRICE in sub_title and the real subtitle in product_sub_title.
String atelierChip(LayoutDatum d) {
  final ps = d.rawString('product_sub_title').trim();
  if (ps.isNotEmpty && ps != 'null') return ps;
  final st = (d.subTitle ?? '').trim();
  return st.isNotEmpty && !RegExp(r'^[\d.,\s₹]+$').hasMatch(st) ? st : '';
}

/// Distinct variants, as the web's distinctVariantCount() counts them.
int atelierVariantCount(LayoutDatum d) {
  final ids = <String>{};
  for (final key in ['product_variants', 'variants']) {
    final list = d.raw[key];
    if (list is List) {
      for (final v in list) {
        if (v is Map) {
          final id = (v['variant_id'] ?? v['id'] ?? '').toString();
          if (id.isNotEmpty) ids.add(id);
        }
      }
    }
  }
  return ids.isNotEmpty ? ids.length : (int.tryParse(d.rawString('no_of_variants')) ?? 0);
}

/// The word on the multi-variant CTA ("size" by default; a saree store says "colour").
String atelierVariantLabel(Content c) {
  final v = c.rawString('layout_variant_label').trim();
  return v.isEmpty || v == 'null' ? 'size' : v;
}

/// Opens a product item's page, or a custom item's redirect.
void atelierOpen(BuildContext context, Content content, LayoutDatum item) =>
    basketOpen(context, content, item);

/// The section's own link (layout_redirect_title + redirect).
VoidCallback? atelierSectionLink(BuildContext context, Content content) {
  final r = content.redirectData;
  if ((content.layoutRedirectTitle ?? '').isEmpty || r == null) return null;
  final hasTarget = (r.redirectType ?? '').isNotEmpty;
  if (!hasTarget) return null;
  return () => RedirectUtils.handleContentRedirectViewAll(context: context, redirectData: r);
}

// ── Type ────────────────────────────────────────────────────────────────────
TextStyle atelierKickerStyle(Color color, {double size = 11}) =>
    FontUtils.secondaryFontStyle(fontSize: size, fontWeight: FontWeight.w600, letterSpacing: size * 0.3, color: color);

TextStyle atelierDisplayStyle(Color color, {double size = 30}) =>
    FontUtils.primaryFontStyle(fontSize: size, fontWeight: FontWeight.w400, letterSpacing: -0.2, color: color)
        .copyWith(height: 1.1);

TextStyle atelierBodyStyle(Color color, {double size = 14.5}) =>
    FontUtils.secondaryFontStyle(fontSize: size, color: color).copyWith(height: 1.6);

class AtelierKicker extends StatelessWidget {
  final String text;
  final Color color;
  final TextAlign align;
  const AtelierKicker(this.text, {super.key, required this.color, this.align = TextAlign.center});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Text(text.toUpperCase(), textAlign: align, style: atelierKickerStyle(color));
  }
}

// ── Ornament ────────────────────────────────────────────────────────────────
const String _roseSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="1.25" stroke-linecap="round">
<path d="M12 5.6c-2.7 0-4.1 2.5-2.9 4.6 1.2 2.1 4.3 1.9 4.9-.4.5-1.9-1-3-2.5-2.4-1.1.5-1.1 2.2 0 2.5"/>
<path d="M12 10.3c2 .9 1.9 4.2-.6 5.2-2.5 1-4.8-.7-4.4-3"/>
<path d="M14.1 9.8c2.6-.9 4.4 1.3 3.4 3.7-.8 2-3.2 2.4-4.5 1"/>
<path d="M11.6 15.6c.2 1.2.1 2.3-.3 3.4"/>
</svg>''';

/// Hairline, line-art rose, hairline.
class AtelierRoseRule extends StatelessWidget {
  final Color color;
  final double width;
  const AtelierRoseRule({super.key, required this.color, this.width = 168});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.6)));
    return SizedBox(
      width: width,
      child: Row(children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SvgPicture.string(_roseSvg,
              width: 20, height: 20, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        ),
        line,
      ]),
    );
  }
}

/// Kicker, light display title, the rose rule, optional description.
class AtelierHeading extends StatelessWidget {
  final String title;
  final String kicker;
  final String description;
  final AtelierColors colors;
  final bool inverted;
  final bool center;
  const AtelierHeading({
    super.key,
    required this.title,
    required this.kicker,
    this.description = '',
    required this.colors,
    this.inverted = false,
    this.center = true,
  });

  factory AtelierHeading.of(Content c, AtelierColors colors, {bool inverted = false, bool center = true}) =>
      AtelierHeading(
        title: c.layoutTitle ?? '',
        kicker: c.layoutSubTitle ?? '',
        description: c.rawString('layout_description') == 'null' ? '' : c.rawString('layout_description'),
        colors: colors,
        inverted: inverted,
        center: center,
      );

  @override
  Widget build(BuildContext context) {
    if (title.trim().isEmpty && kicker.trim().isEmpty) return const SizedBox.shrink();
    final align = center ? TextAlign.center : TextAlign.start;
    final titleColor = inverted ? kAtelierIvory : colors.deep;
    final bodyColor = inverted ? kAtelierIvory.withValues(alpha: 0.74) : colors.deep.withValues(alpha: 0.72);
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (kicker.trim().isNotEmpty) ...[
          AtelierKicker(kicker, color: colors.accent, align: align),
          const SizedBox(height: 10),
        ],
        if (title.trim().isNotEmpty) Text(title, textAlign: align, style: atelierDisplayStyle(titleColor)),
        const SizedBox(height: 12),
        AtelierRoseRule(color: colors.accent),
        if (description.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(description, textAlign: align, style: atelierBodyStyle(bodyColor)),
        ],
      ],
    );
  }
}

/// Small-caps underlined link — the family's secondary action.
class AtelierTextLink extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const AtelierTextLink({super.key, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty || onTap == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color))),
            child: Text(label.toUpperCase(), style: atelierKickerStyle(color, size: 11).copyWith(letterSpacing: 2.6)),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, size: 14, color: color),
        ]),
      ),
    );
  }
}

// ── The arch ────────────────────────────────────────────────────────────────
/// A rectangle whose top edge is a semicircle the full width of the frame.
Path atelierArchPath(Rect r) {
  final radius = r.width / 2;
  return Path()
    ..moveTo(r.left, r.bottom)
    ..lineTo(r.left, r.top + radius)
    ..arcToPoint(Offset(r.right, r.top + radius), radius: Radius.circular(radius))
    ..lineTo(r.right, r.bottom)
    ..close();
}

class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => atelierArchPath(Offset.zero & size);
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _KeylinePainter extends CustomPainter {
  final Color color;
  final double inset;
  const _KeylinePainter(this.color, this.inset);
  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2);
    canvas.drawPath(
        atelierArchPath(r),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color);
  }

  @override
  bool shouldRepaint(covariant _KeylinePainter old) => old.color != color || old.inset != inset;
}

/// The arch portrait: photograph clipped to the arch, a keyline arch inset
/// over it, and any overlay (gradient, badge) on top.
class AtelierArch extends StatelessWidget {
  final String? image;
  final Color background;
  final Color? keyline;
  final double aspectRatio;
  final List<Widget> overlays;
  const AtelierArch({
    super.key,
    this.image,
    required this.background,
    this.keyline,
    this.aspectRatio = 2 / 3,
    this.overlays = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipPath(
        clipper: _ArchClipper(),
        child: Stack(fit: StackFit.expand, children: [
          ColoredBox(color: background),
          if ((image ?? '').trim().isNotEmpty) BasketImage(url: image, fit: BoxFit.cover),
          ...overlays,
          if (keyline != null) CustomPaint(painter: _KeylinePainter(keyline!, 7)),
        ]),
      ),
    );
  }
}

/// A plain rectangular frame with the inset keyline (the drape story's close-ups).
class AtelierFrame extends StatelessWidget {
  final String? image;
  final Color background;
  final Color keyline;
  final double aspectRatio;
  const AtelierFrame({super.key, this.image, required this.background, required this.keyline, this.aspectRatio = 4 / 5});

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(fit: StackFit.expand, children: [
          ColoredBox(color: background),
          if ((image ?? '').trim().isNotEmpty) BasketImage(url: image, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(7),
            child: DecoratedBox(decoration: BoxDecoration(border: Border.all(color: keyline))),
          ),
        ]),
      );
}

// ── Actions ─────────────────────────────────────────────────────────────────
/// A square outlined action in the deep colour (ADD / CHOOSE COLOUR / SOLD OUT).
class AtelierSquareButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool muted;
  const AtelierSquareButton({super.key, required this.label, required this.color, this.onTap, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final c = muted ? color.withValues(alpha: 0.5) : color;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: muted ? color.withValues(alpha: 0.25) : color)),
        child: Text(label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: atelierKickerStyle(c, size: 11).copyWith(letterSpacing: 2.2)),
      ),
    );
  }
}

/// ADD → a filled −/n/+ stepper in the deep colour, square like the web's.
class AtelierStepper extends StatelessWidget {
  final int count;
  final Color color;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const AtelierStepper({super.key, required this.count, required this.color, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return AtelierSquareButton(label: 'Add', color: color, onTap: onInc);
    final on = basketOn(color);
    Widget btn(IconData icon, VoidCallback tap) => GestureDetector(
          onTap: tap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(width: 48, height: 44, child: Icon(icon, size: 17, color: on)),
        );
    return Container(
      height: 44,
      color: color,
      child: Row(children: [
        btn(Icons.remove_rounded, onDec),
        Expanded(
          child: Text('$count',
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: on)),
        ),
        btn(Icons.add_rounded, onInc),
      ]),
    );
  }
}

/// Rebuilds its child whenever the live cart changes (adds, steps, rollbacks
/// from any screen), so steppers on the home feed stay true.
class AtelierCartListener extends StatefulWidget {
  final WidgetBuilder builder;
  const AtelierCartListener({super.key, required this.builder});

  @override
  State<AtelierCartListener> createState() => _AtelierCartListenerState();
}

class _AtelierCartListenerState extends State<AtelierCartListener> {
  StreamSubscription<CartStateEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = eventBus.on<CartStateEvent>().listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

// ── Product card ────────────────────────────────────────────────────────────
/// The family's product card: an arch portrait, the category line in small
/// caps, a two-line name, price with the compare-at, and one action — a
/// one-colour piece adds straight to the bag, several open the page to choose.
class AtelierProductCard extends StatelessWidget {
  final LayoutDatum item;
  final AtelierColors colors;
  final String variantLabel;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const AtelierProductCard({
    super.key,
    required this.item,
    required this.colors,
    required this.variantLabel,
    this.onCartQtyChanged,
  });

  void _open(BuildContext context) {
    final id = item.id ?? '';
    if (id.isNotEmpty) PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: id));
  }

  @override
  Widget build(BuildContext context) {
    final deep = colors.deep;
    final off = basketOff(item);
    final selling = basketAmount(item.prices?.sellingPrice ?? item.subTitle);
    final mrp = basketAmount(item.prices?.originalPrice);
    final chip = atelierChip(item);
    final choose = atelierVariantCount(item) > 1;
    final variantId = basketVariantId(item);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      GestureDetector(
        onTap: () => _open(context),
        child: AtelierArch(
          image: item.image,
          background: deep.withValues(alpha: 0.07),
          keyline: colors.accent.withValues(alpha: 0.75),
          overlays: [
            if (off > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    color: deep,
                    child: Text('$off% OFF', style: atelierKickerStyle(colors.accent, size: 10).copyWith(letterSpacing: 2)),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        height: 14,
        child: chip.isEmpty
            ? null
            : Text(chip.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: atelierKickerStyle(deep.withValues(alpha: 0.58), size: 10).copyWith(letterSpacing: 2.4)),
      ),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () => _open(context),
        child: SizedBox(
          height: 40,
          child: Text(item.title ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(fontSize: 14.5, color: deep).copyWith(height: 1.35)),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        height: 22,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (selling.isNotEmpty)
            Text(selling, style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w600, color: deep)),
          if (off > 0 && mrp.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(mrp,
                style: FontUtils.secondaryFontStyle(
                    fontSize: 12, color: deep.withValues(alpha: 0.45), decoration: TextDecoration.lineThrough)),
          ],
        ]),
      ),
      const SizedBox(height: 12),
      if (choose || variantId.isEmpty || onCartQtyChanged == null)
        AtelierSquareButton(label: choose ? 'Choose $variantLabel' : 'View', color: deep, onTap: () => _open(context))
      else
        AtelierCartListener(
          builder: (_) => AtelierStepper(
            count: CartStore.instance.quantityForVariant(variantId) ?? item.cartDetails?.quantity ?? 0,
            color: deep,
            onInc: () => onCartQtyChanged!(1, variantId),
            onDec: () => onCartQtyChanged!(-1, variantId),
          ),
        ),
    ]);
  }
}

/// Section frame: the ground colour and the family's generous vertical air.
class AtelierSection extends StatelessWidget {
  final Color bg;
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AtelierSection({super.key, required this.bg, required this.child, this.padding = const EdgeInsets.fromLTRB(16, 44, 16, 40)});

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, color: bg, padding: padding, child: child);
}
