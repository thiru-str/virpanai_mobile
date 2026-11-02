import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'premium_kit.dart';

/// PremiumHero1 — full-bleed hero image with an eyebrow, headline, sub and CTA
/// over a bottom scrim. The banner-image field wins; else the first item image.
class PremiumHero1 extends StatelessWidget {
  final Content content;
  const PremiumHero1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final img = (content.layoutBannerImage != null && content.layoutBannerImage!.isNotEmpty)
        ? content.layoutBannerImage
        : (content.layoutData != null && content.layoutData!.isNotEmpty ? content.layoutData!.first.image : null);
    final cta = content.layoutRedirectTitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(PGap.lg, PGap.lg, PGap.lg, PGap.xs),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PRadius.sheet),
        child: AspectRatio(
          aspectRatio: 16 / 11,
          child: Stack(fit: StackFit.expand, children: [
            PImage(url: img, radius: 0),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x00000000), Color(0xCC000000)],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(PGap.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((content.layoutSubTitle ?? '').isNotEmpty)
                    Text(content.layoutSubTitle!.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: PType.badge(color: Colors.white).copyWith(letterSpacing: 1.5)),
                  const SizedBox(height: PGap.sm),
                  Text(content.layoutTitle ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: PType.display(color: Colors.white).copyWith(fontSize: 26)),
                  if (cta != null && cta.isNotEmpty) ...[
                    const SizedBox(height: PGap.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(PRadius.pill)),
                      child: Text(cta, style: PType.label(color: PColor.ink, size: 13.5).copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// PremiumCategoryGrid1 — clean 3-up category tiles (image + label).
class PremiumCategoryGrid1 extends StatelessWidget {
  final Content content;
  const PremiumCategoryGrid1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: PGap.xl),
      PSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle, cta: content.layoutRedirectTitle),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: PGap.lg),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: PGap.md, mainAxisSpacing: PGap.md, mainAxisExtent: 132),
        itemBuilder: (_, i) => Column(children: [
          Expanded(child: PImage(url: items[i].image, radius: PRadius.image)),
          const SizedBox(height: PGap.sm),
          Text(items[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              style: PType.label(size: 12).copyWith(fontWeight: FontWeight.w600)),
        ]),
      ),
      const SizedBox(height: PGap.xs),
    ]);
  }
}

/// PremiumSpotlight1 — a single hero product: big image, eyebrow, title, price, CTA.
class PremiumSpotlight1 extends StatelessWidget {
  final Content content;
  const PremiumSpotlight1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final it = (content.layoutData != null && content.layoutData!.isNotEmpty) ? content.layoutData!.first : LayoutDatum();
    final fg = PColor.onAccent(PColor.accent);
    return Padding(
      padding: const EdgeInsets.fromLTRB(PGap.lg, PGap.xl, PGap.lg, PGap.xs),
      child: PCard(
        padding: const EdgeInsets.all(PGap.md),
        radius: PRadius.sheet,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PImage(url: it.image, aspectRatio: 16 / 10, radius: PRadius.image),
          const SizedBox(height: PGap.md),
          if ((content.layoutSubTitle ?? '').isNotEmpty)
            Text(content.layoutSubTitle!.toUpperCase(), style: PType.badge(color: PColor.accent).copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(content.layoutTitle ?? it.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: PType.section()),
          const SizedBox(height: PGap.sm),
          Row(children: [
            Expanded(child: PPrice(selling: it.prices?.sellingPrice, original: it.prices?.originalPrice, size: 16)),
            const SizedBox(width: PGap.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: PColor.accent, borderRadius: BorderRadius.circular(PRadius.pill)),
              child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Shop now',
                  style: PType.label(color: fg, size: 13).copyWith(fontWeight: FontWeight.w700)),
            ),
          ]),
        ]),
      ),
    );
  }
}
