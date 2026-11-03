import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/ui/widgets/home/maison/maison_shared.dart';
import 'package:waioz/ui/widgets/home/maison/maison_viewers.dart';
import 'package:waioz/utility/redirect_utils.dart';

import 'theatre_shared.dart';

void _open(BuildContext context, Content content, LayoutDatum item) {
  final bound = theatreBound(item);
  if (bound != null) return maisonOpenProduct(context, bound);
  RedirectUtils.handleContentRedirect(context: context, layoutOption: content.layoutOption ?? 'Custom', layoutData: item);
}

// the colour sheet (several options) is MAISON's; it takes these colours
const _sheet = MaisonColors(kTheatrePaper, kTheatreAmber, kTheatreInk);

// ═════════════════════════════════════════════════════════════════════════════
// TheatreHero1 — story-style stills, then the pitch on the night ground.
// ═════════════════════════════════════════════════════════════════════════════
/// Same fields as the web: item 0 = sales_text (kicker), title, feature_text
/// (line 2, in the accent), sub_title, button_text + redirect_data, image
/// (optional first still); items 1+ = stills with a title caption + link.
/// Second button = layout_redirect_title + redirect_data; layout_description =
/// proof points split on "·".
class TheatreHero1 extends StatefulWidget {
  final Content content;
  const TheatreHero1({super.key, required this.content});

  @override
  State<TheatreHero1> createState() => _TheatreHero1State();
}

class _TheatreHero1State extends State<TheatreHero1> {
  final _page = PageController();
  Timer? _timer;
  int _i = 0;

  List<LayoutDatum> get _stills => theatreItems(widget.content, 7)
      .asMap()
      .entries
      .where((e) => (e.value.image ?? '').trim().isNotEmpty)
      .map((e) => e.value)
      .toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (_stills.length > 1 && !MediaQuery.of(context).disableAnimations) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted || !_page.hasClients) return;
        _page.animateToPage((_i + 1) % _stills.length, duration: const Duration(milliseconds: 650), curve: Curves.easeOutCubic);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = theatreItems(widget.content, 7);
    if (items.isEmpty) return const SizedBox.shrink();
    final lead = items.first;
    final colors = TheatreColors.of(widget.content);
    final stills = _stills;
    final proofs = theatreRaw(widget.content, 'layout_description').split('·').map((s) => s.trim()).where((s) => s.isNotEmpty).take(4).toList();
    final second = widget.content.layoutRedirectTitle ?? '';
    final seeAll = basketSeeAll(context, widget.content);
    final w = MediaQuery.of(context).size.width;
    return Container(
      color: colors.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (stills.isNotEmpty)
          SizedBox(
            width: w,
            height: w * 1.12,
            child: Stack(fit: StackFit.expand, children: [
              PageView.builder(
                controller: _page,
                itemCount: stills.length,
                onPageChanged: (i) => setState(() => _i = i),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: stills[i] == lead ? null : () => _open(context, widget.content, stills[i]),
                  child: BasketImage(url: stills[i].image, fit: BoxFit.cover),
                ),
              ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: const Alignment(0, 0.1), colors: [colors.bg, colors.bg.withValues(alpha: 0)]),
                  ),
                ),
              ),
              if (stills.length > 1)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 14,
                  child: Row(children: [
                    for (var k = 0; k < stills.length; k++)
                      Expanded(
                        child: Container(
                          height: 2.6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(color: k <= _i ? colors.accent : Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                  ]),
                ),
              if ((stills[_i].title ?? '').isNotEmpty && stills[_i] != lead)
                Positioned(
                  left: 20,
                  bottom: 18,
                  child: GestureDetector(
                    onTap: () => _open(context, widget.content, stills[_i]),
                    child: Row(children: [
                      Text((stills[_i].title ?? '').toUpperCase(), style: theatreWide(kTheatreScreen, size: 11)),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 15, color: colors.accent),
                    ]),
                  ),
                ),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (theatreSales(lead).isNotEmpty) ...[
              Row(children: [
                TheatreBars(color: colors.accent),
                const SizedBox(width: 10),
                Flexible(child: Text(theatreSales(lead).toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: theatreWide(colors.accent, size: 10.5))),
              ]),
              const SizedBox(height: 14),
            ],
            Text.rich(
              TextSpan(children: [
                TextSpan(text: lead.title ?? ''),
                if (theatreFeature(lead).isNotEmpty) TextSpan(text: '\n${theatreFeature(lead)}', style: TextStyle(color: colors.accent)),
              ]),
              style: theatreDisplay(colors.ink, size: 36, weight: FontWeight.w700),
            ),
            if (theatreSub(lead).isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(theatreSub(lead), style: theatreBody(colors.soft, size: 14.5)),
            ],
            const SizedBox(height: 22),
            if (theatreButton(lead).isNotEmpty) _Action(label: theatreButton(lead), fill: kTheatreRed, onTap: () => _open(context, widget.content, lead)),
            if (theatreButton(lead).isNotEmpty && second.isNotEmpty && seeAll != null) const SizedBox(height: 10),
            if (second.isNotEmpty && seeAll != null) _Action(label: second, outline: colors.ink, onTap: seeAll),
            if (proofs.isNotEmpty) ...[
              const SizedBox(height: 22),
              Container(height: 1, color: colors.line),
              const SizedBox(height: 16),
              for (final p in proofs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 7, right: 10), decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle)),
                    Expanded(child: Text(p, style: theatreBody(colors.ink.withValues(alpha: 0.86), size: 13))),
                  ]),
                ),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _Action extends StatelessWidget {
  final String label;
  final Color? fill;
  final Color? outline;
  final VoidCallback onTap;
  final double height;
  const _Action({required this.label, this.fill, this.outline, required this.onTap, this.height = 50});

  @override
  Widget build(BuildContext context) {
    final on = fill != null ? basketOn(fill!) : (outline ?? kTheatreScreen);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(5),
          border: fill == null ? Border.all(color: on.withValues(alpha: 0.35)) : null,
        ),
        child: Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: theatreWide(on, size: 10.5, weight: FontWeight.w700, tracking: 0.16)),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TheatreSpotlights1 — a rail of lit plinths: cut-out hardware in lamp light.
