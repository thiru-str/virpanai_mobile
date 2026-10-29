import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/atelier/atelier_shared.dart' show AtelierCartListener;
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/utility/cart_store.dart';
import 'package:waioz/utility/font_utils.dart';

import 'maison_shared.dart';
import 'maison_viewers.dart';

List<LayoutDatum> _items(Content c, [int max = 99]) => (c.layoutData ?? const <LayoutDatum>[]).take(max).toList();

// ═════════════════════════════════════════════════════════════════════════════
// MaisonHero1 — full-bleed photography with story progress and live serif copy.
// ═════════════════════════════════════════════════════════════════════════════
/// layout_data[i]: image → photo (portrait) · sales_text → kicker · title →
/// headline · feature_text → second line (italic, metal) · sub_title → one
/// line · button_text → CTA · redirect_data. Hold to pause, swipe to move.
class MaisonHero1 extends StatefulWidget {
  final Content content;
  const MaisonHero1({super.key, required this.content});

  @override
  State<MaisonHero1> createState() => _MaisonHero1State();
}

class _MaisonHero1State extends State<MaisonHero1> with SingleTickerProviderStateMixin {
  final _page = PageController();
  // created in initState, never lazily: a one-slide hero would otherwise build
  // it for the first time inside dispose()
  late final AnimationController _clock;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _go(1);
      });
  }

  List<LayoutDatum> get _slides => _items(widget.content, 6);

  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // "Remove animations" (accessibility): hold the slide, no zoom, no clock.
    _still = MediaQuery.of(context).disableAnimations;
    if (_still) {
      _clock.stop();
    } else if (_slides.length > 1 && !_clock.isAnimating) {
      _clock.forward();
    }
  }

  void _go(int dir) {
    final n = _slides.length;
    if (n < 2 || !_page.hasClients) return;
    _page.animateToPage((_active + dir + n) % n, duration: const Duration(milliseconds: 650), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _clock.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    if (slides.isEmpty) return const SizedBox.shrink();
    final colors = MaisonColors.of(widget.content);
    final w = MediaQuery.of(context).size.width;

    return SizedBox(
      height: w * 1.28,
      child: GestureDetector(
        onLongPressStart: (_) => _clock.stop(),
        onLongPressEnd: (_) {
          if (slides.length > 1 && !_still) _clock.forward();
        },
        child: Stack(children: [
          PageView.builder(
            controller: _page,
            itemCount: slides.length,
            onPageChanged: (i) {
              setState(() => _active = i);
              if (slides.length > 1 && !_still) _clock.forward(from: 0);
            },
            itemBuilder: (_, i) {
              final s = slides[i];
              final cta = maisonField(s, ['button_text', 'btnText']);
              return GestureDetector(
                onTap: () => maisonOpenItem(context, widget.content, s),
                child: Stack(fit: StackFit.expand, children: [
                  const ColoredBox(color: Color(0xFF2B2224)),
                  // slow push-in on the active slide
                  TweenAnimationBuilder<double>(
                    key: ValueKey('hero-$i-${i == _active}'),
                    tween: Tween(begin: 1.0, end: i == _active && !_still ? 1.08 : 1.0),
                    duration: const Duration(seconds: 7),
                    curve: Curves.easeOut,
                    builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                    child: BasketImage(url: s.image, fit: BoxFit.cover),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xE0120A0C), Color(0x66120A0C), Color(0x00120A0C), Color(0x33120A0C)],
                        stops: [0, 0.38, 0.62, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 34,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if ((s.salesText ?? '').isNotEmpty) ...[
                        Text(s.salesText!.toUpperCase(), style: maisonCaps(colors.metal, size: 11)),
                        const SizedBox(height: 10),
                      ],
                      if ((s.title ?? '').isNotEmpty) Text(s.title!, style: maisonSerif(Colors.white, size: 42)),
                      if ((s.featureText ?? '').isNotEmpty)
                        Text(s.featureText!, style: maisonSerif(colors.metal, size: 42, italic: true)),
                      if ((s.subTitle ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(s.subTitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: maisonBody(Colors.white.withValues(alpha: 0.86), size: 14)),
                      ],
                      if (cta.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        MaisonPill(label: cta, fill: colors.metal, icon: Icons.arrow_forward_rounded, onTap: () => maisonOpenItem(context, widget.content, s)),
                      ],
                    ]),
                  ),
                ]),
              );
            },
          ),
          if (slides.length > 1)
            Positioned(
              left: 16,
              right: 16,
              top: 14,
              child: Row(children: [
                for (var i = 0; i < slides.length; i++)
                  Expanded(
                    child: Container(
                      height: 2.5,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.32), borderRadius: BorderRadius.circular(2)),
                      alignment: Alignment.centerLeft,
                      child: i < _active
                          ? Container(color: Colors.white)
                          : i == _active
                              ? AnimatedBuilder(
                                  animation: _clock,
                                  builder: (_, __) => FractionallySizedBox(
                                    widthFactor: _clock.value.clamp(0.0, 1.0),
                                    child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                                  ),
                                )
                              : null,
                    ),
                  ),
              ]),
            ),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MaisonStories1 — story rings that open a full-screen viewer.
// ═════════════════════════════════════════════════════════════════════════════
/// layout_data[i]: image → story photo (portrait; also the ring) · video →
/// optional film · title → ring label · sub_title → caption · button_text →
/// CTA · redirect_data. Category-bound items work too (image + title + link).
class MaisonStories1 extends StatelessWidget {
  final Content content;
  const MaisonStories1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 12);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = MaisonColors.of(content);
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.fromLTRB(0, 22, 0, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((content.layoutTitle ?? '').isNotEmpty || (content.layoutSubTitle ?? '').isNotEmpty) MaisonHeader(content: content, colors: colors),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                opaque: true,
                transitionDuration: const Duration(milliseconds: 280),
                pageBuilder: (_, __, ___) => MaisonStoryViewer(content: content, items: items, start: i, colors: colors),
                transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(a), child: child)),
              )),
              child: SizedBox(
                width: 76,
                child: Column(children: [
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(colors: [colors.metal, colors.deep, colors.metal, colors.deep, colors.metal]),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.bg),
                      child: ClipOval(child: BasketImage(url: items[i].image, fit: BoxFit.cover)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_label(items[i].title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: FontUtils.secondaryFontStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: colors.ink)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /// "TUSSAR SAREE" → "Tussar Saree" — ring labels read better in title case.
  static String _label(String? t) => (t ?? '')
      .toLowerCase()
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

// ═════════════════════════════════════════════════════════════════════════════
// ProductMaisonCarousel1 — a snapping 3D carousel of portrait product cards.
// ═════════════════════════════════════════════════════════════════════════════
class ProductMaisonCarousel1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductMaisonCarousel1({super.key, required this.content, this.onCartQtyChanged});

  @override
  State<ProductMaisonCarousel1> createState() => _ProductMaisonCarousel1State();
}

class _ProductMaisonCarousel1State extends State<ProductMaisonCarousel1> {
  final _page = PageController(viewportFraction: 0.72);

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items(widget.content, 16);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = MaisonColors.of(widget.content);
    final cardW = MediaQuery.of(context).size.width * 0.72;
    final height = cardW * 1.25 + 104;

    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MaisonHeader(content: widget.content, colors: colors, onSeeAll: maisonSeeAll(context, widget.content)),
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _page,
            itemCount: items.length,
            itemBuilder: (_, i) => AnimatedBuilder(
              animation: _page,
              builder: (_, child) {
                double delta = 0;
                if (_page.hasClients && _page.position.haveDimensions) delta = (_page.page ?? 0) - i;
                final d = delta.abs().clamp(0.0, 1.0);
                return Transform.scale(scale: 1 - 0.08 * d, child: Opacity(opacity: 1 - 0.35 * d, child: child));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: _MaisonCard(item: items[i], colors: colors, onCartQtyChanged: widget.onCartQtyChanged),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MaisonCard extends StatelessWidget {
  final LayoutDatum item;
  final MaisonColors colors;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const _MaisonCard({required this.item, required this.colors, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final ink = colors.ink;
    final selling = basketAmount(item.prices?.sellingPrice ?? item.subTitle);
    final mrp = basketAmount(item.prices?.originalPrice);
    final off = basketOff(item);
    final swatches = maisonSwatches(item);
    final total = maisonVariants(item).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => maisonOpenProduct(context, item),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), boxShadow: maisonShadow()),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(fit: StackFit.expand, children: [
                const ColoredBox(color: Color(0xFFEDE4D8)),
                BasketImage(url: item.image, fit: BoxFit.cover),
                if (off > 0)
                  Positioned(
                    left: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: colors.deep, borderRadius: BorderRadius.circular(20)),
                      child: Text('$off% OFF', style: maisonCaps(colors.onDeep, size: 9.5)),
                    ),
                  ),
                if (swatches.length > 1)
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                      child: MaisonSwatches(colors: swatches, total: total, ink: kMaisonInk),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: maisonSerif(ink, size: 19).copyWith(height: 1.15)),
            const SizedBox(height: 6),
            Row(children: [
              if (selling.isNotEmpty) Text(selling, style: FontUtils.primaryFontStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: ink)),
              if (off > 0 && mrp.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(mrp, style: FontUtils.secondaryFontStyle(fontSize: 11.5, color: ink.withValues(alpha: 0.45), decoration: TextDecoration.lineThrough)),
              ],
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        _BagButton(item: item, colors: colors, onCartQtyChanged: onCartQtyChanged),
      ]),
    ]);
  }
}

