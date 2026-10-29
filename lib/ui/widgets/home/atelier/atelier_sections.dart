import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

import 'atelier_shared.dart';

/// The app's native versions of the premium boutique home (web: atelier-*.tsx,
/// posterbanner1, videoshowcase1, reviewgallery1, faq2). Each reads the same
/// layout fields the web component reads, so the web home can be mirrored
/// into the app section for section.

List<LayoutDatum> _items(Content c, [int max = 99]) => (c.layoutData ?? const <LayoutDatum>[]).take(max).toList();

/// First non-empty of an item's raw fields — the web API normalises builder
/// names (mobileImage, button_text) while the app API passes them through as
/// saved (mobileMedia, btnText), so read both.
String _itemField(LayoutDatum d, List<String> keys) {
  for (final k in keys) {
    final v = d.rawString(k).trim();
    if (v.isNotEmpty && v != 'null') return v;
  }
  return '';
}

String _raw(Content c, String key) {
  final v = c.rawString(key).trim();
  return v == 'null' ? '' : v;
}

bool _rawTrue(Content c, String key) => c.raw[key] == true || _raw(c, key) == 'true';

// ═════════════════════════════════════════════════════════════════════════════
// PosterBanner1 — finished artwork slides (the art carries its own copy).
// ═════════════════════════════════════════════════════════════════════════════
class PosterBanner1 extends StatefulWidget {
  final Content content;
  const PosterBanner1({super.key, required this.content});

  @override
  State<PosterBanner1> createState() => _PosterBanner1State();
}

class _PosterBanner1State extends State<PosterBanner1> {
  final _page = PageController();
  Timer? _timer;
  int _active = 0;

