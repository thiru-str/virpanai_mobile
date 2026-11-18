import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';

import 'ribbon_shared.dart';

// ═════════════════════════════════════════════════════════════════════════════
// RibbonHero1 — a story hero: progress bars, tap to step, soft crossfades.
// ═════════════════════════════════════════════════════════════════════════════
/// layout_data[i]: mobileMedia → phone photo (4:5, preferred) · image →
/// desktop photo (fallback) · title → caption · sub_title → city and price ·
/// redirect_data. Section: layout_title (headline), layout_sub_title (copy),
/// layout_redirect_title + redirect_data (button), placeholder_text (second
/// button, scrolls to RibbonHow1 when it is on the page).
class RibbonHero1 extends StatefulWidget {
  final Content content;
  const RibbonHero1({super.key, required this.content});

  @override
  State<RibbonHero1> createState() => _RibbonHero1State();
}

class _RibbonHero1State extends State<RibbonHero1> with TickerProviderStateMixin {
  // both created in initState, never lazily (a lazy controller first touched
  // in dispose() crashes)
  late final AnimationController _clock;
  late final AnimationController _open;
  final Key _seen = UniqueKey();
  int _active = 0;
  int _prev = -1;
  double _prevScale = 1;
  bool _still = false;
  bool _held = false;
  bool _visible = true;

  static String _photoOf(LayoutDatum s) {
    final m = ribbonField(s, ['mobileMedia', 'mobile_media', 'mobileImage', 'mobile_image']);
    return m.isNotEmpty ? m : ribbonTrim(s.image);
  }