/// The round "add to bag" — shows how many are already in the bag.
class _BagButton extends StatelessWidget {
  final LayoutDatum item;
  final MaisonColors colors;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  final double size;
  const _BagButton({required this.item, required this.colors, this.onCartQtyChanged, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return AtelierCartListener(builder: (_) {
      final ids = {...maisonVariants(item).map((v) => v.id), basketVariantId(item)}..remove('');
      final inBag = ids.fold<int>(0, (n, id) => n + (CartStore.instance.quantityForVariant(id) ?? 0));
      return GestureDetector(
        onTap: () => maisonAdd(context, item, colors, onCartQtyChanged),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: colors.deep, shape: BoxShape.circle, boxShadow: maisonShadow(0.22)),
            child: Icon(inBag > 0 ? Icons.shopping_bag_rounded : Icons.add_rounded, size: size * 0.45, color: colors.onDeep),
          ),
          if (inBag > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: colors.metal, borderRadius: BorderRadius.circular(10)),
                child: Text('$inBag', style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: basketOn(colors.metal))),
              ),
            ),
        ]),
      );
    });
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ProductMaisonGrid1 — a staggered editorial grid with quick add.
// ═════════════════════════════════════════════════════════════════════════════
class ProductMaisonGrid1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductMaisonGrid1({super.key, required this.content, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 12);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = MaisonColors.of(content);
    final ink = colors.ink;

    Widget card(LayoutDatum it) {
      final selling = basketAmount(it.prices?.sellingPrice ?? it.subTitle);
      final count = maisonVariants(it).length;
      return Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => maisonOpenProduct(context, it),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: maisonShadow(0.12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(fit: StackFit.expand, children: [
                    const ColoredBox(color: Color(0xFFEDE4D8)),
                    BasketImage(url: it.image, fit: BoxFit.cover),
                    if (count > 1)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(14)),
                          child: Text('$count colours', style: maisonCaps(kMaisonInk, size: 8.5).copyWith(letterSpacing: 1)),
                        ),
                      ),
                    Positioned(right: 10, bottom: 10, child: _BagButton(item: it, colors: colors, onCartQtyChanged: onCartQtyChanged, size: 38)),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => maisonOpenProduct(context, it),
            child: Text(it.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: maisonSerif(ink, size: 17).copyWith(height: 1.15)),
          ),
          const SizedBox(height: 4),
          if (selling.isNotEmpty) Text(selling, style: FontUtils.primaryFontStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: ink)),
        ]),
      );
    }

    final left = [for (var i = 0; i < items.length; i += 2) card(items[i])];
    final right = [for (var i = 1; i < items.length; i += 2) card(items[i])];
    final more = maisonSeeAll(context, content);
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.only(top: 30, bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MaisonHeader(content: content, colors: colors),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(children: left)),
            const SizedBox(width: 14),
            // the staggered column — the editorial offset that reads as a lookbook
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 46), child: Column(children: right))),
          ]),
        ),
        if (more != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: GestureDetector(
              onTap: more,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: ink.withValues(alpha: 0.25))),
                child: Text(content.layoutRedirectTitle ?? 'View all', style: FontUtils.primaryFontStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: ink)),
              ),
            ),
          ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MaisonReels1 — film cards that open full-screen vertical reels.