// ═════════════════════════════════════════════════════════════════════════════
/// Fields per item: image (a cut-out reads best), title, sub_title (count),
/// redirect_data. Section head via layout_*.
class TheatreSpotlights1 extends StatelessWidget {
  final Content content;
  const TheatreSpotlights1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = theatreItems(content, 10);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = TheatreColors.of(content, ground: kTheatreVelvet, card: kTheatreStage);
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TheatreHeader(content: content, colors: colors, onSeeAll: basketSeeAll(context, content)),
        SizedBox(
          height: 228,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final it = items[i];
              return GestureDetector(
                onTap: () => _open(context, content, it),
                child: Container(
                  width: 164,
                  decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: colors.line)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(center: const Alignment(0, -0.85), radius: 0.8, colors: [colors.accent.withValues(alpha: 0.3), colors.accent.withValues(alpha: 0)]),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      top: 18,
                      bottom: 70,
                      child: BasketImage(url: it.image, fit: BoxFit.contain),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text((it.title ?? '').toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: theatreWide(colors.ink, size: 10.5, weight: FontWeight.w700, tracking: 0.14)),
                        if (theatreSub(it).isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(theatreSub(it), maxLines: 1, overflow: TextOverflow.ellipsis, style: theatreBody(colors.soft, size: 11.5)),
                        ],
                      ]),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ProductTheatreGrid1 — two columns of hardware on pale stages.
// ═════════════════════════════════════════════════════════════════════════════
class ProductTheatreGrid1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductTheatreGrid1({super.key, required this.content, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final items = theatreItems(content, 10);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = TheatreColors.of(content, ground: kTheatrePaper, card: kTheatrePlate);
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _TheatreTile(item: items[i], colors: colors, onCartQtyChanged: onCartQtyChanged)),
            const SizedBox(width: 12),
            Expanded(child: i + 1 < items.length ? _TheatreTile(item: items[i + 1], colors: colors, onCartQtyChanged: onCartQtyChanged) : const SizedBox()),
          ]),
        ),
      ));
    }
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TheatreHeader(content: content, colors: colors, onSeeAll: basketSeeAll(context, content)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: rows)),
      ]),
    );
  }
}