  List<LayoutDatum> get _slides => ribbonItems(widget.content, 6).where((s) => _photoOf(s).isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: const Duration(milliseconds: 6500))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _go(1);
      });
    _open = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100), value: 1)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && _prev >= 0 && mounted) setState(() => _prev = -1);
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = ribbonStill(context);
    _sync();
  }

  void _sync() {
    if (!_still && !_held && _visible && _slides.isNotEmpty) {
      if (!_clock.isAnimating && !_clock.isCompleted) _clock.forward();
    } else {
      _clock.stop();
    }
  }

  double get _drift => _still ? 1.0 : 1.05 - 0.05 * Curves.easeOut.transform(_clock.value);

  void _go(int dir) {
    final n = _slides.length;
    if (n < 2 || !mounted) return;
    HapticFeedback.selectionClick();
    setState(() {
      _prevScale = _drift;
      _prev = _active;
      _active = (_active + dir + n) % n;
    });
    if (_still) {
      _open.value = 1;
      setState(() => _prev = -1);
    } else {
      _open.forward(from: 0);
    }
    _clock.value = 0;
    _sync();
  }

  @override
  void dispose() {
    _clock.dispose();
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    if (slides.isEmpty) return const SizedBox.shrink();
    if (_active >= slides.length) _active = 0;
    final content = widget.content;
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = (mq.size.height * 0.78).clamp(480.0, 820.0);
    final bg = basketParseColor(content.layoutBgColor) ?? kRibbonNight;
    final title = ribbonTrim(content.layoutTitle);
    final copy = ribbonTrim(content.layoutSubTitle);
    final primary = ribbonTrim(content.layoutRedirectTitle);
    final onPrimary = ribbonSeeAll(context, content);
    final second = ribbonRaw(content, 'placeholder_text');
    final slide = slides[_active];

    final buttons = ValueListenableBuilder<GlobalKey?>(
      valueListenable: ribbonHowAnchor,
      builder: (context, anchor, _) {
        final target = anchor?.currentContext;
        final showSecond = second.isNotEmpty && target != null;
        final showPrimary = primary.isNotEmpty && onPrimary != null;
        if (!showPrimary && !showSecond) return const SizedBox.shrink();
        final a = showPrimary ? RibbonButton(label: primary, color: Colors.white, filled: true, onTap: onPrimary, height: 48) : null;
        final b = showSecond
            ? RibbonButton(
                label: second,
                color: Colors.white,
                height: 48,
                onTap: () {
                  final ctx = ribbonHowAnchor.value?.currentContext;
                  if (ctx == null) return;
                  Scrollable.ensureVisible(ctx,
                      duration: _still ? Duration.zero : const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
                },
              )
            : null;
        if (a != null && b != null) {
          return Row(children: [Expanded(child: a), const SizedBox(width: 10), Expanded(child: b)]);
        }
        return Row(mainAxisSize: MainAxisSize.min, children: [a ?? b!]);
      },
    );

    return VisibilityDetector(
      key: _seen,
      onVisibilityChanged: (info) {
        final v = info.visibleFraction > 0.3;
        if (v != _visible && mounted) {
          _visible = v;
          _sync();
        }
      },
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _go(d.localPosition.dx < w * 0.32 ? -1 : 1),
          onLongPressStart: (_) {
            _held = true;
            _sync();
          },
          onLongPressEnd: (_) {
            _held = false;
            _sync();
          },
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v.abs() > 150) _go(v < 0 ? 1 : -1);
          },
          child: ColoredBox(
            color: bg,
            child: Stack(fit: StackFit.expand, children: [
              if (_prev >= 0 && _prev < slides.length)
                Transform.scale(scale: _prevScale, child: BasketImage(url: _photoOf(slides[_prev]), fit: BoxFit.cover)),
              AnimatedBuilder(
                animation: Listenable.merge([_open, _clock]),
                // a soft crossfade over the last photo, the new one settling
                // from a slight zoom into the slow drift
                builder: (_, child) {
                  final o = Curves.easeOutCubic.transform(_open.value);
                  return Opacity(
                    opacity: Curves.easeOut.transform(_open.value),
                    child: Transform.scale(scale: _drift + 0.03 * (1 - o), child: child),
                  );
                },
                child: KeyedSubtree(key: ValueKey('ribbon-hero-$_active'), child: BasketImage(url: _photoOf(slide), fit: BoxFit.cover)),
              ),
              // shallow, only where the words and the bars sit
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66000000), Color(0x00000000), Color(0x00000000), Color(0x8C000000), Color(0xD9000000)],
                      stops: [0, 0.17, 0.4, 0.7, 1],
                    ),
                  ),
                ),
              ),
              if (slides.length > 1)
                Positioned(
                  left: 14,
                  right: 14,
                  top: 12,
                  child: Row(children: [
                    for (var i = 0; i < slides.length; i++)
                      Expanded(
                        child: Container(
                          height: 2.5,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.32), borderRadius: BorderRadius.circular(2)),
                          alignment: Alignment.centerLeft,
                          child: i < _active
                              ? Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)))
                              : i == _active
                                  ? AnimatedBuilder(
                                      animation: _clock,
                                      builder: (_, __) => FractionallySizedBox(
                                        widthFactor: _still ? 1 : _clock.value.clamp(0.0, 1.0),
                                        child: Container(
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                  ]),
                ),
              Positioned(
                left: 14,
                top: 28,
                child: AnimatedSwitcher(
                  duration: _still ? Duration.zero : const Duration(milliseconds: 460),
                  switchInCurve: kRibbonIn,
                  switchOutCurve: kRibbonOut,
                  transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(position: Tween(begin: const Offset(0, -0.25), end: Offset.zero).animate(a), child: child),
                  ),
                  child: KeyedSubtree(key: ValueKey('ribbon-cap-$_active'), child: _caption(context, slide, w)),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 26,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  if (title.isNotEmpty) Text(title, style: ribbonDisplay(Colors.white, size: (w * 0.14).clamp(44.0, 60.0), height: 0.92)),
                  if (copy.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(copy,
                        maxLines: 4, overflow: TextOverflow.ellipsis, style: ribbonText(Colors.white.withValues(alpha: 0.86), size: 15)),
                  ],
                  const SizedBox(height: 20),
                  buttons,
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _caption(BuildContext context, LayoutDatum s, double w) {
    final name = ribbonTrim(s.title);
    final line = ribbonTrim(s.subTitle);
    if (name.isEmpty && line.isEmpty) return const SizedBox.shrink();
    return RibbonPress(
      onTap: ribbonHasLink(s) ? () => ribbonOpenItem(context, s) : null,
      child: RibbonFrost(
        light: false,
        radius: 12,
        padding: const EdgeInsets.fromLTRB(12, 8, 14, 9),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w * 0.72),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            if (name.isNotEmpty)
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ribbonText(Colors.white, size: 14, weight: FontWeight.w600, height: 1.3)),
            if (line.isNotEmpty)
              Text(line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ribbonText(Colors.white.withValues(alpha: 0.8), size: 12.5, height: 1.3)),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RibbonCities1 — tall city cards in a carousel, the photo moving under them.
// ═════════════════════════════════════════════════════════════════════════════
/// layout_data[i]: image · title (city) · sub_title ("10 experiences") ·
/// feature_text (what's there) · btnText (link label) · redirect_data.
class RibbonCities1 extends StatefulWidget {
  final Content content;
  const RibbonCities1({super.key, required this.content});

  @override
  State<RibbonCities1> createState() => _RibbonCities1State();
}

class _RibbonCities1State extends State<RibbonCities1> {
  final _page = PageController(viewportFraction: 0.78);

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ribbonItems(widget.content, 12);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = RibbonColors.of(widget.content);
    final w = MediaQuery.of(context).size.width;
    final cardW = w * 0.78;
    final height = cardW * 1.3;

    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RibbonHeader(content: widget.content, colors: colors),
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _page,
            physics: kRibbonPagePhysics,
            itemCount: items.length,
            itemBuilder: (_, i) => RibbonRise(
              delay: ribbonStagger(i),
              child: AnimatedBuilder(
                animation: _page,
                builder: (_, child) {
                  double delta = 0;
                  if (_page.hasClients && _page.position.haveDimensions) delta = (_page.page ?? 0) - i;
                  final d = delta.clamp(-1.0, 1.0);
                  return Transform.scale(
                    scale: 1 - 0.07 * d.abs(),
                    child: _CityCard(item: items[i], shift: d, cardW: cardW, index: i),
                  );
                },
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _CityCard extends StatelessWidget {
  final LayoutDatum item;
  final double shift;
  final double cardW;
  final int index;
  const _CityCard({required this.item, required this.shift, required this.cardW, required this.index});

  @override
  Widget build(BuildContext context) {
    final city = ribbonTrim(item.title);
    final count = ribbonTrim(item.subTitle);
    final line = ribbonTrim(item.featureText);
    final link = ribbonField(item, ['btnText', 'button_text', 'buttonText']);
    return RibbonPress(
      onTap: () => ribbonOpenItem(context, item),
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(fit: StackFit.expand, children: [
            RibbonSettle(
              delay: ribbonStagger(index),
              child: ClipRect(
                child: Transform.translate(
                  // parallax: the photo travels slower than the card
                  offset: Offset(shift * cardW * 0.14, 0),
                  child: Transform.scale(scale: 1.2, child: BasketImage(url: item.image, fit: BoxFit.cover)),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x00000000), Color(0x99000000), Color(0xD9000000)],
                  stops: [0, 0.42, 0.74, 1],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                if (count.isNotEmpty)
                  Text(count, style: ribbonText(Colors.white.withValues(alpha: 0.85), size: 13.5, weight: FontWeight.w500)),
                if (city.isNotEmpty)
                  Text(city, maxLines: 1, overflow: TextOverflow.ellipsis, style: ribbonDisplay(Colors.white, size: 52, height: 1.0)),
                if (line.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(line,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ribbonText(Colors.white.withValues(alpha: 0.86), size: 14, height: 1.4)),
                ],
                if (link.isNotEmpty && ribbonHasLink(item)) ...[
                  const SizedBox(height: 10),
                  RibbonLink(label: link, color: Colors.white, onTap: () => ribbonOpenItem(context, item), size: 14.5),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RibbonTabs1 — mood tabs over a rail of experience cards.
// ═════════════════════════════════════════════════════════════════════════════
/// layout_data[i] = a tab: title (label) · multi_product_data (products) ·
/// btnText + redirect_data (see all).
class RibbonTabs1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const RibbonTabs1({super.key, required this.content, this.onCartQtyChanged});

  @override
  State<RibbonTabs1> createState() => _RibbonTabs1State();
}

class _RibbonTabs1State extends State<RibbonTabs1> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = ribbonItems(widget.content, 8).where((t) => ribbonTrim(t.title).isNotEmpty && basketMultiProducts(t).isNotEmpty).toList();
    if (tabs.isEmpty) return const SizedBox.shrink();
    if (_tab >= tabs.length) _tab = 0;
    final colors = RibbonColors.of(widget.content);
    final still = ribbonStill(context);
    final tab = tabs[_tab];
    final products = basketMultiProducts(tab).take(12).toList();
    final w = MediaQuery.of(context).size.width;
    final cardW = (w * 0.58).clamp(200.0, 260.0);
    final ts = MediaQuery.textScalerOf(context);
    final railH = cardW * 1.25 + 12 + ts.scale(21) * 2 + 2 + 6 + ts.scale(15) * 1.25 + 12 + 46 + 4;
    final more = ribbonField(tab, ['btnText', 'button_text', 'buttonText']);

    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RibbonHeader(content: widget.content, colors: colors),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: kRibbonRailPhysics,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            for (var i = 0; i < tabs.length; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (i == _tab) return;
                  HapticFeedback.selectionClick();
                  setState(() => _tab = i);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 22),
                  child: AnimatedContainer(
                    duration: still ? Duration.zero : const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.only(top: 6, bottom: 9),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: i == _tab ? colors.accent : Colors.transparent, width: 2.2)),
                    ),
                    child: Text(tabs[i].title!,
                        style: ribbonText(i == _tab ? colors.ink : colors.soft,
                            size: 16, weight: i == _tab ? FontWeight.w700 : FontWeight.w500, height: 1.2)),
                  ),
                ),
              ),
          ]),
        ),
        Container(height: 1, color: colors.line),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: still ? Duration.zero : const Duration(milliseconds: 460),
          switchInCurve: kRibbonIn,
          switchOutCurve: kRibbonOut,
          layoutBuilder: (current, previous) => Stack(alignment: Alignment.topLeft, children: [...previous, if (current != null) current]),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(a), child: child),
          ),
          child: SizedBox(
            key: ValueKey('ribbon-tab-$_tab'),
            height: railH,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: kRibbonRailPhysics,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: cardW,
                child: RibbonExperienceCard(item: products[i], colors: colors, index: i, onCartQtyChanged: widget.onCartQtyChanged),
              ),
            ),
          ),
        ),
        if (more.isNotEmpty && ribbonHasLink(tab))
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: RibbonLink(label: more, color: colors.accent, onTap: () => ribbonOpenItem(context, tab)),
          ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RibbonHow1 — one voucher that fills in as you step through gifting.
