import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/utility/font_utils.dart';

/// THEATRE — the app family for home-cinema and hi-fi stores, the native twin
/// of the web THEATRE sections (same layout names, same fields), drawn the way
/// a phone wants it: a story-style still hero, rails you swipe, a segmented
/// layout picker with the room drawn from above, full-screen reels.
///
///  - The screening room: a near-black NIGHT ground and VELVET panels, the
///    screen's warm white for type, the lamp's AMBER as the one warm accent
///    (Primary Color), the house RED only for actions.
///  - Hardware shot on white stands on a pale PLATE (Card Background on the
///    light shelves); cut-outs stand in a pool of amber light.
///  - Archivo (bundled, variable) run wide for kickers, layouts and figures,
///    and for prices (it carries ₹); body copy in the store's own font.

const String kTheatreFont = 'Archivo';
const Color kTheatreNight = Color(0xFF0B0A0E);
const Color kTheatreVelvet = Color(0xFF15131A);
const Color kTheatreStage = Color(0xFF201D26);
const Color kTheatreScreen = Color(0xFFF4F1EC);
const Color kTheatreAmber = Color(0xFFF2B33D);
const Color kTheatreRed = Color(0xFFE3262B);
const Color kTheatrePlate = Color(0xFFE9E5DF);
const Color kTheatrePaper = Color(0xFFF4F1EC);
const Color kTheatreInk = Color(0xFF141217);

class TheatreColors {
  final Color bg;
  final Color accent;
  final Color card;
  final Color? textOverride;
  const TheatreColors(this.bg, this.accent, this.card, this.textOverride);

  bool get dark => bg.computeLuminance() < 0.35;
  Color get ink => textOverride ?? (dark ? kTheatreScreen : kTheatreInk);
  Color get soft => ink.withValues(alpha: 0.62);
  Color get line => ink.withValues(alpha: dark ? 0.12 : 0.14);

  /// The kicker colour: amber reads on the night, the house red on paper.
  Color get kicker => dark ? accent : (accent == kTheatreAmber ? kTheatreRed : accent);

  factory TheatreColors.of(Content c, {Color ground = kTheatreNight, Color? card}) {
    final bg = basketParseColor(c.layoutBgColor) ?? ground;
    final dark = bg.computeLuminance() < 0.35;
    return TheatreColors(
      bg,
      basketParseColor(c.layoutPrimaryColor) ?? kTheatreAmber,
      basketParseColor(c.layoutCardColor) ?? card ?? (dark ? kTheatreVelvet : kTheatrePlate),
      basketParseColor(c.layoutSecondaryColor),
    );
  }
}

// ── Type ────────────────────────────────────────────────────────────────────
TextStyle theatreWide(Color color, {double size = 11, FontWeight weight = FontWeight.w600, double tracking = 0.22}) => TextStyle(
      fontFamily: kTheatreFont,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wdth', 125), FontVariation('wght', weight.value.toDouble())],
      letterSpacing: size * tracking,
      height: 1.15,
      color: color,
    );

TextStyle theatreDisplay(Color color, {double size = 28, FontWeight weight = FontWeight.w600}) => TextStyle(
      fontFamily: kTheatreFont,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wdth', 108), FontVariation('wght', weight.value.toDouble())],
      letterSpacing: -0.2,
      height: 1.04,
      color: color,
    );

TextStyle theatreBody(Color color, {double size = 13.5, FontWeight weight = FontWeight.w400}) =>
    FontUtils.secondaryFontStyle(fontSize: size, fontWeight: weight, color: color).copyWith(height: 1.5);

/// Prices in the bundled Archivo, which carries ₹ (store fonts may not).
TextStyle theatrePrice(Color color, {double size = 16}) => theatreDisplay(color, size: size, weight: FontWeight.w700).copyWith(height: 1.2);

// ── Data helpers ────────────────────────────────────────────────────────────
List<LayoutDatum> theatreItems(Content c, [int max = 99]) => (c.layoutData ?? const <LayoutDatum>[]).take(max).toList();

/// First non-empty of an item's fields (the app API passes builder names through as saved).
String theatreField(LayoutDatum d, List<String> keys) => basketField(d, keys);

String theatreRaw(Content c, String key) {
  final v = c.rawString(key).trim();
  return v == 'null' ? '' : v;
}

String theatreFeature(LayoutDatum d) => (d.featureText ?? '').trim().isNotEmpty ? d.featureText!.trim() : theatreField(d, ['feature_text', 'secondaryText', 'secondary_text']);
String theatreSales(LayoutDatum d) => (d.salesText ?? '').trim().isNotEmpty ? d.salesText!.trim() : theatreField(d, ['sales_text', 'description']);
String theatreSub(LayoutDatum d) => (d.subTitle ?? '').trim().isNotEmpty ? d.subTitle!.trim() : theatreField(d, ['sub_title', 'subTitle']);
String theatreButton(LayoutDatum d) => theatreField(d, ['button_text', 'btnText']);

