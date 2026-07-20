import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

class VideoBanner1 extends StatelessWidget {
  final Content content;
  const VideoBanner1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(children: [
      const AspectRatio(aspectRatio: 16 / 9, child: ImageFallbackWidget(fit: BoxFit.cover)),
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: Colors.black.withOpacity(0.25)))),
      const Positioned.fill(child: Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 56))),
      Positioned(left: 16, right: 16, bottom: 16, child: Text(content.layoutTitle ?? 'Watch the Film',
        style: FontUtils.primaryFontStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))),
    ])),
  );
}

class TextCta1 extends StatelessWidget {
  final Content content;
  const TextCta1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    child: Column(children: [
      if ((content.layoutSubTitle ?? '').isNotEmpty)
        Text(content.layoutSubTitle!.toUpperCase(), style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textColor50)),
      const SizedBox(height: 8),
      Text(content.layoutTitle ?? 'Join thousands who shop smarter', textAlign: TextAlign.center,
        style: FontUtils.primaryFontStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textColor)),
      const SizedBox(height: 16),
      Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 28), alignment: Alignment.center,
        decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(22)),
        child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Get started',
          style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
    ]),
  );
}

class CountBadgeRail1 extends StatelessWidget {
  final Content content;
  const CountBadgeRail1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '', ctaText: content.layoutRedirectTitle ?? '')),
        const SizedBox(height: 12),
        SizedBox(height: 246, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => GroceryTile(data: items[i], width: 138))),
      ]),
    );
  }
}

class SubscribeBox1 extends StatelessWidget {
  final Content content;
  const SubscribeBox1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Container(height: 48, width: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.autorenew, color: Colors.white, size: 26)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(content.layoutTitle ?? 'Subscribe & Save 15%', style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(content.layoutSubTitle ?? 'Never run out of your essentials', maxLines: 2, style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70)),
        ])),
        const SizedBox(width: 8),
        Container(height: 34, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Start', style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kInk))),
      ]),
    ),
  );
}

class FaqCompact1 extends StatelessWidget {
  final Content content;
  const FaqCompact1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(3).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
        const SizedBox(height: 12),
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: kInk.withOpacity(0.08))),
            child: Row(children: [
              Expanded(child: Text(items[i].title ?? '', style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textColor))),
              const Icon(Icons.add, size: 18, color: AppColors.textColor),
            ])),
        ],
      ]),
    );
  }
}