// ═════════════════════════════════════════════════════════════════════════════
/// Three items. Step 1: title, sub_title, image (photo on the voucher),
/// sales_text (experience), feature_text (city and price). Step 2: title,
/// sub_title, sales_text ("For Ananya, from Rohan"), feature_text (the note).
/// Step 3: title, sub_title, sales_text (booked date), feature_text (validity).
class RibbonHow1 extends StatefulWidget {
  final Content content;
  const RibbonHow1({super.key, required this.content});

  @override
  State<RibbonHow1> createState() => _RibbonHow1State();
}

class _RibbonHow1State extends State<RibbonHow1> {
  final _anchor = GlobalKey();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    // registered after the frame: the hero listens, and must not rebuild mid-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ribbonHowAnchor.value = _anchor;
    });
  }

  @override
  void dispose() {
    final mine = _anchor;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ribbonHowAnchor.value == mine) ribbonHowAnchor.value = null;
    });
    super.dispose();
  }

  void _to(int i, int n) {
    final next = (i + n) % n;
    if (next == _step) return;
    HapticFeedback.selectionClick();
    setState(() => _step = next);
  }

  @override
  Widget build(BuildContext context) {
    final steps = ribbonItems(widget.content, 3);
    if (steps.isEmpty) return SizedBox.shrink(key: _anchor);
    final n = steps.length;
    if (_step >= n) _step = 0;
    final colors = RibbonColors.of(widget.content, ground: kRibbonBlush);
    final still = ribbonStill(context);
    final dur = still ? Duration.zero : const Duration(milliseconds: 460);
    final copy = ribbonTrim(steps[_step].subTitle);

    return Container(
      key: _anchor,
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RibbonHeader(content: widget.content, colors: colors),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = 0; i < n; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _to(i, n),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AnimatedContainer(
                      duration: dur,
                      height: 3,
                      decoration: BoxDecoration(
                          color: i <= _step ? colors.accent : colors.ink.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 10),
                    AnimatedDefaultTextStyle(
                      duration: dur,
                      style: ribbonText(i == _step ? colors.ink : colors.soft,
                          size: 14, weight: i == _step ? FontWeight.w700 : FontWeight.w500, height: 1.3),
                      child: Text(ribbonTrim(steps[i].title), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RibbonSize(
            alignment: Alignment.topLeft,
            child: AnimatedSwitcher(
              duration: dur,
              switchInCurve: kRibbonIn,
              switchOutCurve: kRibbonOut,
              layoutBuilder: (current, previous) =>
                  Stack(alignment: Alignment.topLeft, children: [...previous, if (current != null) current]),
              child: Text(copy, key: ValueKey('ribbon-how-copy-$_step'), style: ribbonText(colors.soft, size: 15)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v.abs() > 150) _to(_step + (v < 0 ? 1 : -1), n);
            },
            child: RibbonPress(
              onTap: () => _to(_step + 1, n),
              scale: 0.985,
              haptic: false,
              child: _Voucher(steps: steps, step: _step, colors: colors, duration: dur),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Voucher extends StatelessWidget {
  final List<LayoutDatum> steps;
  final int step;
  final RibbonColors colors;
  final Duration duration;
  const _Voucher({required this.steps, required this.step, required this.colors, required this.duration});

  @override
  Widget build(BuildContext context) {
    final first = steps.first;
    final name = ribbonTrim(first.salesText).isNotEmpty ? ribbonTrim(first.salesText) : ribbonTrim(first.title);
    final line = ribbonTrim(first.featureText);
    final photo = steps.map((s) => ribbonTrim(s.image)).firstWhere((u) => u.isNotEmpty, orElse: () => '');

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final photoH = photo.isEmpty ? 0.0 : w * 0.56;
      final foldY = photo.isEmpty ? 64.0 : photoH;
      return ClipPath(
        clipper: _TicketClipper(foldY),
        clipBehavior: Clip.antiAlias,
        child: ColoredBox(
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (photo.isNotEmpty)
              SizedBox(
                height: photoH,
                child: Stack(fit: StackFit.expand, children: [
                  RibbonSettle(child: BasketImage(url: photo, fit: BoxFit.cover)),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: kRibbonInk, borderRadius: BorderRadius.circular(8)),
                      child: Text('Gift voucher', style: ribbonText(Colors.white, size: 12.5, weight: FontWeight.w600, height: 1.2)),
                    ),
                  ),
                ]),
              ),
            SizedBox(height: 1, child: CustomPaint(painter: _Perforation(kRibbonInk.withValues(alpha: 0.22)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: RibbonSize(
                alignment: Alignment.topCenter,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (photo.isEmpty) ...[
                    Text('Gift voucher', style: ribbonText(colors.accent, size: 13, weight: FontWeight.w600)),
                    const SizedBox(height: 6),
                  ],
                  if (name.isNotEmpty) Text(name, style: ribbonDisplay(kRibbonInk, size: 30, height: 1.0)),
                  if (line.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(line, style: ribbonText(kRibbonInk.withValues(alpha: 0.66), size: 15, weight: FontWeight.w500)),
                  ],
                  AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: kRibbonIn,
                    switchOutCurve: kRibbonOut,
                    layoutBuilder: (current, previous) =>
                        Stack(alignment: Alignment.topLeft, children: [...previous, if (current != null) current]),
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(position: Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(a), child: child),
                    ),
                    child: KeyedSubtree(key: ValueKey('ribbon-voucher-$step'), child: _state(context)),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
    });
  }

  Widget _state(BuildContext context) {
    if (step == 0 || step >= steps.length) return const SizedBox(width: double.infinity);
    final s = steps[step];
    final head = ribbonTrim(s.salesText);
    final body = ribbonTrim(s.featureText);
    if (step == 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (head.isNotEmpty) Text(head, style: ribbonText(kRibbonInk, size: 15, weight: FontWeight.w700)),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('“$body”', style: ribbonText(kRibbonInk, size: 18, weight: FontWeight.w500, height: 1.4)),
          ],
          const SizedBox(height: 14),
          const Wrap(spacing: 8, runSpacing: 8, children: [
            _SentChip(icon: Icons.chat_outlined, label: 'Sent on WhatsApp'),
            _SentChip(icon: Icons.mail_outline_rounded, label: 'Sent by email'),
          ]),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (head.isNotEmpty)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                    padding: const EdgeInsets.only(top: 2), child: Icon(Icons.event_available_outlined, size: 18, color: colors.accent)),
                const SizedBox(width: 8),
                Expanded(child: Text(head, style: ribbonText(kRibbonInk, size: 15, weight: FontWeight.w700, height: 1.35))),
              ]),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Text(body, style: ribbonText(kRibbonInk.withValues(alpha: 0.66), size: 14)),
              ),
            ],
          ]),
        ),
        const SizedBox(width: 10),
        _Stamp(color: colors.accent, still: duration == Duration.zero),
      ]),
    );
  }
}

