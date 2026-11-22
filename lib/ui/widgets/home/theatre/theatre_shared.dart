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
  Color get kicker =>
      dark ? accent : (accent == kTheatreAmber ? kTheatreRed : accent);

  factory TheatreColors.of(Content c,
      {Color ground = kTheatreNight, Color? card}) {
    final bg = basketParseColor(c.layoutBgColor) ?? ground;
    final dark = bg.computeLuminance() < 0.35;
    return TheatreColors(
      bg,
      basketParseColor(c.layoutPrimaryColor) ?? kTheatreAmber,
      basketParseColor(c.layoutCardColor) ??
          card ??
          (dark ? kTheatreVelvet : kTheatrePlate),
      basketParseColor(c.layoutSecondaryColor),
    );
  }
}

// ── Type ────────────────────────────────────────────────────────────────────
TextStyle theatreWide(Color color,
        {double size = 11,
        FontWeight weight = FontWeight.w600,
        double tracking = 0.22}) =>
    TextStyle(
      fontFamily: kTheatreFont,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [
        FontVariation('wdth', 125),
        FontVariation('wght', weight.value.toDouble())
      ],
      letterSpacing: size * tracking,
      height: 1.15,
      color: color,
    );

TextStyle theatreDisplay(Color color,
        {double size = 28, FontWeight weight = FontWeight.w600}) =>
    TextStyle(
      fontFamily: kTheatreFont,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [
        FontVariation('wdth', 108),
        FontVariation('wght', weight.value.toDouble())
      ],
      letterSpacing: -0.2,
      height: 1.04,
      color: color,
    );

TextStyle theatreBody(Color color,
        {double size = 13.5, FontWeight weight = FontWeight.w400}) =>
    FontUtils.secondaryFontStyle(
            fontSize: size, fontWeight: weight, color: color)
        .copyWith(height: 1.5);

/// Prices in the bundled Archivo, which carries ₹ (store fonts may not).
TextStyle theatrePrice(Color color, {double size = 16}) =>
    theatreDisplay(color, size: size, weight: FontWeight.w700)
        .copyWith(height: 1.2);

// ── Data helpers ────────────────────────────────────────────────────────────
List<LayoutDatum> theatreItems(Content c, [int max = 99]) =>
    (c.layoutData ?? const <LayoutDatum>[]).take(max).toList();

/// First non-empty of an item's fields (the app API passes builder names through as saved).
String theatreField(LayoutDatum d, List<String> keys) => basketField(d, keys);

String theatreRaw(Content c, String key) {
  final v = c.rawString(key).trim();
  return v == 'null' ? '' : v;
}

String theatreFeature(LayoutDatum d) => (d.featureText ?? '').trim().isNotEmpty
    ? d.featureText!.trim()
    : theatreField(d, ['feature_text', 'secondaryText', 'secondary_text']);
String theatreSales(LayoutDatum d) => (d.salesText ?? '').trim().isNotEmpty
    ? d.salesText!.trim()
    : theatreField(d, ['sales_text', 'description']);
String theatreSub(LayoutDatum d) => (d.subTitle ?? '').trim().isNotEmpty
    ? d.subTitle!.trim()
    : theatreField(d, ['sub_title', 'subTitle']);
String theatreButton(LayoutDatum d) =>
    theatreField(d, ['button_text', 'btnText']);

/// The product an item is bound to (product_data), or null.
LayoutDatum? theatreBound(LayoutDatum d) {
  final p = d.raw['product_data'];
  if (p is Map && p.isNotEmpty && (p['id'] ?? '').toString().isNotEmpty)
    return LayoutDatum.fromJson(Map<String, dynamic>.from(p));
  return null;
}

const _brands = [
  'Bowers & Wilkins',
  'Monitor Audio',
  'Pure Acoustics',
  'Polk Audio',
  'Denon',
  'Marantz',
  'Polk',
  'Klipsch',
  'Jamo',
  'Sony',
  'BenQ',
  'Yamaha',
  'Onkyo',
  'KEF',
  'Taga',
  'Sonodyne'
];

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
  final cut = t.toLowerCase().startsWith(b.toLowerCase())
      ? b.length
      : (t.toLowerCase().startsWith('polk') ? 4 : 0);
  final rest = t.substring(cut).replaceFirst(RegExp(r'^[\s\-–—:×x]+'), '');
  return rest.isEmpty ? t : rest;
}

/// Spec chips read off a title: channel layout, video, Atmos, wireless.
List<String> theatreSpecs(String title) {
  final out = <String>[];
  final ch = RegExp(r'\b(\d{1,2}\.\d(?:\.\d)?)\s*(?:-?\s*(?:ch|channel))?\b',
          caseSensitive: false)
      .firstMatch(title);
  if (ch != null) out.add('${ch.group(1)} CH');
  if (RegExp(r'\b8k\b', caseSensitive: false).hasMatch(title)) {
    out.add('8K');
  } else if (RegExp(r'\b4k\b', caseSensitive: false).hasMatch(title)) {
    out.add('4K');
  }
  if (RegExp('atmos', caseSensitive: false).hasMatch(title)) out.add('ATMOS');
  if (RegExp(r'wireless|bluetooth|heos', caseSensitive: false).hasMatch(title))
    out.add('WIRELESS');
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
      child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < h.length; i++)
              Container(
                width: 2.6,
                height: h[i],
                margin: const EdgeInsets.only(right: 2.6),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: i.isOdd ? 0.65 : 1),
                    borderRadius: BorderRadius.circular(2)),
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
  const TheatreHeader(
      {super.key, required this.content, required this.colors, this.onSeeAll});

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
            Flexible(
                child: Text(kicker.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theatreWide(colors.kicker, size: 10.5))),
          ]),
        if (kicker.isNotEmpty && title.isNotEmpty) const SizedBox(height: 10),
        if (title.isNotEmpty)
          Text(title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theatreDisplay(colors.ink, size: 26)),
        if (copy.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(copy,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theatreBody(colors.soft, size: 13)),
        ],
        if (onSeeAll != null && seeAll.isNotEmpty) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(seeAll.toUpperCase(),
                  style: theatreWide(colors.ink, size: 10.5)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 15, color: colors.kicker),
            ]),
          ),
        ],
      ]),
    );
  }
}

