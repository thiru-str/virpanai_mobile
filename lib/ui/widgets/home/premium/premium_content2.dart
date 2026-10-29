import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'premium_kit.dart';

/// PremiumOfferDuo1 — two side-by-side offer cards (image + title + subtitle).
class PremiumOfferDuo1 extends StatelessWidget {
  final Content content;
  const PremiumOfferDuo1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(2).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(PGap.lg, PGap.xl, PGap.lg, PGap.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (i) {
          final it = items[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : PGap.sm, right: i == items.length - 1 ? 0 : PGap.sm),
              child: PCard(
                padding: const EdgeInsets.all(PGap.sm),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  PImage(url: it.image, aspectRatio: 4 / 3, radius: PRadius.image - 2),
                  const SizedBox(height: PGap.md),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(it.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: PType.cardTitle()),
                      const SizedBox(height: 2),
                      Text(it.featureText ?? it.subTitle ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: PType.sub()),
                    ]),
                  ),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// PremiumFaq1 — clean FAQ accordion (first row expanded in preview).
class PremiumFaq1 extends StatefulWidget {
  final Content content;
  const PremiumFaq1({super.key, required this.content});
  @override
  State<PremiumFaq1> createState() => _PremiumFaq1State();
}

class _PremiumFaq1State extends State<PremiumFaq1> {
  int open = 0;
  @override
  Widget build(BuildContext context) {
    final items = widget.content.layoutData ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: PGap.xl),
      PSectionHeader(title: widget.content.layoutTitle ?? '', subtitle: widget.content.layoutSubTitle),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: PGap.lg),
        child: Column(children: List.generate(items.length, (i) {
          final it = items[i];
          final isOpen = open == i;
          final answer = it.featureText ?? it.subTitle ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: PGap.sm),
            child: PCard(
              padding: const EdgeInsets.all(PGap.lg),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => open = isOpen ? -1 : i),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(it.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: PType.cardTitle().copyWith(fontSize: 14.5))),
                    const SizedBox(width: PGap.md),
                    Icon(isOpen ? Icons.remove_rounded : Icons.add_rounded, size: 20, color: PColor.accent),
                  ]),
                  if (isOpen && answer.isNotEmpty) ...[
                    const SizedBox(height: PGap.sm),
                    Text(answer, style: PType.sub(color: PColor.ink70).copyWith(height: 1.45)),
                  ],
                ]),
              ),
            ),
          );
        })),
      ),
      const SizedBox(height: PGap.xs),
    ]);
  }
}

/// PremiumAppDownload1 — dark premium app-install banner with store buttons.
class PremiumAppDownload1 extends StatelessWidget {
  final Content content;
  const PremiumAppDownload1({super.key, required this.content});
  Widget _store(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.18))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: PType.label(color: Colors.white, size: 12).copyWith(fontWeight: FontWeight.w700)),
        ]),
      );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(PGap.lg, PGap.xl, PGap.lg, PGap.xs),
      child: Container(
        padding: const EdgeInsets.all(PGap.xl),
        decoration: BoxDecoration(color: PColor.ink, borderRadius: BorderRadius.circular(PRadius.sheet)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(content.layoutTitle ?? 'Get the App', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: PType.section(color: Colors.white)),
              if ((content.layoutSubTitle ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(content.layoutSubTitle!, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: PType.sub(color: Colors.white.withOpacity(0.7))),
              ],
              const SizedBox(height: PGap.lg),
              Wrap(spacing: PGap.sm, runSpacing: PGap.sm, children: [
                _store(Icons.apple, 'App Store'),
                _store(Icons.play_arrow_rounded, 'Google Play'),
              ]),
            ]),
          ),
          const SizedBox(width: PGap.lg),
          SizedBox(width: 84, child: PImage(url: null, aspectRatio: 3 / 4, radius: PRadius.image)),
        ]),
      ),
    );
  }
}