class _SentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SentChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: kRibbonInk.withValues(alpha: 0.16))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: kRibbonInk.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(label, style: ribbonText(kRibbonInk.withValues(alpha: 0.8), size: 12.5, weight: FontWeight.w500, height: 1.2)),
        ]),
      );
}

/// "Booked", inked on: it drops in large and settles at a slight tilt.
class _Stamp extends StatelessWidget {
  final Color color;
  final bool still;
  const _Stamp({required this.color, required this.still});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: still ? 1 : 0, end: 1),
        // lands once the booked details have faded in
        duration: still ? Duration.zero : const Duration(milliseconds: 1000),
        curve: const Interval(0.42, 1, curve: Curves.easeOutBack),
        builder: (_, t, child) => Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.rotate(angle: -0.34 + 0.18 * t, child: Transform.scale(scale: 1.8 - 0.8 * t, child: child)),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: color, width: 2)),
          child: Text('Booked', style: ribbonDisplay(color, size: 26, height: 1.0)),
        ),
      );
}

/// A ticket: rounded corners and a notch each side at the fold.
class _TicketClipper extends CustomClipper<Path> {
  final double foldY;
  const _TicketClipper(this.foldY);

  @override
  Path getClip(Size size) {
    final body = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)));
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, foldY), radius: 11))
      ..addOval(Rect.fromCircle(center: Offset(size.width, foldY), radius: 11));
    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  bool shouldReclip(_TicketClipper old) => old.foldY != foldY;
}