/// The pale stage a packshot stands on (white grounds multiply into it). With
/// [waves] set, sound-wave rings ripple out from behind the product (see
/// [TheatreSoundWaves]); [seed] (the product title) gives each tile its own
/// starting point so a grid never pulses in step.
class TheatrePlate extends StatelessWidget {
  final String? url;
  final Color plate;
  final double radius;
  final EdgeInsets padding;
  final bool waves;
  final String seed;
  const TheatrePlate(
      {super.key,
      required this.url,
      this.plate = kTheatrePlate,
      this.radius = 8,
      this.padding = const EdgeInsets.all(14),
      this.waves = false,
      this.seed = ''});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 1.0,
                colors: [Color.lerp(plate, Colors.white, 0.55)!, plate]),
          ),
          child: Stack(fit: StackFit.passthrough, children: [
            // the rings go on the stage first, so the product stands in front
            // of them (as on the web)
            if (waves) Positioned.fill(child: TheatreSoundWaves(seed: seed)),
            Padding(
              padding: padding,
              child: ColorFiltered(
                colorFilter: waves
                    ? theatreCutOutFilter(plate)
                    // multiply: the studio's white sinks into the plate instead of boxing the product
                    : ColorFilter.mode(plate, BlendMode.multiply),
                child: BasketImage(url: url, fit: BoxFit.contain),
              ),
            ),
          ]),
        ),
      );
}

/// Lifts a packshot off its studio white so whatever sits behind it (the
/// stage gradient, the sound waves) shows through, the way the web's
/// `mix-blend-multiply` does: near-white pixels turn transparent, anything
/// darker than about 75% grey stays solid, and colours are tinted by [plate]
/// as a multiply would. Flutter widgets can't blend with what's beneath them,
/// so this is done with alpha instead.
ColorFilter theatreCutOutFilter(Color plate) {
  // alpha = 4 * (alpha - average brightness): 0 on pure white, solid below
  // ~75% grey, and still 0 where the layer is empty (no offset term, or the
  // whole layer would turn black)
  const k = 4.0;
  return ColorFilter.matrix(<double>[
    plate.r, 0, 0, 0, 0, //
    0, plate.g, 0, 0, 0, //
    0, 0, plate.b, 0, 0, //
    -k / 3, -k / 3, -k / 3, k, 0, //
  ]);
}

/// The family's motion touch (the app twin of the web's SoundWaves): three thin
/// rings ripple out from the centre of the stage like sound from a speaker,
/// behind the product (see [TheatrePlate]), fading as they grow: 27% ink (the
/// web's 32% at 85%), a line that scales with the stage (1 px on a phone tile,
/// 1.75 px on a 300 px stage, as on the web), a 4.2 s cycle, each ring a third
/// of a cycle behind the last. Starts at a point seeded by the product so tiles
/// don't pulse together; nothing is drawn when the phone has animations off.
class TheatreSoundWaves extends StatefulWidget {
  final String seed;
  final Color ink;
  const TheatreSoundWaves({super.key, this.seed = '', this.ink = kTheatreInk});

  @override
  State<TheatreSoundWaves> createState() => _TheatreSoundWavesState();
}

class _TheatreSoundWavesState extends State<TheatreSoundWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    var h = 0;
    for (final u in widget.seed.codeUnits) {
      h = (h * 31 + u) & 0x7fffffff;
    }
    _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 4200),
        value: (h % 1000) / 1000);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
      return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
          painter: _WavesPainter(_c, widget.ink.withValues(alpha: 0.27))),
    );
  }
}

class _WavesPainter extends CustomPainter {
  final Animation<double> t;
  final Color color;
  _WavesPainter(this.t, this.color) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final base = size.shortestSide *
        0.82 /
        2; // ring diameter at full size: 82% of the stage
    for (var k = 0; k < 3; k++) {
      final p = (t.value + k / 3) % 1.0;
      final eased = Curves.easeOutCubic.transform(p);
      final scale = 0.32 + (1.3 - 0.32) * eased;
      // fade in over the first 18%, then out as it grows
      final o = p < 0.18 ? p / 0.18 : 1 - (p - 0.18) / 0.82;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (size.shortestSide * 0.0058).clamp(1.0, 1.75)
        ..blendMode = BlendMode.multiply
        ..color = color.withValues(alpha: color.a * o.clamp(0.0, 1.0));
      canvas.drawCircle(centre, base * scale, paint);
    }
  }

  @override
  bool shouldRepaint(_WavesPainter old) => old.color != color;
}