class _TheatreTile extends StatelessWidget {
  final LayoutDatum item;
  final TheatreColors colors;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const _TheatreTile({required this.item, required this.colors, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final title = item.title ?? '';
    final brand = theatreBrand(title);
    final specs = theatreSpecs(title);
    final price = basketAmount(item.prices?.sellingPrice);
    final off = basketOff(item);
    final mrp = off > 0 ? basketAmount(item.prices?.originalPrice) : '';
    final ink = colors.ink;
    return GestureDetector(
      onTap: () => maisonOpenProduct(context, item),
      behavior: HitTestBehavior.opaque,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(fit: StackFit.expand, children: [
            TheatrePlate(url: item.image, plate: colors.card),
            if (off > 0)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: kTheatreRed, borderRadius: BorderRadius.circular(3)),
                  child: Text('$off% OFF', style: theatreWide(Colors.white, size: 8.5, weight: FontWeight.w700, tracking: 0.12)),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        if (brand.isNotEmpty) Text(brand.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: theatreWide(ink.withValues(alpha: 0.5), size: 9)),
        const SizedBox(height: 4),
        Text(theatreModel(title), maxLines: 2, overflow: TextOverflow.ellipsis, style: theatreBody(ink, size: 13, weight: FontWeight.w500).copyWith(height: 1.3)),
        if (specs.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(spacing: 4, runSpacing: 4, children: [
            for (final s in specs)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(border: Border.all(color: ink.withValues(alpha: 0.18)), borderRadius: BorderRadius.circular(3)),
                child: Text(s, style: theatreWide(ink.withValues(alpha: 0.75), size: 8, tracking: 0.08)),
              ),
          ]),
        ],
        const SizedBox(height: 6),
        Wrap(crossAxisAlignment: WrapCrossAlignment.end, spacing: 6, children: [
          if (price.isNotEmpty) Text(price, style: theatrePrice(ink, size: 15.5)),
          if (mrp.isNotEmpty) Text(mrp, style: theatreBody(ink.withValues(alpha: 0.45), size: 11).copyWith(decoration: TextDecoration.lineThrough)),
        ]),
        const Spacer(),
        const SizedBox(height: 10),
        _Action(
          label: basketVariantCount(item) > 1 ? 'Choose option' : 'Add to cart',
          fill: kTheatreInk,
          height: 40,
          onTap: () => maisonAdd(context, item, _sheet, onCartQtyChanged),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TheatreLayouts1 — pick a speaker layout; the room is drawn from above.
// ═════════════════════════════════════════════════════════════════════════════
class _Layout {
  final int main, subs, heights;
  const _Layout(this.main, this.subs, this.heights);
  static _Layout? parse(String name) {
    final m = RegExp(r'(\d{1,2})\.(\d)(?:\.(\d))?').firstMatch(name);
    if (m == null) return null;
    return _Layout(math.min(int.parse(m.group(1)!), 9), math.min(int.parse(m.group(2)!), 2), math.min(int.tryParse(m.group(3) ?? '0') ?? 0, 4));
  }

  String get legend {
    final p = <String>[main >= 3 ? 'front left, centre, right' : 'front left & right'];
    if (main >= 4) p.add('two surrounds');
    if (main >= 6) p.add(main >= 7 ? 'two rear surrounds' : 'one rear surround');
    if (main >= 8) p.add('front wides');
    if (subs > 0) p.add(subs > 1 ? '$subs subwoofers' : 'a subwoofer');
    if (heights > 0) p.add('$heights height (Atmos) channels');
    return p.join(' · ');
  }
}

class _ChannelMapPainter extends CustomPainter {
  final _Layout l;
  final Color accent;
  final Color ink;
  _ChannelMapPainter(this.l, this.accent, this.ink);

  static const _pos = <String, Offset>{
    'FL': Offset(82, 46), 'FR': Offset(218, 46), 'C': Offset(150, 38), 'WL': Offset(38, 100), 'WR': Offset(262, 100),
    'SL': Offset(34, 158), 'SR': Offset(266, 158), 'BL': Offset(104, 222), 'BR': Offset(196, 222),
  };
  static const _main = <int, List<String>>{
    2: ['FL', 'FR'], 3: ['FL', 'FR', 'C'], 4: ['FL', 'FR', 'SL', 'SR'], 5: ['FL', 'FR', 'C', 'SL', 'SR'],
    6: ['FL', 'FR', 'C', 'SL', 'SR', 'BL'], 7: ['FL', 'FR', 'C', 'SL', 'SR', 'BL', 'BR'],
    8: ['FL', 'FR', 'C', 'WL', 'WR', 'SL', 'SR', 'BL'], 9: ['FL', 'FR', 'C', 'WL', 'WR', 'SL', 'SR', 'BL', 'BR'],
  };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 300, size.height / 244);
    final stroke = Paint()..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromLTRBR(1, 1, 299, 243, const Radius.circular(10)), stroke..color = ink.withValues(alpha: 0.14));
    canvas.drawRRect(RRect.fromLTRBR(70, 12, 230, 17, const Radius.circular(2.5)), Paint()..color = ink.withValues(alpha: 0.9));
    canvas.drawRect(
      const Rect.fromLTRB(70, 17, 230, 43),
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ink.withValues(alpha: 0.14), ink.withValues(alpha: 0)]).createShader(const Rect.fromLTRB(70, 17, 230, 43)),
    );
    for (final r in [50.0, 80.0, 110.0]) {
      canvas.drawCircle(const Offset(150, 168), r, Paint()..style = PaintingStyle.stroke..color = accent.withValues(alpha: 0.08));
    }
    canvas.drawRRect(RRect.fromLTRBR(114, 160, 186, 182, const Radius.circular(7)), Paint()..color = ink.withValues(alpha: 0.16));
    canvas.drawRRect(RRect.fromLTRBR(120, 166, 180, 176, const Radius.circular(4)), Paint()..color = ink.withValues(alpha: 0.22));
    for (final k in _main[l.main] ?? _main[5]!) {
      final p = _pos[k]!;
      canvas.drawRRect(RRect.fromLTRBR(p.dx - 9, p.dy - 11, p.dx + 9, p.dy + 11, const Radius.circular(4)), Paint()..color = accent);
      canvas.drawCircle(p.translate(0, 2), 4.4, Paint()..color = kTheatreNight.withValues(alpha: 0.55));
    }
    const heights = [Offset(112, 92), Offset(188, 92), Offset(112, 190), Offset(188, 190)];
    for (final h in heights.take(l.heights)) {
      // a dashed ring for a ceiling (height) channel
      for (var a = 0.0; a < math.pi * 2; a += math.pi / 7) {
        canvas.drawArc(Rect.fromCircle(center: h, radius: 9), a, math.pi / 11, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.6..color = accent);
      }
      canvas.drawCircle(h, 3, Paint()..color = accent);
    }
    const subs = [Offset(40, 30), Offset(260, 30)];
    for (final s in subs.take(l.subs)) {
      canvas.drawRRect(RRect.fromLTRBR(s.dx - 11, s.dy - 11, s.dx + 11, s.dy + 11, const Radius.circular(4)), Paint()..color = kTheatreRed);
      canvas.drawCircle(s, 6, Paint()..color = kTheatreNight.withValues(alpha: 0.5));
    }
  }