class _Perforation extends CustomPainter {
  final Color color;
  const _Perforation(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (double x = 20; x < size.width - 20; x += 11) {
      canvas.drawLine(Offset(x, 0.5), Offset((x + 5).clamp(0, size.width - 20), 0.5), p);
    }
  }

  @override
  bool shouldRepaint(_Perforation old) => old.color != color;
}

// ═════════════════════════════════════════════════════════════════════════════
// RibbonMoods1 — a mosaic of mood tiles, then "Gift for" links.
// ═════════════════════════════════════════════════════════════════════════════
/// Items WITH an image: mood tiles (title, sub_title count, redirect_data).
/// Items WITHOUT one: plain links (title, redirect_data). Section
/// layout_description: the label before the links ("Gift for").
class RibbonMoods1 extends StatelessWidget {
  final Content content;
  const RibbonMoods1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = ribbonItems(content, 24);
    final tiles = items.where((d) => ribbonTrim(d.image).isNotEmpty).take(9).toList();
    final links = items.where((d) => ribbonTrim(d.image).isEmpty && ribbonTrim(d.title).isNotEmpty).toList();
    if (tiles.isEmpty && links.isEmpty) return const SizedBox.shrink();
    final colors = RibbonColors.of(content);
    final label = ribbonRaw(content, 'layout_description');