  List<LayoutDatum> get _slides => _items(widget.content)
      .where((s) => _itemField(s, ['mobileImage', 'mobileMedia']).isNotEmpty || (s.image ?? '').trim().isNotEmpty)
      .toList();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      final n = _slides.length;
      if (n < 2 || !_page.hasClients) return;
      _page.animateToPage((_active + 1) % n, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    if (slides.isEmpty) return const SizedBox.shrink();
    final accent = basketParseColor(widget.content.layoutPrimaryColor) ?? AppColors.primary;
    final bg = basketParseColor(widget.content.layoutBgColor) ?? Colors.white;
    // The phone art is designed 4:5 (1080×1350); desktop-only art is shown
    // in the same frame, cover-cropped.
    return Container(
      color: bg,
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(children: [
          PageView.builder(
            controller: _page,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _active = i),
            itemBuilder: (_, i) {
              final s = slides[i];
              final mobile = _itemField(s, ['mobileImage', 'mobileMedia']);
              final art = mobile.isNotEmpty ? mobile : s.image;
              return GestureDetector(
                onTap: () => RedirectUtils.handleContentRedirect(
                    context: context, layoutOption: widget.content.layoutOption ?? 'Custom', layoutData: s),
                child: BasketImage(url: art, fit: BoxFit.cover),
              );
            },
          ),
          if (slides.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                      color: i == _active ? accent : const Color(0x471C4321),
                      borderRadius: BorderRadius.circular(2),
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
// AtelierCategoryArches1 — shop by weave: numbered arches with the name at the foot.
// ═════════════════════════════════════════════════════════════════════════════
class AtelierCategoryArches1 extends StatelessWidget {
  final Content content;
  const AtelierCategoryArches1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 8);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = AtelierColors.of(content);
    final n = items.length;
    // three across when the count fills rows of three (3, 6), else two
    final cols = n % 3 == 0 && n % 4 != 0 ? 3 : 2;
    final option = content.layoutOption ?? 'Category';

    Widget arch(int i) {
      final it = items[i];
      final small = cols == 3;
      return GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(context: context, layoutOption: option, layoutData: it),
        child: AtelierArch(
          image: it.image,
          background: colors.deep.withValues(alpha: 0.08),
          keyline: colors.accent.withValues(alpha: 0.8),
          overlays: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [colors.deep.withValues(alpha: 0.86), colors.deep.withValues(alpha: 0.35), colors.deep.withValues(alpha: 0)],
                  stops: const [0, 0.26, 0.48],
                ),
              ),
            ),
            Positioned(
              left: 6,
              right: 6,
              bottom: small ? 14 : 20,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(i < kAtelierNumerals.length ? kAtelierNumerals[i] : '${i + 1}',
                    style: atelierKickerStyle(colors.accent, size: 10.5).copyWith(letterSpacing: 3)),
                const SizedBox(height: 4),
                Text(it.title ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: atelierDisplayStyle(kAtelierIvory, size: small ? 15 : 19)),
                const SizedBox(height: 5),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('EXPLORE', style: atelierKickerStyle(colors.accent, size: small ? 8.5 : 9.5).copyWith(letterSpacing: 2.2)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: small ? 10 : 12, color: colors.accent),
                ]),
              ]),
            ),
          ],
        ),
      );
    }

    final rows = <Widget>[];
    for (var r = 0; r < n; r += cols) {
      rows.add(Padding(
        padding: EdgeInsets.only(top: r == 0 ? 0 : 24),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var c = 0; c < cols; c++) ...[
            if (c > 0) const SizedBox(width: 12),
            Expanded(child: r + c < n ? arch(r + c) : const SizedBox.shrink()),
          ],
        ]),
      ));
    }

    return AtelierSection(
      bg: colors.bg,
      child: Column(children: [
        AtelierHeading.of(content, colors),
        const SizedBox(height: 32),
        ...rows,
        const SizedBox(height: 24),
        AtelierTextLink(label: content.layoutRedirectTitle ?? '', color: colors.deep, onTap: atelierSectionLink(context, content)),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ProductAtelierGrid1 — the arch product grid, two across.
// ═════════════════════════════════════════════════════════════════════════════
class ProductAtelierGrid1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductAtelierGrid1({super.key, required this.content, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 12);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = AtelierColors.of(content);
    final label = atelierVariantLabel(content);

    final rows = <Widget>[];
    for (var r = 0; r < items.length; r += 2) {
      rows.add(Padding(
        padding: EdgeInsets.only(top: r == 0 ? 0 : 32),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var c = 0; c < 2; c++) ...[
            if (c > 0) const SizedBox(width: 12),
            Expanded(
              child: r + c < items.length
                  ? AtelierProductCard(
                      item: items[r + c], colors: colors, variantLabel: label, onCartQtyChanged: onCartQtyChanged)
                  : const SizedBox.shrink(),
            ),
          ],
        ]),
      ));
    }

    return AtelierSection(
      bg: colors.bg,
      child: Column(children: [
        AtelierHeading.of(content, colors),
        const SizedBox(height: 32),
        ...rows,
        const SizedBox(height: 28),
        AtelierTextLink(label: content.layoutRedirectTitle ?? '', color: colors.deep, onTap: atelierSectionLink(context, content)),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// AtelierDrapeStory1 — portrait arch, two close-ups, the story and its notes.
// ═════════════════════════════════════════════════════════════════════════════
class AtelierDrapeStory1 extends StatelessWidget {
  final Content content;
  const AtelierDrapeStory1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = AtelierColors.of(content);
    final deep = colors.deep;
    final portrait = items.first;
    final details = items.skip(1).take(2).where((d) => (d.image ?? '').trim().isNotEmpty).toList();
    final notes = items.skip(3).take(4).where((d) => (d.title ?? '').isNotEmpty || (d.featureText ?? '').isNotEmpty).toList();
    final btn = _itemField(portrait, ['button_text', 'btnText']);
    final hasBtn = btn.isNotEmpty;
    final cta = hasBtn ? btn : (content.layoutRedirectTitle ?? '');
    final VoidCallback? ctaTap = hasBtn
        ? () => RedirectUtils.handleContentRedirect(context: context, layoutOption: content.layoutOption ?? 'Custom', layoutData: portrait)
        : atelierSectionLink(context, content);
    final description = _raw(content, 'layout_description');

    return AtelierSection(
      bg: colors.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.86,
            child: AtelierArch(
              image: portrait.image,
              background: deep.withValues(alpha: 0.08),
              keyline: colors.accent.withValues(alpha: 0.8),
            ),
          ),
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 28),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = 0; i < 2; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: i < details.length
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        AtelierFrame(
                          image: details[i].image,
                          background: deep.withValues(alpha: 0.08),
                          keyline: colors.accent.withValues(alpha: 0.7),
                        ),
                        if ((details[i].title ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(details[i].title!.toUpperCase(),
                              style: atelierKickerStyle(deep.withValues(alpha: 0.6), size: 10).copyWith(letterSpacing: 2.4)),
                        ],
                      ])
                    : const SizedBox.shrink(),
              ),
            ],
          ]),
        ],
        const SizedBox(height: 28),
        AtelierKicker(content.layoutSubTitle ?? '', color: colors.accent, align: TextAlign.start),
        if ((content.layoutTitle ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(content.layoutTitle!, style: atelierDisplayStyle(deep, size: 29)),
        ],
        const SizedBox(height: 12),
        AtelierRoseRule(color: colors.accent),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(description, style: atelierBodyStyle(deep.withValues(alpha: 0.74))),
        ],
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          for (final note in notes)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: deep.withValues(alpha: 0.14)))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(note.title ?? '', style: FontUtils.primaryFontStyle(fontSize: 16.5, color: deep)),
                if ((note.featureText ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(note.featureText!, style: atelierBodyStyle(deep.withValues(alpha: 0.68), size: 13.5)),
                ],
              ]),
            ),
        ],
        if (cta.isNotEmpty) ...[
          const SizedBox(height: 12),
          AtelierTextLink(label: cta, color: deep, onTap: ctaTap),
        ],
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// AtelierLookRail1 — a swipeable rail of looks on the deep band.
// ═════════════════════════════════════════════════════════════════════════════
class AtelierLookRail1 extends StatelessWidget {
  final Content content;
  const AtelierLookRail1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 16);
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = AtelierColors.of(content);
    final label = atelierVariantLabel(content);
    final width = MediaQuery.of(context).size.width * 0.68;
    // arch (2:3) + chip + two-line name + price + action label
    final height = width * 1.5 + 128;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44),
      decoration: BoxDecoration(
        color: colors.deep,
        gradient: RadialGradient(
          center: const Alignment(-0.8, -1),
          radius: 1.1,
          colors: [Color.alphaBlend(Colors.white.withValues(alpha: 0.06), colors.deep), colors.deep],
          stops: const [0, 0.6],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AtelierHeading.of(content, colors, inverted: true, center: false),
            const SizedBox(height: 8),
            AtelierTextLink(label: content.layoutRedirectTitle ?? '', color: colors.accent, onTap: atelierSectionLink(context, content)),
          ]),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 18),
            itemBuilder: (_, i) {
              final it = items[i];
              final off = basketOff(it);
              final selling = basketAmount(it.prices?.sellingPrice ?? it.subTitle);
              final mrp = basketAmount(it.prices?.originalPrice);
              final chip = atelierChip(it);
              final choose = atelierVariantCount(it) > 1;
              return GestureDetector(
                onTap: () {
                  final id = it.id ?? '';
                  if (id.isNotEmpty) PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: id));
                },
                child: SizedBox(
                  width: width,
                  child: Column(children: [
                    AtelierArch(
                      image: it.image,
                      background: Colors.black.withValues(alpha: 0.18),
                      keyline: colors.accent.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 14),
                    if (chip.isNotEmpty)
                      Text(chip.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: atelierKickerStyle(colors.accent.withValues(alpha: 0.9), size: 10).copyWith(letterSpacing: 2.4)),
                    Text(it.title ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(fontSize: 16, color: kAtelierIvory).copyWith(height: 1.3)),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      if (selling.isNotEmpty)
                        Text(selling, style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.accent)),
                      if (off > 0 && mrp.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(mrp,
                            style: FontUtils.secondaryFontStyle(
                                fontSize: 12, color: kAtelierIvory.withValues(alpha: 0.5), decoration: TextDecoration.lineThrough)),
                      ],
                    ]),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.accent.withValues(alpha: 0.8)))),
                      child: Text((choose ? 'Choose $label' : 'Shop the look').toUpperCase(),
                          style: atelierKickerStyle(kAtelierIvory, size: 10).copyWith(letterSpacing: 2.4)),
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
// AtelierPromiseBand1 — the promises in gold on the deep ground.
// ═════════════════════════════════════════════════════════════════════════════
class AtelierPromiseBand1 extends StatelessWidget {
  final Content content;
  const AtelierPromiseBand1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 4);
    if (items.isEmpty && (content.layoutTitle ?? '').isEmpty) return const SizedBox.shrink();
    final colors = AtelierColors.of(content);

    Widget promise(LayoutDatum it) => Column(children: [
          if ((it.salesText ?? '').isNotEmpty)
            Text(it.salesText!, textAlign: TextAlign.center, style: atelierDisplayStyle(colors.accent, size: 27).copyWith(height: 1.05)),
          if ((it.title ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(it.title!.toUpperCase(),
                textAlign: TextAlign.center, style: atelierKickerStyle(kAtelierIvory, size: 10.5).copyWith(letterSpacing: 2.6)),
          ],
          if ((it.featureText ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(it.featureText!,
                textAlign: TextAlign.center, style: atelierBodyStyle(kAtelierIvory.withValues(alpha: 0.68), size: 13)),
          ],
        ]);

    final rows = <Widget>[];
    for (var r = 0; r < items.length; r += 2) {
      rows.add(Padding(
        padding: EdgeInsets.only(top: r == 0 ? 0 : 30),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: promise(items[r])),
          const SizedBox(width: 16),
          Expanded(child: r + 1 < items.length ? promise(items[r + 1]) : const SizedBox.shrink()),
        ]),
      ));
    }

    return Container(
      width: double.infinity,
      color: colors.deep,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 52),
      child: Column(children: [
        AtelierKicker(content.layoutSubTitle ?? '', color: colors.accent),
        if ((content.layoutTitle ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(content.layoutTitle!, textAlign: TextAlign.center, style: atelierDisplayStyle(kAtelierIvory, size: 29)),
        ],
        const SizedBox(height: 12),
        AtelierRoseRule(color: colors.accent),
        if (rows.isNotEmpty) const SizedBox(height: 36),
        ...rows,
      ]),
    );
  }
}