  @override
  bool shouldRepaint(covariant _ChannelMapPainter old) => old.l.main != l.main || old.l.subs != l.subs || old.l.heights != l.heights || old.accent != accent;
}

/// Fields per item: title (the layout, e.g. "5.1.2"), sales_text (tab
/// label), sub_title (who it suits), feature_text (legend; written from the
/// layout when blank), multi_product_data (the packages), button_text +
/// redirect_data. Section head via layout_*.
class TheatreLayouts1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const TheatreLayouts1({super.key, required this.content, this.onCartQtyChanged});

  @override
  State<TheatreLayouts1> createState() => _TheatreLayouts1State();
}

class _TheatreLayouts1State extends State<TheatreLayouts1> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final items = theatreItems(widget.content, 5).where((d) => (d.title ?? '').isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = TheatreColors.of(widget.content, ground: kTheatreNight);
    final it = items[_tab.clamp(0, items.length - 1)];
    final layout = _Layout.parse(it.title ?? '');
    final products = basketMultiProducts(it).take(4).toList();
    final legend = theatreFeature(it).isNotEmpty ? theatreFeature(it) : (layout?.legend ?? '');
    final more = theatreButton(it);
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TheatreHeader(content: widget.content, colors: colors),
        SizedBox(
          height: 66,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final on = i == _tab;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _tab = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: on ? colors.accent.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: on ? colors.accent : colors.line),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(items[i].title ?? '', style: theatreWide(on ? colors.accent : colors.ink, size: 20, weight: FontWeight.w700, tracking: 0.02)),
                    if (theatreSales(items[i]).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(theatreSales(items[i]).toUpperCase(), style: theatreWide(colors.soft, size: 8.5)),
                    ],
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        if (layout != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: kTheatreVelvet, borderRadius: BorderRadius.circular(10)),
              child: AspectRatio(aspectRatio: 300 / 244, child: CustomPaint(painter: _ChannelMapPainter(layout, colors.accent, kTheatreScreen))),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (theatreSub(it).isNotEmpty) Text(theatreSub(it), style: theatreBody(colors.ink.withValues(alpha: 0.86), size: 14)),
            if (legend.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(legend, style: theatreBody(colors.soft, size: 12)),
            ],
            const SizedBox(height: 20),
            Text('SYSTEMS FOR ${(it.title ?? '').toUpperCase()}', style: theatreWide(colors.accent, size: 10)),
            const SizedBox(height: 4),
            for (final p in products) _PackageRow(item: p, colors: colors, onCartQtyChanged: widget.onCartQtyChanged),
            if (products.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text('Ask us for a package built to this layout.', style: theatreBody(colors.soft))),
            if (more.isNotEmpty && (it.redirectData?.redirectType ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => RedirectUtils.handleContentRedirect(context: context, layoutOption: widget.content.layoutOption ?? 'Custom', layoutData: it),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(more.toUpperCase(), style: theatreWide(colors.ink, size: 10.5)),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 15, color: colors.accent),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _PackageRow extends StatelessWidget {
  final LayoutDatum item;
  final TheatreColors colors;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const _PackageRow({required this.item, required this.colors, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final title = item.title ?? '';
    final brand = theatreBrand(title);
    final price = basketAmount(item.prices?.sellingPrice);
    return GestureDetector(
      onTap: () => maisonOpenProduct(context, item),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.line))),
        child: Row(children: [
          SizedBox(width: 84, height: 84, child: TheatrePlate(url: item.image, radius: 6, padding: const EdgeInsets.all(6))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (brand.isNotEmpty) Text(brand.toUpperCase(), style: theatreWide(colors.soft, size: 8.5)),
              const SizedBox(height: 3),
              Text(theatreModel(title), maxLines: 2, overflow: TextOverflow.ellipsis, style: theatreBody(colors.ink, size: 13, weight: FontWeight.w500).copyWith(height: 1.3)),
              const SizedBox(height: 6),
              if (price.isNotEmpty) Text(price, style: theatrePrice(colors.ink, size: 15)),
            ]),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => maisonAdd(context, item, _sheet, onCartQtyChanged),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.accent)),
              child: Icon(Icons.add_rounded, size: 20, color: colors.accent),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TheatreReels1 — the store's own videos; a tap opens them full screen.
// ═════════════════════════════════════════════════════════════════════════════
class TheatreReels1 extends StatelessWidget {
  final Content content;
  const TheatreReels1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = theatreItems(content, 10).where((d) => (d.video ?? '').trim().isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = TheatreColors.of(content, ground: kTheatreVelvet);
    final channel = basketSeeAll(context, content);
    final viewer = MaisonColors(kTheatreNight, colors.accent, kTheatreRed);
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TheatreHeader(content: content, colors: colors),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _Reel(
              item: items[i],
              accent: colors.accent,
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 260),
                pageBuilder: (_, __, ___) => MaisonReelViewer(content: content, items: items, start: i, colors: viewer, cta: 'Shop this'),
                transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
              )),
            ),
          ),
        ),
        if (channel != null && (content.layoutRedirectTitle ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _Action(label: content.layoutRedirectTitle!, fill: kTheatreRed, onTap: channel, height: 46),
          ),
      ]),
    );
  }
}