    Widget tile(int i, LayoutDatum d, double aspect, {double nameSize = 26}) {
      final count = ribbonTrim(d.subTitle);
      return RibbonRise(
        delay: ribbonStagger(i),
        child: RibbonPress(
          onTap: () => ribbonOpenItem(context, d),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: aspect,
              child: Stack(fit: StackFit.expand, children: [
                RibbonSettle(delay: ribbonStagger(i), child: BasketImage(url: d.image, fit: BoxFit.cover)),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0x00000000), Color(0xB3000000)],
                      stops: [0, 0.5, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 13,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(ribbonTrim(d.title),
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: ribbonDisplay(Colors.white, size: nameSize, height: 1.0)),
                    if (count.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(count, maxLines: 1, style: ribbonText(Colors.white.withValues(alpha: 0.85), size: 13, height: 1.3)),
                    ],
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
    }

    final rest = tiles.skip(1).toList();
    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < rest.length; i++) {
      final t = tile(i + 1, rest[i], 4 / 5, nameSize: 24);
      (i.isEven ? left : right).add(Padding(padding: const EdgeInsets.only(bottom: 12), child: t));
    }

    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RibbonHeader(content: content, colors: colors),
        if (tiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              Padding(padding: const EdgeInsets.only(bottom: 12), child: tile(0, tiles.first, 16 / 10, nameSize: 34)),
              if (rest.isNotEmpty)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(children: left)),
                  const SizedBox(width: 12),
                  // the second column sits lower: a mosaic, not a table
                  Expanded(child: Padding(padding: EdgeInsets.only(top: right.isEmpty ? 0 : 40), child: Column(children: right))),
                ]),
            ]),
          ),
        if (links.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(20, tiles.isEmpty ? 0 : 16, 20, 0),
            child: Wrap(spacing: 18, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (label.isNotEmpty) Text(label, style: ribbonText(colors.soft, size: 15, height: 1.6)),
              for (final l in links)
                RibbonLink(
                    label: ribbonTrim(l.title), color: colors.ink, underline: colors.accent, onTap: () => ribbonOpenItem(context, l)),
            ]),
          ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ProductRibbonGrid1 — two columns of experience cards.
