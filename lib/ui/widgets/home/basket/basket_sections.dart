import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

import 'basket_shared.dart';

typedef BasketCartChange = void Function(int delta, String variantId);

// ── BasketOfferCarousel1 ────────────────────────────────────────────────────
/// The front window: a row of offer cards, one and a peek visible. A grocery
/// catalogue has no campaign photography, so each card is COMPOSED — a
/// coloured card with the offer in type and up to three packshots on white
/// plates (a bare white carton on colour reads as a mistake; on a plate it
/// reads as a design).
///
/// Custom items: background_color = card · feature_text = kicker · title ·
/// sub_title · button_text = CTA · media = main packshot · primary_image /
/// secondary_media = two supporting packshots · redirect_data.
/// Steps every 4.8s; any swipe stops it for good.
class BasketOfferCarousel1 extends StatefulWidget {
  final Content content;
  const BasketOfferCarousel1({super.key, required this.content});

  @override
  State<BasketOfferCarousel1> createState() => _BasketOfferCarousel1State();
}

class _BasketOfferCarousel1State extends State<BasketOfferCarousel1> {
  final _page = PageController(viewportFraction: 0.88);
  Timer? _timer;
  bool _stopped = false;
  int _index = 0;

  List<LayoutDatum> get _items => (widget.content.layoutData ?? []).toList();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 4800), (_) {
      if (_stopped || !_page.hasClients || _items.length < 2) return;
      final next = (_index + 1) % _items.length;
      _page.animateToPage(next, duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
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
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = BasketColors.of(widget.content, ground: Colors.white);
    return BasketSection(
      bg: colors.bg,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        SizedBox(
          height: 176,
          child: NotificationListener<ScrollStartNotification>(
            onNotification: (n) {
              if (n.dragDetails != null) _stopped = true;
              return false;
            },
            child: PageView.builder(
              controller: _page,
              padEnds: false,
              itemCount: items.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.only(left: i == 0 ? 16 : 6, right: 6),
                child: _OfferCard(content: widget.content, item: items[i], index: i),
              ),
            ),
          ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: i == _index ? 18 : 6,
                decoration: BoxDecoration(
                  color: i == _index ? colors.accent : colors.text.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ]),
        ],
      ]),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Content content;
  final LayoutDatum item;
  final int index;
  const _OfferCard({required this.content, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final card = basketParseColor(item.rawString('background_color')) ?? kBasketTints[index % kBasketTints.length];
    final ink = basketOn(card);
    final kicker = item.featureText ?? '';
    final cta = basketField(item, ['button_text', 'btnText']);
    final main = (item.image ?? '').isNotEmpty ? item.image : basketField(item, ['mobileImage', 'mobileMedia']);
    final extras = [
      basketField(item, ['primary_image', 'primaryMedia']),
      basketField(item, ['secondary_image', 'secondary_media', 'secondaryMedia']),
    ].where((s) => s.isNotEmpty).toList();

    Widget plate(String? url, double size, double radius, double pad) => Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.13), blurRadius: 22, offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(radius - 4), child: BasketImage(url: url)),
        );

    return GestureDetector(
      onTap: () => basketOpen(context, content, item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: card,
          child: LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            final art = w * 0.5;
            final mainSize = (art * 0.64).clamp(0.0, h - 28);
            return Stack(children: [
              // Packshots on white plates, overlapping so they read as one
              // group: the main plate anchored right, the supporting two tucked
              // in front of its lower-left corner.
              Positioned(
                right: 14,
                top: (h - mainSize) / 2,
                child: plate(main, mainSize, 16, 8),
              ),
              if (extras.isNotEmpty)
                Positioned(right: 14 + mainSize * 0.62, bottom: h * 0.1, child: plate(extras[0], art * 0.34, 12, 5)),
              if (extras.length > 1)
                Positioned(right: 14 + mainSize * 0.38, top: h * 0.08, child: plate(extras[1], art * 0.3, 12, 5)),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: w * 0.55,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (kicker.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(kicker.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                  fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: ink)),
                        ),
                      Text(item.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                                  fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: ink)
                              .copyWith(height: 1.1)),
                      if ((item.subTitle ?? '').isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(item.subTitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.secondaryFontStyle(fontSize: 11.5, color: ink.withValues(alpha: 0.75))
                                .copyWith(height: 1.3)),
                      ],
                      if (cta.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                          decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(20)),
                          child: Text(cta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: card)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ]);
          }),
        ),
      ),
    );
  }
}

