import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';
import 'premium_kit.dart';

/// PremiumBundle1 — "Build your stack": a curated multi-item bundle with a
/// running total and one add-all action. Replaces the boxy checklist look.
class PremiumBundle1 extends StatelessWidget {
  final Content content;
  const PremiumBundle1({super.key, required this.content});

  int _num(String? v) => int.tryParse((v ?? '').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final total = items.fold<int>(0, (s, it) => s + _num(it.prices?.sellingPrice));
    final fg = PColor.onAccent(PColor.accent);
    return Padding(
      padding: const EdgeInsets.fromLTRB(PGap.lg, PGap.xl, PGap.lg, PGap.xs),
      child: PCard(
        padding: const EdgeInsets.all(PGap.lg),
        radius: PRadius.sheet,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(content.layoutTitle ?? '', style: PType.section()),
          if ((content.layoutSubTitle ?? '').isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(content.layoutSubTitle!, style: PType.sub()),
          ],
          const SizedBox(height: PGap.lg),
          ...items.asMap().entries.map((e) {
            final it = e.value;
            final last = e.key == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : PGap.md),
              child: Row(children: [
                Icon(Icons.check_circle_rounded, size: 20, color: PColor.accent),
                const SizedBox(width: PGap.md),
                SizedBox(width: 44, height: 44, child: PImage(url: it.image, radius: 10)),
                const SizedBox(width: PGap.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(it.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: PType.cardTitle()),
                    const SizedBox(height: 2),
                    PPrice(selling: it.prices?.sellingPrice, original: it.prices?.originalPrice, size: 13),
                  ]),
                ),
              ]),
            );
          }),
          const SizedBox(height: PGap.lg),
          Container(height: 1, color: PColor.line),
          const SizedBox(height: PGap.md),
          Row(children: [
            Text('Total', style: PType.label(size: 13.5)),
            const Spacer(),
            Text(CurrencyUtil.appendCurrency(total.toString()), style: PType.price(size: 17)),
          ]),
          const SizedBox(height: PGap.md),
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: PColor.accent, borderRadius: BorderRadius.circular(PRadius.pill)),
            child: Text('Add ${items.length} items to cart',
                style: PType.label(color: fg, size: 14).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.2)),
          ),
        ]),
      ),
    );
  }
}

/// PremiumReviews1 — testimonials on LIGHT cards (fixes the dark, unreadable
/// version): clear quote, gold stars, reviewer name + place.
class PremiumReviews1 extends StatelessWidget {
  final Content content;
  const PremiumReviews1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: PGap.xl),
      PSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle),
      SizedBox(
        height: 176,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: PGap.lg),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: PGap.md),
          itemBuilder: (_, i) {
            final it = items[i];
            final stars = (it.rating ?? 5).round().clamp(0, 5);
            return Container(
              width: 288,
              padding: const EdgeInsets.all(PGap.lg),
              decoration: BoxDecoration(
                color: PColor.surface,
                borderRadius: BorderRadius.circular(PRadius.card),
                border: Border.all(color: PColor.line),
                boxShadow: PShadow.hair,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: List.generate(5, (s) => Icon(
                    s < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16, color: s < stars ? const Color(0xFFF5A623) : PColor.ink45))),
                const SizedBox(height: PGap.sm),
                Expanded(
                  child: Text('"${it.featureText ?? it.subTitle ?? ''}"',
                      maxLines: 3, overflow: TextOverflow.ellipsis,
                      style: PType.label(color: PColor.ink70, size: 13.5).copyWith(height: 1.4, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: PGap.sm),
                Text(it.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: PType.cardTitle()),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: PGap.xs),
    ]);
  }
}

/// PremiumTrust1 — trust strip: 4 evenly-spaced items, labels WRAP (no
/// "Authorised distribut…" truncation).
class PremiumTrust1 extends StatelessWidget {
  final Content content;
  const PremiumTrust1({super.key, required this.content});
  static const _icons = [Icons.verified_user_rounded, Icons.sell_rounded, Icons.workspace_premium_rounded, Icons.local_shipping_rounded];
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(4).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(PGap.lg, PGap.xl, PGap.lg, PGap.xs),
      child: PCard(
        padding: const EdgeInsets.symmetric(horizontal: PGap.md, vertical: PGap.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(items.length, (i) {
            final it = items[i];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(children: [
                  Container(
                    height: 40, width: 40,
                    decoration: BoxDecoration(color: PColor.accentWash(0.10), shape: BoxShape.circle),
                    child: Icon(_icons[i % _icons.length], size: 20, color: PColor.accent),
                  ),
                  const SizedBox(height: PGap.sm),
                  Text(it.title ?? '', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: PType.label(size: 11.5).copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(it.featureText ?? it.subTitle ?? '', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: PType.sub(color: PColor.ink45).copyWith(fontSize: 10.5, height: 1.25)),
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }
}