/// The product an item is bound to (product_data), or null.
LayoutDatum? theatreBound(LayoutDatum d) {
  final p = d.raw['product_data'];
  if (p is Map && p.isNotEmpty && (p['id'] ?? '').toString().isNotEmpty) return LayoutDatum.fromJson(Map<String, dynamic>.from(p));
  return null;
}

const _brands = ['Bowers & Wilkins', 'Monitor Audio', 'Pure Acoustics', 'Polk Audio', 'Denon', 'Marantz', 'Polk', 'Klipsch', 'Jamo', 'Sony', 'BenQ', 'Yamaha', 'Onkyo', 'KEF', 'Taga', 'Sonodyne'];

/// The maker, read off the start of a product title.
String theatreBrand(String title) {
  final t = title.trim().toLowerCase();
  for (final b in _brands) {
    if (t.startsWith(b.toLowerCase())) return b == 'Polk' ? 'Polk Audio' : b;
  }
  return '';
}

/// The product name without the maker it starts with.
String theatreModel(String title) {
  final b = theatreBrand(title);
  final t = title.trim();
  if (b.isEmpty) return t;
  final cut = t.toLowerCase().startsWith(b.toLowerCase()) ? b.length : (t.toLowerCase().startsWith('polk') ? 4 : 0);
  final rest = t.substring(cut).replaceFirst(RegExp(r'^[\s\-–—:×x]+'), '');
  return rest.isEmpty ? t : rest;
}

/// Spec chips read off a title: channel layout, video, Atmos, wireless.
List<String> theatreSpecs(String title) {
  final out = <String>[];
  final ch = RegExp(r'\b(\d{1,2}\.\d(?:\.\d)?)\s*(?:-?\s*(?:ch|channel))?\b', caseSensitive: false).firstMatch(title);
  if (ch != null) out.add('${ch.group(1)} CH');
  if (RegExp(r'\b8k\b', caseSensitive: false).hasMatch(title)) {
    out.add('8K');
  } else if (RegExp(r'\b4k\b', caseSensitive: false).hasMatch(title)) {
    out.add('4K');
  }
  if (RegExp('atmos', caseSensitive: false).hasMatch(title)) out.add('ATMOS');
  if (RegExp(r'wireless|bluetooth|heos', caseSensitive: false).hasMatch(title)) out.add('WIRELESS');
  return out.take(3).toList();
}

// ── Pieces ──────────────────────────────────────────────────────────────────
/// A row of equaliser bars — the family's ornament.
class TheatreBars extends StatelessWidget {
  final Color color;
  const TheatreBars({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    const h = [5.0, 9.0, 14.0, 8.0, 12.0, 6.0, 10.0];
    return SizedBox(
      height: 14,
      child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < h.length; i++)
          Container(
            width: 2.6,
            height: h[i],
            margin: const EdgeInsets.only(right: 2.6),
            decoration: BoxDecoration(color: color.withValues(alpha: i.isOdd ? 0.65 : 1), borderRadius: BorderRadius.circular(2)),
          ),
      ]),
    );
  }
}

/// Section head: bars + kicker in wide caps, the title, optional copy and a "see all".
class TheatreHeader extends StatelessWidget {
  final Content content;
  final TheatreColors colors;
  final VoidCallback? onSeeAll;
  const TheatreHeader({super.key, required this.content, required this.colors, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle ?? '';
    final kicker = content.layoutSubTitle ?? '';
    final copy = theatreRaw(content, 'layout_description');
    if (title.isEmpty && kicker.isEmpty) return const SizedBox.shrink();
    final seeAll = content.layoutRedirectTitle ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (kicker.isNotEmpty)
          Row(children: [
            TheatreBars(color: colors.kicker),
            const SizedBox(width: 10),
            Flexible(child: Text(kicker.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: theatreWide(colors.kicker, size: 10.5))),
          ]),
        if (kicker.isNotEmpty && title.isNotEmpty) const SizedBox(height: 10),
        if (title.isNotEmpty) Text(title, maxLines: 3, overflow: TextOverflow.ellipsis, style: theatreDisplay(colors.ink, size: 26)),
        if (copy.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(copy, maxLines: 3, overflow: TextOverflow.ellipsis, style: theatreBody(colors.soft, size: 13)),
        ],
        if (onSeeAll != null && seeAll.isNotEmpty) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(seeAll.toUpperCase(), style: theatreWide(colors.ink, size: 10.5)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 15, color: colors.kicker),
            ]),
          ),
        ],
      ]),
    );
  }
}

/// The pale stage a packshot stands on (white grounds multiply into it).
class TheatrePlate extends StatelessWidget {
  final String? url;
  final Color plate;
  final double radius;
  final EdgeInsets padding;
  const TheatrePlate({super.key, required this.url, this.plate = kTheatrePlate, this.radius = 8, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(center: const Alignment(0, -0.4), radius: 1.0, colors: [Color.lerp(plate, Colors.white, 0.55)!, plate]),
          ),
          child: Padding(
            padding: padding,
            child: ColorFiltered(
              // multiply: the studio's white sinks into the plate instead of boxing the product
              colorFilter: ColorFilter.mode(plate, BlendMode.multiply),
              child: BasketImage(url: url, fit: BoxFit.contain),
            ),
          ),
        ),
      );
}