// ── BasketCategoryGrid1 ─────────────────────────────────────────────────────
/// Shop by department: a 4-up grid of tinted squares, each framing a white
/// tile with the department's packshot shown whole, name underneath.
class BasketCategoryGrid1 extends StatelessWidget {
  final Content content;
  const BasketCategoryGrid1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(30).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = BasketColors.of(content);
    return BasketSection(
      bg: colors.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BasketSectionHead(content: content, colors: colors),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(builder: (context, box) {
            const cols = 4;
            const gap = 10.0;
            final w = (box.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(spacing: gap, runSpacing: 14, children: [
              for (var i = 0; i < items.length; i++)
                SizedBox(
                  width: w,
                  child: GestureDetector(
                    onTap: () => basketOpen(context, content, items[i]),
                    child: Column(children: [
                      Container(
                        width: w,
                        height: w,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: basketParseColor(items[i].rawString('background_color')) ??
                              kBasketTints[i % kBasketTints.length],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ColoredBox(
                            color: Colors.white,
                            child: Padding(padding: const EdgeInsets.all(5), child: BasketImage(url: items[i].image)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(items[i].title ?? '',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                                  fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.text.withValues(alpha: 0.9))
                              .copyWith(height: 1.2)),
                    ]),
                  ),
                ),
            ]);
          }),
        ),
      ]),
    );
  }
}

// ── ProductBasketRail1 ──────────────────────────────────────────────────────
/// A shelf of products, bought straight from the rail.
class ProductBasketRail1 extends StatelessWidget {
  final Content content;
  final BasketCartChange? onCartQtyChanged;
  const ProductBasketRail1({super.key, required this.content, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(24).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = BasketColors.of(content);
    return BasketSection(
      bg: colors.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BasketSectionHead(content: content, colors: colors, onSeeAll: basketSeeAll(context, content)),
        BasketTileRail(items: items, colors: colors, onCartQtyChanged: onCartQtyChanged),
      ]),
    );
  }
}

// ── ProductBasketGrid1 ──────────────────────────────────────────────────────
/// The same tiles in a grid — two up on a phone, three on a wide one.
class ProductBasketGrid1 extends StatelessWidget {
  final Content content;
  final BasketCartChange? onCartQtyChanged;
  const ProductBasketGrid1({super.key, required this.content, this.onCartQtyChanged});

  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(24).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = BasketColors.of(content);
    return BasketSection(
      bg: colors.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BasketSectionHead(content: content, colors: colors, onSeeAll: basketSeeAll(context, content)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(builder: (context, box) {
            final cols = box.maxWidth >= 560 ? 4 : box.maxWidth >= 400 ? 3 : 2;
            const gap = 10.0;
            final w = (box.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(spacing: gap, runSpacing: gap, children: [
              for (final item in items)
                SizedBox(
                  width: w,
                  height: BasketTile.heightFor(w, pack: BasketTile.anyPack(items)),
                  child: BasketTile(item: item, colors: colors, onCartQtyChanged: onCartQtyChanged),
                ),
            ]);
          }),
        ),
      ]),
    );
  }
}

// ── BasketAisleTabs1 ────────────────────────────────────────────────────────
/// Shop by need: pill tabs over one shelf. Each custom item is a tab — its
/// title is the label and its products (multiple_product_data) the shelf;
/// the item's redirect is the tab's "See all".
class BasketAisleTabs1 extends StatefulWidget {
  final Content content;
  final BasketCartChange? onCartQtyChanged;
  const BasketAisleTabs1({super.key, required this.content, this.onCartQtyChanged});

  @override
  State<BasketAisleTabs1> createState() => _BasketAisleTabs1State();
}

class _BasketAisleTabs1State extends State<BasketAisleTabs1> {
  int _active = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = (widget.content.layoutData ?? [])
        .where((t) => (t.title ?? '').isNotEmpty && basketMultiProducts(t).isNotEmpty)
        .toList();
    if (tabs.isEmpty) return const SizedBox.shrink();
    final colors = BasketColors.of(widget.content);
    final current = tabs[_active.clamp(0, tabs.length - 1)];
    final products = basketMultiProducts(current).take(18).toList();
    final redirect = current.redirectData;
    final hasSeeAll = (redirect?.redirectType ?? '').isNotEmpty;

