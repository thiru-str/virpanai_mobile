import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/home/atelier/atelier_shared.dart' show AtelierCartListener;
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/utility/cart_store.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

/// RIBBON — the app family for experience gifting (vouchers for sails,
/// cooking dates, spa rituals). Same layout names and fields as the web
/// ribbon-*.tsx sections, drawn the way a phone wants it: a story hero whose
/// photos crossfade and drift, a city carousel with parallax, a voucher
/// that fills in as you step through how gifting works.
///
///  - White page, one ink (#141414) for type and filled buttons, one accent
///    (periwinkle, Primary Color) for links, the active tab and the stamp.
///    Blush only as the voucher's ground; near-black only behind the hero.
///  - Sofia Sans Extra Condensed (bundled, variable) for headlines and names,
///    Sofia Sans (bundled, variable) for everything else. Neither has a ₹
///    glyph, so the bundled Archivo is the fallback that draws it (run at
///    its narrowest width inside the condensed headlines).
///  - Photos arrive with a fade while settling from a slight zoom; cards rise
///    in a short stagger; anything you can tap gives under the finger.
///    Every motion stops when the phone asks for reduced motion.

const String kRibbonDisplay = 'SofiaSansExtraCondensed';
const String kRibbonText = 'SofiaSans';

/// Draws the ₹ (and anything else Sofia Sans lacks).
const List<String> kRibbonFallback = ['Archivo'];
const Color kRibbonInk = Color(0xFF141414);
const Color kRibbonAccent = Color(0xFF4A56C8);
const Color kRibbonBlush = Color(0xFFFBF1F4);
const Color kRibbonNight = Color(0xFF0F0F12);
const Color kRibbonMist = Color(0xFFF1F1F3);

class RibbonColors {
  final Color bg;
  final Color accent;
  final Color ink;
  const RibbonColors(this.bg, this.accent, this.ink);

  bool get dark => bg.computeLuminance() < 0.35;
  Color get soft => ink.withValues(alpha: 0.66);
  Color get line => ink.withValues(alpha: 0.12);
  Color get onInk => basketOn(ink);

  factory RibbonColors.of(Content c, {Color ground = Colors.white}) {
    final bg = basketParseColor(c.layoutBgColor) ?? ground;
    final dark = bg.computeLuminance() < 0.35;
    var accent = basketParseColor(c.layoutPrimaryColor) ?? kRibbonAccent;
    // a dark accent disappears on a dark ground: lift it toward white
    if (dark && accent.computeLuminance() < 0.2) accent = Color.lerp(accent, Colors.white, 0.55)!;
    return RibbonColors(bg, accent, basketParseColor(c.layoutSecondaryColor) ?? (dark ? Colors.white : kRibbonInk));
  }
}

// ── Type ────────────────────────────────────────────────────────────────────
TextStyle ribbonDisplay(Color color, {double size = 34, FontWeight weight = FontWeight.w800, double height = 0.96}) => TextStyle(
      fontFamily: kRibbonDisplay,
      fontSize: size,
      fontWeight: weight,
      fontFamilyFallback: kRibbonFallback,
      fontVariations: [FontVariation('wght', weight.value.toDouble()), const FontVariation('wdth', 62)],
      height: height,
      color: color,
    );

TextStyle ribbonText(Color color, {double size = 14.5, FontWeight weight = FontWeight.w400, double height = 1.5}) => TextStyle(
      fontFamily: kRibbonText,
      fontFamilyFallback: kRibbonFallback,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      height: height,
      color: color,
    );

// ── Data helpers ────────────────────────────────────────────────────────────
List<LayoutDatum> ribbonItems(Content c, [int max = 99]) => (c.layoutData ?? const <LayoutDatum>[]).take(max).toList();

/// First non-empty of an item's fields: the app API passes custom fields as
/// saved (btnText, mobileMedia) next to the normalised ones.
String ribbonField(LayoutDatum d, List<String> keys) {
  for (final k in keys) {
    final v = d.rawString(k).trim();
    if (v.isNotEmpty && v != 'null') return v;
  }
  return '';
}

String ribbonRaw(Content c, String key) {
  final v = c.rawString(key).trim();
  return v == 'null' ? '' : v;
}