// ═════════════════════════════════════════════════════════════════════════════
/// layout_data[i]: video → the film · image → optional poster · title ·
/// sub_title · button_text → CTA in the reel · redirect_data.
class MaisonReels1 extends StatelessWidget {
  final Content content;
  const MaisonReels1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 10).where((d) => (d.video ?? '').trim().isNotEmpty || (d.image ?? '').trim().isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = MaisonColors.of(content);
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MaisonHeader(content: content, colors: colors),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ReelCard(
              item: items[i],
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 260),
                pageBuilder: (_, __, ___) => MaisonReelViewer(content: content, items: items, start: i, colors: colors),
                transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
              )),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ReelCard extends StatefulWidget {
  final LayoutDatum item;
  final VoidCallback onTap;
  const _ReelCard({required this.item, required this.onTap});

  @override
  State<_ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<_ReelCard> with WidgetsBindingObserver {
  VideoPlayerController? _c;
  bool _visible = false;
  bool _foreground = true;

  String get _url => (widget.item.video ?? '').trim();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }

  void _ensure() {
    if (_c != null || _url.isEmpty) return;
    final c = VideoPlayerController.networkUrl(Uri.parse(_url.replaceAll(' ', '%20')));
    _c = c;
    c.setLooping(true);
    c.setVolume(0);
    c.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _sync();
    }).catchError((_) {});
  }

  void _sync() {
    final c = _c;
    if (c == null || !c.value.isInitialized) return;
    (_visible && _foreground) ? c.play() : c.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final ready = c != null && c.value.isInitialized;
    return VisibilityDetector(
      key: ValueKey('maison-reel-${widget.item.id}-${_url.hashCode}'),
      onVisibilityChanged: (info) {
        _visible = info.visibleFraction >= 0.4;
        if (_visible) _ensure();
        // pause before leaving the feed (the full-screen viewer plays its own copy)
        _sync();
      },
      child: GestureDetector(
        onTap: () {
          c?.pause();
          widget.onTap();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: 169,
            height: 300,
            child: Stack(fit: StackFit.expand, children: [
              const ColoredBox(color: Color(0xFF2B2224)),
              if ((widget.item.image ?? '').trim().isNotEmpty) BasketImage(url: widget.item.image, fit: BoxFit.cover),
              if (ready) FittedBox(fit: BoxFit.cover, child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c))),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Color(0xB3000000), Color(0x00000000)]),
                ),
              ),
              const Positioned(right: 10, top: 10, child: Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 22)),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(widget.item.title ?? '',
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: maisonSerif(Colors.white, size: 19).copyWith(height: 1.1)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MaisonChapter1 — an editorial chapter: full-bleed photo, a card over it.
// ═════════════════════════════════════════════════════════════════════════════
/// Same fields as AtelierDrapeStory1: item 0 = photo + button_text/redirect;
/// items 1–2 = close-ups (image + caption); items 3+ = notes (title +
/// feature_text). Section: layout_sub_title, layout_title, layout_description.
class MaisonChapter1 extends StatelessWidget {
  final Content content;
  const MaisonChapter1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = MaisonColors.of(content);
    final lead = items.first;
    final details = items.skip(1).take(2).where((d) => (d.image ?? '').trim().isNotEmpty).toList();
    final notes = items.skip(3).take(4).where((d) => (d.title ?? '').isNotEmpty).toList();
    final cta = maisonField(lead, ['button_text', 'btnText']);
    final desc = maisonRaw(content, 'layout_description');
    final w = MediaQuery.of(context).size.width;

    final photoH = w * 1.12;
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.only(bottom: 30),
      // the card overlaps the photo by 64pt; a Stack (not a translate) so the
      // section's height is the real height and no gap is left under the card
      child: Stack(children: [
        SizedBox(
          width: w,
          height: photoH,
          child: Stack(fit: StackFit.expand, children: [
            const ColoredBox(color: Color(0xFF2B2224)),
            BasketImage(url: lead.image, fit: BoxFit.cover),
          ]),
        ),
        Padding(
          padding: EdgeInsets.only(top: photoH - 64),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
            decoration: BoxDecoration(color: kMaisonIvory, borderRadius: BorderRadius.circular(26), boxShadow: maisonShadow(0.18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CHAPTER  ·  ${(content.layoutSubTitle ?? '').toUpperCase()}', style: maisonCaps(colors.deep.withValues(alpha: 0.75))),
              const SizedBox(height: 8),
              if ((content.layoutTitle ?? '').isNotEmpty) Text(content.layoutTitle!, style: maisonSerif(kMaisonInk, size: 34)),
              const SizedBox(height: 10),
              Container(width: 36, height: 1.5, color: colors.metal),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(desc, style: maisonSerif(kMaisonInk.withValues(alpha: 0.82), size: 19, italic: true).copyWith(height: 1.3)),
              ],
              if (details.isNotEmpty) ...[
                const SizedBox(height: 18),
                Row(children: [
                  for (var i = 0; i < details.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(aspectRatio: 4 / 5, child: BasketImage(url: details[i].image, fit: BoxFit.cover)),
                        ),
                        if ((details[i].title ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(details[i].title!.toUpperCase(), style: maisonCaps(kMaisonInk.withValues(alpha: 0.55), size: 9)),
                        ],
                      ]),
                    ),
                  ],
                ]),
              ],
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                for (final n in notes)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Transform.rotate(angle: 0.785, child: Container(width: 6, height: 6, color: colors.metal)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(n.title!, style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kMaisonInk)),
                          if ((n.featureText ?? '').isNotEmpty)
                            Text(n.featureText!, style: maisonBody(kMaisonInk.withValues(alpha: 0.62), size: 12.5)),
                        ]),
                      ),
                    ]),
                  ),
              ],
              if (cta.isNotEmpty) ...[
                const SizedBox(height: 22),
                MaisonPill(label: cta, fill: colors.deep, icon: Icons.arrow_forward_rounded, onTap: () => maisonOpenItem(context, content, lead)),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MaisonVoices1 — testimonials, swipeable, on the deep band.
// ═════════════════════════════════════════════════════════════════════════════
class MaisonVoices1 extends StatefulWidget {
  final Content content;
  const MaisonVoices1({super.key, required this.content});

  @override
  State<MaisonVoices1> createState() => _MaisonVoices1State();
}

class _MaisonVoices1State extends State<MaisonVoices1> {
  final _page = PageController(viewportFraction: 0.86);
  int _active = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items(widget.content, 8);
    if (items.isEmpty) return const SizedBox.shrink();
    final base = MaisonColors.of(widget.content);
    // the band is the deep colour; the section background is ignored here on purpose
    final colors = MaisonColors(base.deep, base.metal, base.deep);
    return Container(
      color: colors.deep,
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MaisonHeader(content: widget.content, colors: colors, ink: Colors.white),
        SizedBox(
          height: 236,
          child: PageView.builder(
            controller: _page,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _active = i),
            itemBuilder: (_, i) {
              final it = items[i];
              final rating = ((it.rating ?? 5).round()).clamp(0, 5);
              final quote = (it.featureText ?? '').isNotEmpty ? it.featureText! : (it.subTitle ?? '');
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: kMaisonIvory, borderRadius: BorderRadius.circular(24)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      ClipOval(child: SizedBox(width: 46, height: 46, child: BasketImage(url: it.image, fit: BoxFit.cover))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(it.title ?? 'Verified buyer',
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: FontUtils.primaryFontStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: kMaisonInk)),
                          const SizedBox(height: 3),
                          Row(children: [for (var s = 0; s < 5; s++) Icon(Icons.star_rounded, size: 14, color: s < rating ? colors.metal : kMaisonInk.withValues(alpha: 0.15))]),
                        ]),
                      ),
                      Text('“', style: maisonSerif(colors.metal, size: 54).copyWith(height: 0.8)),
                    ]),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Text(quote, maxLines: 4, overflow: TextOverflow.ellipsis, style: maisonSerif(kMaisonInk, size: 19, italic: true).copyWith(height: 1.3)),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < items.length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: i == _active ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(color: i == _active ? colors.metal : Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3)),
            ),
        ]),
      ]),
    );
  }
}