class _Reel extends StatefulWidget {
  final LayoutDatum item;
  final Color accent;
  final VoidCallback onTap;
  const _Reel({required this.item, required this.accent, required this.onTap});

  @override
  State<_Reel> createState() => _ReelState();
}

class _ReelState extends State<_Reel> with WidgetsBindingObserver {
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
      key: ValueKey('theatre-reel-${widget.item.id}-${_url.hashCode}'),
      onVisibilityChanged: (info) {
        _visible = info.visibleFraction >= 0.4;
        if (_visible) _ensure();
        _sync();
      },
      child: GestureDetector(
        onTap: () {
          c?.pause();
          widget.onTap();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 169,
            height: 300,
            child: Stack(fit: StackFit.expand, children: [
              const ColoredBox(color: kTheatreStage),
              if ((widget.item.image ?? '').trim().isNotEmpty) BasketImage(url: widget.item.image, fit: BoxFit.cover),
              if (ready) FittedBox(fit: BoxFit.cover, child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c))),
              const DecoratedBox(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Color(0xE60B0A0E), Color(0x000B0A0E)])),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.play_arrow_rounded, size: 12, color: widget.accent),
                    const SizedBox(width: 3),
                    Text('SOUND ON', style: theatreWide(Colors.white, size: 8)),
                  ]),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(widget.item.title ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: theatreBody(Colors.white, size: 13, weight: FontWeight.w500).copyWith(height: 1.3)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TheatreBudget1 — budgets as stops along a price track.
// ═════════════════════════════════════════════════════════════════════════════
class TheatreBudget1 extends StatelessWidget {
  final Content content;
  const TheatreBudget1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = theatreItems(content, 8).where((d) => (d.title ?? '').isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = TheatreColors.of(content, ground: kTheatrePaper);
    final accent = basketParseColor(content.layoutPrimaryColor) ?? kTheatreRed;
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TheatreHeader(content: content, colors: colors),
        SizedBox(
          height: 138,
          child: Stack(children: [
            Positioned(
              left: 0,
              right: 0,
              top: 11,
              child: Container(height: 2, decoration: BoxDecoration(gradient: LinearGradient(colors: [accent.withValues(alpha: 0.25), accent]))),
            ),
            ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final it = items[i];
                return GestureDetector(
                  onTap: () => _open(context, content, it),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 118,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.18)),
                        child: Container(width: 11, height: 11, decoration: BoxDecoration(shape: BoxShape.circle, color: accent)),
                      ),
                      const SizedBox(height: 12),
                      if (theatreSales(it).isNotEmpty) Text(theatreSales(it).toUpperCase(), style: theatreWide(colors.soft, size: 9)),
                      const SizedBox(height: 4),
                      Text(it.title ?? '', style: theatreWide(colors.ink, size: 24, weight: FontWeight.w700, tracking: 0.0)),
                      const SizedBox(height: 4),
                      if (theatreSub(it).isNotEmpty) Text(theatreSub(it), style: theatreBody(colors.soft, size: 12)),
                    ]),
                  ),
                );
              },
            ),
          ]),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TheatreBrandWall1 — the makers, as nameplates.