String ribbonTrim(String? v) => (v ?? '').trim();

/// "Mumbai, for two" → "Mumbai".
String ribbonCity(LayoutDatum d) {
  final f = ribbonTrim(d.featureText);
  final i = f.indexOf(',');
  return (i < 0 ? f : f.substring(0, i)).trim();
}

/// "Mumbai, for two" → "For two".
String ribbonParty(LayoutDatum d) {
  final f = ribbonTrim(d.featureText);
  final i = f.indexOf(',');
  if (i < 0) return '';
  final p = f.substring(i + 1).split(',').first.trim();
  return p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}';
}

/// The selling price ("₹3,500"); a product item's sub_title is its price.
String ribbonPrice(LayoutDatum d) {
  final list = d.raw['product_variants'];
  final variantPrice = list is List && list.isNotEmpty && list.first is Map ? (list.first as Map)['variant_price']?.toString() : null;
  for (final v in [d.prices?.sellingPrice, variantPrice, d.subTitle]) {
    final a = basketAmount(v);
    if (a.isNotEmpty) return a;
  }
  return '';
}

/// The one buyable variant (a voucher), or '' when the shopper must choose.
String ribbonVariantId(LayoutDatum d) {
  final list = d.raw['product_variants'];
  final n = list is List ? list.length : 0;
  if (n > 1) return '';
  final id = basketVariantId(d);
  if (id.isNotEmpty) return id;
  if (n == 1 && list!.first is Map) return ((list.first as Map)['variant_id'] ?? '').toString();
  return '';
}

bool ribbonHasLink(LayoutDatum d) => (d.redirectData?.redirectType ?? '').trim().isNotEmpty;

void ribbonOpenProduct(BuildContext context, LayoutDatum item) {
  final id = item.id ?? '';
  if (id.isNotEmpty) PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: id));
}

void ribbonOpenItem(BuildContext context, LayoutDatum item) {
  if (!ribbonHasLink(item)) return;
  RedirectUtils.handleContentRedirect(context: context, layoutOption: 'Custom', layoutData: item);
}

/// The section's own button (layout_redirect_title + redirect_data).
VoidCallback? ribbonSeeAll(BuildContext context, Content content) => basketSeeAll(context, content);

/// Where the hero's "How gifting works" scrolls to: the mounted RibbonHow1.
final ValueNotifier<GlobalKey?> ribbonHowAnchor = ValueNotifier<GlobalKey?>(null);

bool ribbonStill(BuildContext context) => MediaQuery.maybeOf(context)?.disableAnimations ?? false;

// ── Motion ──────────────────────────────────────────────────────────────────
/// Plays once when its child first comes into view (after [delay]).
/// [builder] gets the eased 0→1 progress; [child] stays a constant subtree.
class RibbonOnView extends StatefulWidget {
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Widget child;
  final Widget Function(BuildContext context, double t, Widget child) builder;
  const RibbonOnView({
    super.key,
    required this.child,
    required this.builder,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeInOutCubic,
  });

  @override
  State<RibbonOnView> createState() => _RibbonOnViewState();
}

class _RibbonOnViewState extends State<RibbonOnView> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Key _key = UniqueKey();
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ribbonStill(context)) {
      _timer?.cancel();
      _c.value = 1;
      _started = true;
    }
  }

  void _start() {
    if (_started) return;
    _started = true;
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: _key,
        onVisibilityChanged: (info) {
          if (!_started && mounted && info.visibleFraction > 0.12) _start();
        },
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) => widget.builder(context, widget.curve.transform(_c.value), child!),
          child: widget.child,
        ),
      );
}

/// A photo arriving: it fades in while settling from a slight zoom, once,
/// when it first comes into view. A quiet mist sits behind it meanwhile.
/// (The rise comes from the card around it, so no mist edge ever shows.)
class RibbonSettle extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Color background;
  const RibbonSettle({super.key, required this.child, this.delay = Duration.zero, this.background = kRibbonMist});

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: background,
        child: RibbonOnView(
          delay: delay,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 1.05 - 0.05 * t, child: child),
          ),
          child: child,
        ),
      );
}