// ── Shared header for the general sections (video, reviews, FAQ) ───────────
/// The web's SectionHeader: the subtitle as an outlined small-caps chip, the
/// title large under it.
class _ChipHeader extends StatelessWidget {
  final Content content;
  final Color ink;
  const _ChipHeader({required this.content, required this.ink});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle ?? '';
    final sub = content.layoutSubTitle ?? '';
    if (title.isEmpty && sub.isEmpty) return const SizedBox.shrink();
    return Column(children: [
      if (sub.isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ink.withValues(alpha: 0.12)),
            color: Colors.white.withValues(alpha: 0.6),
          ),
          child: Text(sub.toUpperCase(), style: atelierKickerStyle(ink.withValues(alpha: 0.7), size: 10).copyWith(letterSpacing: 1.8)),
        ),
      if (title.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: atelierDisplayStyle(ink, size: 27)),
      ],
      const SizedBox(height: 24),
    ]);
  }
}

const Color _kInk = Color(0xFF2A1F22);

// ═════════════════════════════════════════════════════════════════════════════
// VideoShowcase1 — four portrait films, two across, playing muted in view.
// ═════════════════════════════════════════════════════════════════════════════
class VideoShowcase1 extends StatelessWidget {
  final Content content;
  const VideoShowcase1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 4);
    if (items.isEmpty) return const SizedBox.shrink();
    final bg = basketParseColor(content.layoutBgColor) ?? Colors.white;
    final ink = basketOn(bg) == Colors.white ? Colors.white : _kInk;
    final autoplay = _rawTrue(content, 'layout_auto_slide') || _rawTrue(content, 'layout_marque');

    final rows = <Widget>[];
    for (var r = 0; r < items.length; r += 2) {
      rows.add(Padding(
        padding: EdgeInsets.only(top: r == 0 ? 0 : 12),
        child: Row(children: [
          Expanded(child: AtelierVideoTile(item: items[r], content: content, autoplay: autoplay)),
          const SizedBox(width: 12),
          Expanded(child: r + 1 < items.length ? AtelierVideoTile(item: items[r + 1], content: content, autoplay: autoplay) : const SizedBox.shrink()),
        ]),
      ));
    }

    return AtelierSection(bg: bg, child: Column(children: [_ChipHeader(content: content, ink: ink), ...rows]));
  }
}