// ═════════════════════════════════════════════════════════════════════════════
class TheatreBrandWall1 extends StatelessWidget {
  final Content content;
  const TheatreBrandWall1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = theatreItems(content, 12).where((d) => (d.title ?? '').isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = TheatreColors.of(content, ground: kTheatreVelvet);
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _Plate(item: items[i], colors: colors, onTap: () => _open(context, content, items[i]))),
          Expanded(child: i + 1 < items.length ? _Plate(item: items[i + 1], colors: colors, onTap: () => _open(context, content, items[i + 1])) : const SizedBox()),
        ]),
      ));
    }
    return Container(
      color: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TheatreHeader(content: content, colors: colors),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.line), left: BorderSide(color: colors.line))),
            child: Column(children: rows),
          ),
        ),
      ]),
    );
  }
}

class _Plate extends StatelessWidget {
  final LayoutDatum item;
  final TheatreColors colors;
  final VoidCallback onTap;
  const _Plate({required this.item, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 118),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border(right: BorderSide(color: colors.line), bottom: BorderSide(color: colors.line))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((item.title ?? '').toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: theatreWide(colors.ink, size: 13.5, weight: FontWeight.w700, tracking: 0.04)),
            const Spacer(),
            const SizedBox(height: 12),
            if (theatreSub(item).isNotEmpty) Text(theatreSub(item), maxLines: 2, overflow: TextOverflow.ellipsis, style: theatreBody(colors.soft, size: 11.5).copyWith(height: 1.3)),
            if (theatreFeature(item).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(theatreFeature(item).toUpperCase(), style: theatreWide(colors.accent, size: 8.5, weight: FontWeight.w700)),
            ],
          ]),
        ),
      );
}