    return BasketSection(
      bg: colors.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BasketSectionHead(content: widget.content, colors: colors),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final on = i == _active;
              return GestureDetector(
                onTap: () => setState(() => _active = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? colors.accent : colors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: on ? colors.accent : kBasketLine),
                  ),
                  child: Text(tabs[i].title!,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: on ? colors.onAccent : colors.cardText.withValues(alpha: 0.8))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        BasketTileRail(
          key: ValueKey(_active),
          items: products,
          colors: colors,
          onCartQtyChanged: widget.onCartQtyChanged,
        ),
        if (hasSeeAll)
          Center(
            child: GestureDetector(
              onTap: () => RedirectUtils.handleContentRedirectViewAll(context: context, redirectData: redirect!),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('See all ${current.title} ›',
                    style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.accent)),
              ),
            ),
          ),
      ]),
    );
  }
}

// ── BasketBrandRail1 ────────────────────────────────────────────────────────
/// Top brands: round white logo plates in a rail, name and a line (e.g. the
/// product count) under each.
class BasketBrandRail1 extends StatelessWidget {
  final Content content;
  const BasketBrandRail1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(20).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = BasketColors.of(content);
    return BasketSection(
      bg: colors.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BasketSectionHead(content: content, colors: colors),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => basketOpen(context, content, items[i]),
              child: SizedBox(
                width: 84,
                child: Column(children: [
                  Container(
                    width: 84,
                    height: 84,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBasketLine),
                    ),
                    child: ClipOval(child: BasketImage(url: items[i].image)),
                  ),
                  const SizedBox(height: 6),
                  Text(items[i].title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colors.text)),
                  if ((items[i].subTitle ?? '').isNotEmpty)
                    Text(items[i].subTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.accent)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── BasketPromiseStrip1 ─────────────────────────────────────────────────────
/// The store's promises (since 2010, genuine brands, delivery…) as a 2-up grid
/// of quiet cards, each with an icon in a soft accent circle. An item image,
/// when set, replaces the icon.
class BasketPromiseStrip1 extends StatelessWidget {
  final Content content;
  const BasketPromiseStrip1({super.key, required this.content});

  static const _fallback = [
    Icons.local_shipping_outlined,
    Icons.eco_outlined,
    Icons.percent_rounded,
    Icons.autorenew_rounded,
    Icons.verified_user_outlined,
  ];

  // The promise's words pick its icon; the web's order is the fallback.
  static IconData _iconFor(String text, int i) {
    final t = text.toLowerCase();
    if (RegExp(r'deliver|ship|dispatch').hasMatch(t)) return Icons.local_shipping_outlined;
    if (RegExp(r'price|offer|save|discount|%').hasMatch(t)) return Icons.sell_outlined;
    if (RegExp(r'return|exchange|refund').hasMatch(t)) return Icons.autorenew_rounded;
    if (RegExp(r'\bhelp|\bcall\b|\bsupport\b|\bchat\b|expert').hasMatch(t)) return Icons.support_agent_outlined;
    if (RegExp(r'secure|safe|pay').hasMatch(t)) return Icons.lock_outline_rounded;
    if (RegExp(r'since|genuine|trust|original|certified|authentic').hasMatch(t)) return Icons.verified_outlined;
    // a count claim ("202 supports", "10 departments") is about the range
    if (RegExp(r'^\d|department|categor|range|product|essential').hasMatch(t)) return Icons.grid_view_rounded;
    return _fallback[i % _fallback.length];
  }

  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(5).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = BasketColors.of(content);

    Widget card(int i) {
      final d = items[i];
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBasketLine),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: colors.accent.withValues(alpha: 0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: (d.image ?? '').isNotEmpty
                ? SizedBox(width: 22, height: 22, child: BasketImage(url: d.image))
                : Icon(_iconFor('${d.title} ${d.subTitle}', i), size: 19, color: colors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colors.cardText)
                      .copyWith(height: 1.2)),
              if ((d.subTitle ?? '').isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(d.subTitle!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.secondaryFontStyle(fontSize: 11.5, color: colors.cardText.withValues(alpha: 0.6))
                        .copyWith(height: 1.3)),
              ],
            ]),
          ),
        ]),
      );
    }

    // Pairs share a height; an odd last card spans the row instead of
    // standing alone.
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 10));
      rows.add(i + 1 < items.length
          ? IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: card(i)),
                const SizedBox(width: 10),
                Expanded(child: card(i + 1)),
              ]),
            )
          : card(i));
    }

    return BasketSection(
      bg: colors.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BasketSectionHead(content: content, colors: colors),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: rows)),
      ]),
    );
  }
}