/// One 9:16 film. Loads when it first scrolls into view; with autoplay it
/// plays muted on loop while at least a third of it is visible and pauses
/// off-screen. A tap follows the item's link.
class AtelierVideoTile extends StatefulWidget {
  final LayoutDatum item;
  final Content content;
  final bool autoplay;
  const AtelierVideoTile({super.key, required this.item, required this.content, required this.autoplay});

  @override
  State<AtelierVideoTile> createState() => _AtelierVideoTileState();
}

class _AtelierVideoTileState extends State<AtelierVideoTile> {
  VideoPlayerController? _controller;
  bool _visible = false;

  String get _url => (widget.item.video ?? '').trim();

  void _ensure() {
    if (_controller != null || _url.isEmpty) return;
    final c = VideoPlayerController.networkUrl(Uri.parse(_url.replaceAll(' ', '%20')));
    _controller = c;
    c.setLooping(true);
    c.setVolume(0);
    c.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _sync();
    }).catchError((_) {});
  }

  void _sync() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (widget.autoplay && _visible) {
      c.play();
    } else {
      c.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;
    return VisibilityDetector(
      key: ValueKey('atelier-video-${widget.item.id}-${_url.hashCode}'),
      onVisibilityChanged: (info) {
        _visible = info.visibleFraction >= 0.35;
        if (_visible) _ensure();
        _sync();
      },
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
            context: context, layoutOption: widget.content.layoutOption ?? 'Custom', layoutData: widget.item),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Stack(fit: StackFit.expand, children: [
              const ColoredBox(color: Color(0xFFEDE6DC)),
              if ((widget.item.image ?? '').trim().isNotEmpty) BasketImage(url: widget.item.image, fit: BoxFit.cover),
              if (ready)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c)),
                ),
              const ColoredBox(color: Color(0x33000000)),
              if (!widget.autoplay)
                Center(
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(color: Color(0xE6FFFFFF), shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF0B0B0B), size: 26),
                  ),
                ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Text(widget.item.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ReviewGallery1 — customer photos with stars, a quote and a name.
// ═════════════════════════════════════════════════════════════════════════════
class ReviewGallery1 extends StatelessWidget {
  final Content content;
  const ReviewGallery1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 4);
    if (items.isEmpty) return const SizedBox.shrink();
    final bg = basketParseColor(content.layoutBgColor) ?? Colors.white;
    final ink = basketOn(bg) == Colors.white ? Colors.white : _kInk;

    Widget card(LayoutDatum it) {
      final rating = ((it.rating ?? 5).round()).clamp(0, 5);
      final quote = (it.featureText ?? '').isNotEmpty ? it.featureText! : (it.subTitle ?? '');
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kInk.withValues(alpha: 0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(fit: StackFit.expand, children: [
              const ColoredBox(color: Color(0xFFF1ECE4)),
              BasketImage(url: it.image, fit: BoxFit.cover),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                for (var s = 0; s < 5; s++)
                  Icon(s < rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 15, color: _kInk),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: Text(quote,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: atelierBodyStyle(_kInk.withValues(alpha: 0.7), size: 12).copyWith(height: 1.5)),
              ),
              const SizedBox(height: 8),
              Text(it.title ?? 'Verified buyer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kInk)),
            ]),
          ),
        ]),
      );
    }

    final rows = <Widget>[];
    for (var r = 0; r < items.length; r += 2) {
      rows.add(Padding(
        padding: EdgeInsets.only(top: r == 0 ? 0 : 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: card(items[r])),
          const SizedBox(width: 14),
          Expanded(child: r + 1 < items.length ? card(items[r + 1]) : const SizedBox.shrink()),
        ]),
      ));
    }
    return AtelierSection(bg: bg, child: Column(children: [_ChipHeader(content: content, ink: ink), ...rows]));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Faq2 — questions and answers, open, in a single column on a phone.
// ═════════════════════════════════════════════════════════════════════════════
class Faq2 extends StatelessWidget {
  final Content content;
  const Faq2({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = _items(content, 4);
    if (items.isEmpty) return const SizedBox.shrink();
    final bg = basketParseColor(content.layoutBgColor) ?? Colors.white;
    final ink = basketOn(bg) == Colors.white ? Colors.white : _kInk;
    return AtelierSection(
      bg: bg,
      child: Column(children: [
        _ChipHeader(content: content, ink: ink),
        for (final it in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(it.title ?? '', style: FontUtils.primaryFontStyle(fontSize: 17, fontWeight: FontWeight.w600, color: ink)),
              const SizedBox(height: 8),
              Text(it.featureText ?? '', style: atelierBodyStyle(ink.withValues(alpha: 0.7), size: 13.5)),
            ]),
          ),
      ]),
    );
  }
}