/// Press feedback that feels native: a slight scale-down while the finger is
/// on it, a selection tick on tap. Still with reduced motion.
class RibbonPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;
  const RibbonPress({super.key, required this.child, this.onTap, this.scale = 0.97, this.haptic = true});

  @override
  State<RibbonPress> createState() => _RibbonPressState();
}

class _RibbonPressState extends State<RibbonPress> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: enabled
          ? () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _down && !ribbonStill(context) ? widget.scale : 1,
        duration: Duration(milliseconds: _down ? 90 : 220),
        curve: _down ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// Snappy, springy scrolling on every platform, the way a native app scrolls.
const ScrollPhysics kRibbonRailPhysics = BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
const ScrollPhysics kRibbonPagePhysics = PageScrollPhysics(parent: BouncingScrollPhysics());

/// Fades and lifts a block into place: the list stagger.
class RibbonRise extends StatelessWidget {
  final Widget child;
  final Duration delay;
  const RibbonRise({super.key, required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) => RibbonOnView(
        delay: delay,
        duration: const Duration(milliseconds: 620),
        curve: Curves.easeOutCubic,
        builder: (_, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
        ),
        child: child,
      );
}

/// Grows or shrinks smoothly as its child changes (still with reduced
/// motion: AnimatedSize must never run with a zero duration).
class RibbonSize extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  const RibbonSize({super.key, required this.child, this.alignment = Alignment.topCenter});

  @override
  Widget build(BuildContext context) => ribbonStill(context)
      ? child
      : AnimatedSize(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic, alignment: alignment, child: child);
}

/// Switcher curves: the old content leaves in the first half, the new one
/// arrives in the second, so two blocks of text never sit on each other.
const Curve kRibbonIn = Interval(0.45, 1, curve: Curves.easeOutCubic);
const Curve kRibbonOut = Interval(0.55, 1, curve: Curves.easeInCubic);

/// 60–80 ms between neighbours, capped so a long rail doesn't lag.
Duration ribbonStagger(int index) => Duration(milliseconds: 70 * (index % 4));

// ── Pieces ──────────────────────────────────────────────────────────────────
/// Section head: condensed title, one plain line under it, an optional link.
class RibbonHeader extends StatelessWidget {
  final Content content;
  final RibbonColors colors;
  final String? link;
  final VoidCallback? onLink;
  const RibbonHeader({super.key, required this.content, required this.colors, this.link, this.onLink});

  @override
  Widget build(BuildContext context) {
    final title = ribbonTrim(content.layoutTitle);
    final sub = ribbonTrim(content.layoutSubTitle);
    if (title.isEmpty && sub.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title.isNotEmpty) Text(title, style: ribbonDisplay(colors.ink, size: 42, height: 0.95)),
        if (sub.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(sub, style: ribbonText(colors.soft, size: 15)),
        ],
        if (link != null && onLink != null) ...[
          const SizedBox(height: 10),
          RibbonLink(label: link!, color: colors.accent, onTap: onLink!),
        ],
      ]),
    );
  }
}

/// A plain text link in the accent, underlined.
class RibbonLink extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double size;
  final Color? underline;
  const RibbonLink({super.key, required this.label, required this.color, required this.onTap, this.size = 15, this.underline});

  @override
  Widget build(BuildContext context) => RibbonPress(
        onTap: onTap,
        scale: 0.96,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(label,
              style: ribbonText(color, size: size, weight: FontWeight.w600).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: (underline ?? color).withValues(alpha: 0.45),
                decorationThickness: 1.4,
              )),
        ),
      );
}

/// The family's button: 12pt corners, filled in a colour or outlined.
class RibbonButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;
  final double height;
  final IconData? icon;
  const RibbonButton({super.key, required this.label, required this.color, this.filled = false, this.onTap, this.height = 46, this.icon});

  @override
  Widget build(BuildContext context) {
    final on = filled ? basketOn(color) : color;
    return RibbonPress(
      onTap: onTap,
      haptic: false,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: color.withValues(alpha: 0.85), width: 1.2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 17, color: on), const SizedBox(width: 8)],
            Text(label, maxLines: 1, style: ribbonText(on, size: 15, weight: FontWeight.w600, height: 1.1)),
          ]),
        ),
      ),
    );
  }
}

