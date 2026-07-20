import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

// FeatureIcons1 — "why shop with us" icon + text row.
class FeatureIcons1 extends StatelessWidget {
  final Content content;
  const FeatureIcons1({super.key, required this.content});
  static const _icons = [Icons.eco, Icons.workspace_premium, Icons.local_shipping, Icons.recycling];
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '', centered: true),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 108),
          itemBuilder: (context, i) => Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kInk.withOpacity(0.08))),
            child: Row(children: [
              Container(height: 40, width: 40,
                decoration: BoxDecoration(color: kFresh.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
                child: Icon(_icons[i % _icons.length], color: kFresh, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(items[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textColor)),
                if ((items[i].featureText ?? '').isNotEmpty)
                  Text(items[i].featureText!, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
              ])),
            ])),
        ),
      ]),
    );
  }
}

// TestimonialBig1 — single large testimonial (dark).
class TestimonialBig1 extends StatelessWidget {
  final Content content;
  const TestimonialBig1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final r = (content.layoutData ?? []).isNotEmpty ? content.layoutData!.first : null;
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Icon(Icons.format_quote, color: Colors.white24, size: 36),
          const SizedBox(height: 10),
          Text('"${r?.featureText ?? 'Hands-down the best purchase I have made all year. The craftsmanship is unreal.'}"',
            textAlign: TextAlign.center,
            style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 14),
          Text(r?.title ?? 'Ananya R.',
            style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('Verified buyer',
            style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white54)),
        ]),
      ),
    );
  }
}

// StatBand1 — brand stats band (dark).
class StatBand1 extends StatelessWidget {
  final Content content;
  const StatBand1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final stats = [['50k+', 'Happy customers'], ['200+', 'Artisan partners'], ['4.8', 'Avg. rating']];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          for (final s in stats) Column(mainAxisSize: MainAxisSize.min, children: [
            Text(s[0], style: FontUtils.primaryFontStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(s[1], style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white60)),
          ]),
        ]),
      ),
    );
  }
}

// CategoryCardRail1 — category image cards rail.
class CategoryCardRail1 extends StatelessWidget {
  final Content content;
  const CategoryCardRail1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '',
            ctaText: content.layoutRedirectTitle ?? '')),
        const SizedBox(height: 12),
        SizedBox(height: 150, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => SizedBox(width: 120, child: Column(children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(16),
              child: const SizedBox.expand(child: ImageFallbackWidget(fit: BoxFit.cover)))),
            const SizedBox(height: 8),
            Text(items[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColor)),
          ]))),
        ),
      ]),
    );
  }
}