// ═════════════════════════════════════════════════════════════════════════════
class ProductRibbonGrid1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductRibbonGrid1({super.key, required this.content, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final items = ribbonItems(content, 12);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = RibbonColors.of(content);
    final more = ribbonSeeAll(context, content);
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: RibbonExperienceCard(item: items[i], colors: colors, index: 0, onCartQtyChanged: onCartQtyChanged)),
          const SizedBox(width: 12),
          Expanded(
            child: i + 1 < items.length
                ? RibbonExperienceCard(item: items[i + 1], colors: colors, index: 1, onCartQtyChanged: onCartQtyChanged)
                : const SizedBox.shrink(),
          ),
        ]),
      ));
    }
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RibbonHeader(content: content, colors: colors),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: rows)),
        if (more != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RibbonButton(label: ribbonTrim(content.layoutRedirectTitle), color: colors.ink, onTap: more),
          ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RibbonVoices1 — guests after the experience, one card at a time.
// ═════════════════════════════════════════════════════════════════════════════
/// layout_data[i]: image (optional guest photo) · sub_title (quote) · title
/// (name) · feature_text (the experience). Auto-advances every 7 s.
class RibbonVoices1 extends StatefulWidget {
  final Content content;
  const RibbonVoices1({super.key, required this.content});

  @override
  State<RibbonVoices1> createState() => _RibbonVoices1State();
}

class _RibbonVoices1State extends State<RibbonVoices1> with SingleTickerProviderStateMixin {
  final _page = PageController(viewportFraction: 0.86);
  late final AnimationController _clock;
  final Key _seen = UniqueKey();
  int _active = 0;
  bool _still = false;
  bool _visible = false;
  bool _dragging = false;

  List<LayoutDatum> get _items =>
      ribbonItems(widget.content, 8).where((d) => ribbonTrim(d.subTitle).isNotEmpty || ribbonTrim(d.featureText).isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: const Duration(seconds: 7))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = ribbonStill(context);
    _sync();
  }

  void _sync() {
    if (!_still && _visible && !_dragging && _items.length > 1) {
      if (!_clock.isAnimating) _clock.forward();
    } else {
      _clock.stop();
    }
  }

  void _next() {
    final n = _items.length;
    if (n < 2 || !_page.hasClients) return;
    _page.animateToPage((_active + 1) % n, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _clock.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = RibbonColors.of(widget.content);
    final w = MediaQuery.of(context).size.width;
    final ts = MediaQuery.textScalerOf(context);
    final photoW = (w * 0.24).clamp(80.0, 104.0);
    final height = 40 + photoW * 1.25 + 18 + ts.scale(27) * 1.08 * 5 + 6;
    final card = colors.dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF4F4F6);

    return VisibilityDetector(
      key: _seen,
      onVisibilityChanged: (info) {
        final v = info.visibleFraction > 0.4;
        if (v != _visible && mounted) {
          _visible = v;
          _sync();
        }
      },
      child: Container(
        color: colors.bg,
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RibbonHeader(content: widget.content, colors: colors),
          SizedBox(
            height: height,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollStartNotification && n.dragDetails != null) {
                  _dragging = true;
                  _sync();
                } else if (n is ScrollEndNotification && _dragging) {
                  _dragging = false;
                  _sync();
                }
                return false;
              },
              child: PageView.builder(
                controller: _page,
                physics: kRibbonPagePhysics,
                itemCount: items.length,
                onPageChanged: (i) {
                  setState(() => _active = i);
                  _clock.value = 0;
                  _sync();
                },
                itemBuilder: (_, i) {
                  final it = items[i];
                  final quote = ribbonTrim(it.subTitle).isNotEmpty ? ribbonTrim(it.subTitle) : ribbonTrim(it.featureText);
                  final name = ribbonTrim(it.title);
                  final after = ribbonTrim(it.subTitle).isNotEmpty ? ribbonTrim(it.featureText) : '';
                  final hasPhoto = ribbonTrim(it.image).isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          if (hasPhoto) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                  width: photoW,
                                  height: photoW * 1.25,
                                  child: RibbonSettle(child: BasketImage(url: it.image, fit: BoxFit.cover))),
                            ),
                            const SizedBox(width: 14),
                          ],
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                              if (name.isNotEmpty)
                                Text(name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ribbonText(colors.ink, size: 15, weight: FontWeight.w700, height: 1.35)),
                              if (after.isNotEmpty)
                                Text('After $after',
                                    maxLines: 3, overflow: TextOverflow.ellipsis, style: ribbonText(colors.soft, size: 13.5, height: 1.4)),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Text('“$quote”',
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: ribbonDisplay(colors.ink, size: 27, weight: FontWeight.w700, height: 1.08)),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),
          if (items.length > 1) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                for (var i = 0; i < items.length; i++)
                  Container(
                    width: 26,
                    height: 2.5,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(color: colors.ink.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(2)),
                    alignment: Alignment.centerLeft,
                    child: i < _active
                        ? Container(decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(2)))
                        : i == _active
                            ? AnimatedBuilder(
                                animation: _clock,
                                builder: (_, __) => FractionallySizedBox(
                                  widthFactor: _still ? 1 : _clock.value.clamp(0.0, 1.0),
                                  child: Container(decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(2))),
                                ),
                              )
                            : null,
                  ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