/// Once a voucher is in the bag: − n in bag +, filled in the ink.
class RibbonStepper extends StatelessWidget {
  final int count;
  final Color color;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final double height;
  const RibbonStepper({super.key, required this.count, required this.color, required this.onInc, required this.onDec, this.height = 46});

  @override
  Widget build(BuildContext context) {
    final on = basketOn(color);
    Widget btn(IconData icon, VoidCallback tap) => RibbonPress(
          onTap: tap,
          scale: 0.85,
          child: SizedBox(width: 42, height: height, child: Icon(icon, size: 18, color: on)),
        );
    return Container(
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        btn(Icons.remove_rounded, onDec),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('$count in bag', maxLines: 1, style: ribbonText(on, size: 14.5, weight: FontWeight.w600, height: 1.1)),
          ),
        ),
        btn(Icons.add_rounded, onInc),
      ]),
    );
  }
}

/// A small frosted label over a photo.
class RibbonFrost extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool light;
  const RibbonFrost(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      this.radius = 8,
      this.light = true});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: light ? Colors.white.withValues(alpha: 0.82) : Colors.black.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(radius),
              border: light ? null : Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: child,
          ),
        ),
      );
}

// ── The experience card ─────────────────────────────────────────────────────
/// 4:5 photo that settles in, the city on the photo, the name in the
/// condensed face, price and party, and "Gift this" that puts the voucher
/// straight in the bag (then the − n +). Tap anywhere else opens it.
class RibbonExperienceCard extends StatelessWidget {
  final LayoutDatum item;
  final RibbonColors colors;
  final int index;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const RibbonExperienceCard({super.key, required this.item, required this.colors, this.index = 0, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final ink = colors.ink;
    final city = ribbonCity(item);
    final party = ribbonParty(item);
    final price = ribbonPrice(item);
    final variantId = ribbonVariantId(item);
    final delay = ribbonStagger(index);
    final nameH = MediaQuery.textScalerOf(context).scale(21) * 2 + 2;

    final Widget action;
    if (variantId.isEmpty || onCartQtyChanged == null) {
      action = RibbonButton(label: 'Choose', color: ink, onTap: () => ribbonOpenProduct(context, item));
    } else {
      action = AtelierCartListener(builder: (_) {
        final n = CartStore.instance.quantityForVariant(variantId) ?? item.cartDetails?.quantity ?? 0;
        return AnimatedSwitcher(
          duration: ribbonStill(context) ? Duration.zero : const Duration(milliseconds: 260),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(a), child: child),
          ),
          child: n > 0
              ? RibbonStepper(
                  key: const ValueKey('stepper'),
                  count: n,
                  color: ink,
                  onInc: () => onCartQtyChanged!(1, variantId),
                  onDec: () => onCartQtyChanged!(-1, variantId),
                )
              : RibbonButton(
                  key: const ValueKey('gift'),
                  label: 'Gift this',
                  color: ink,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onCartQtyChanged!(1, variantId);
                  },
                ),
        );
      });
    }

    return RibbonRise(
      delay: delay,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        RibbonPress(
          onTap: () => ribbonOpenProduct(context, item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(fit: StackFit.expand, children: [
                RibbonSettle(delay: delay, child: BasketImage(url: item.image, fit: BoxFit.cover)),
                if (city.isNotEmpty)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: RibbonFrost(child: Text(city, style: ribbonText(kRibbonInk, size: 12, weight: FontWeight.w600, height: 1.2))),
                  ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => ribbonOpenProduct(context, item),
          child: SizedBox(
            height: nameH,
            child: Text(item.title ?? '',
                maxLines: 2, overflow: TextOverflow.ellipsis, style: ribbonDisplay(ink, size: 21, weight: FontWeight.w700, height: 1.0)),
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          if (price.isNotEmpty) Text(price, style: ribbonText(ink, size: 15, weight: FontWeight.w700, height: 1.25)),
          if (price.isNotEmpty && party.isNotEmpty) const SizedBox(width: 8),
          if (party.isNotEmpty)
            Flexible(
                child: Text(party, maxLines: 1, overflow: TextOverflow.ellipsis, style: ribbonText(colors.soft, size: 13.5, height: 1.25))),
        ]),
        const SizedBox(height: 12),
        action,
      ]),
    );
  }
}
