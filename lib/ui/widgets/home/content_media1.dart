import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

// Blog1 — article / journal teaser rail.
class Blog1 extends StatelessWidget {
  final Content content;
  const Blog1({super.key, required this.content});
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
        SizedBox(height: 220, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => SizedBox(width: 240, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(14),
              child: const AspectRatio(aspectRatio: 16 / 10, child: ImageFallbackWidget(fit: BoxFit.cover))),
            const SizedBox(height: 10),
            if ((items[i].salesText ?? '').isNotEmpty)
              Text(items[i].salesText!.toUpperCase(),
                style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kFresh)),
            const SizedBox(height: 4),
            Text(items[i].title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textColor)),
            if ((items[i].featureText ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(items[i].featureText!, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
            ],
          ]))),
        ),
      ]),
    );
  }
}

// Story1 — brand story: image over narrative copy.
class Story1 extends StatelessWidget {
  final Content content;
  const Story1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final hero = (content.layoutData ?? []).isNotEmpty ? content.layoutData!.first : null;
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(18),
          child: const AspectRatio(aspectRatio: 16 / 9, child: ImageFallbackWidget(fit: BoxFit.cover))),
        const SizedBox(height: 14),
        if ((content.layoutSubTitle ?? '').isNotEmpty)
          Text(content.layoutSubTitle!.toUpperCase(),
            style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textColor50)),
        const SizedBox(height: 6),
        Text(content.layoutTitle ?? 'Rooted in Craft',
          style: FontUtils.primaryFontStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textColor)),
        const SizedBox(height: 8),
        Text(hero?.featureText ?? 'Every piece is made by skilled artisans using time-honoured techniques, blending heritage with a modern sensibility.',
          style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
        const SizedBox(height: 12),
        Row(children: [
          Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Read our story',
            style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textColor)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward, size: 16, color: AppColors.textColor),
        ]),
      ]),
    );
  }
}

// HowTo1 — numbered how-it-works steps (vertical list).
class HowTo1 extends StatelessWidget {
  final Content content;
  const HowTo1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
        const SizedBox(height: 12),
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 34, width: 34, alignment: Alignment.center,
              decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(12)),
              child: Text('${i + 1}', style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(items[i].title ?? '',
                style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor)),
              if ((items[i].featureText ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(items[i].featureText!,
                  style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
              ],
            ])),
          ]),
        ],
      ]),
    );
  }
}

// Reels1 — vertical short-video reels rail with play + like count.
class Reels1 extends StatelessWidget {
  final Content content;
  const Reels1({super.key, required this.content});
  static const _likes = ['12.4k', '8.1k', '21.7k', '5.9k', '15.2k', '9.3k'];
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
        SizedBox(height: 230, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => ClipRRect(borderRadius: BorderRadius.circular(16),
            child: SizedBox(width: 130, child: Stack(children: [
              const Positioned.fill(child: ImageFallbackWidget(fit: BoxFit.cover)),
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent])))),
              const Positioned.fill(child: Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40))),
              Positioned(left: 8, bottom: 8, child: Row(children: [
                const Icon(Icons.favorite, color: Colors.white, size: 12),
                const SizedBox(width: 3),
                Text(_likes[i % _likes.length], style: FontUtils.primaryFontStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ])),
            ])),
          ),
        )),
      ]),
    );
  }
}
