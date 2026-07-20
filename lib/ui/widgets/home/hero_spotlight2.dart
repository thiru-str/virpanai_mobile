import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

// RankedGrid1 — top-4 ranked product grid with rank badges.
class RankedGrid1 extends StatelessWidget {
  final Content content;
  const RankedGrid1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '',
          ctaText: content.layoutRedirectTitle ?? ''),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 288),
          itemBuilder: (context, i) => Stack(children: [
            GroceryTile(data: items[i], width: 0),
            Positioned(left: 6, top: 6, child: Container(
              height: 26, width: 26, alignment: Alignment.center,
              decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(8)),
              child: Text('${i + 1}', style: FontUtils.primaryFontStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)))),
          ]),
        ),
      ]),
    );
  }
}

// CategorySpotlight1 — category label + a featured spotlight tile.
class CategorySpotlight1 extends StatelessWidget {
  final Content content;
  const CategorySpotlight1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(children: [
        const AspectRatio(aspectRatio: 16 / 9, child: ImageFallbackWidget(fit: BoxFit.cover)),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent])))),
        Positioned(left: 18, top: 0, bottom: 0, child: Center(child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            if ((content.layoutSubTitle ?? '').isNotEmpty)
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), borderRadius: BorderRadius.circular(20)),
                child: Text(content.layoutSubTitle!, style: FontUtils.primaryFontStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
            const SizedBox(height: 10),
            Text(content.layoutTitle ?? '', style: FontUtils.primaryFontStyle(
              fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 12),
            Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 18), alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Explore',
                style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kInk))),
          ]))),
      ])),
    );
  }
}

// LookbookRail1 — tall lookbook image cards rail with labels.
class LookbookRail1 extends StatelessWidget {
  final Content content;
  const LookbookRail1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '')),
        const SizedBox(height: 12),
        SizedBox(height: 240, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => ClipRRect(borderRadius: BorderRadius.circular(18),
            child: SizedBox(width: 170, child: Stack(children: [
              const Positioned.fill(child: ImageFallbackWidget(fit: BoxFit.cover)),
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent])))),
              Positioned(left: 12, right: 12, bottom: 12, child: Text(items[i].title ?? '',
                maxLines: 2, overflow: TextOverflow.ellipsis, style: FontUtils.primaryFontStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white))),
            ])))),
        ),
      ]),
    );
  }
}

// LaunchCountdown1 — product-launch countdown with image + notify CTA.
class LaunchCountdown1 extends StatelessWidget {
  final Content content;
  const LaunchCountdown1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    const parts = ['02', '11', '45'];
    const labels = ['DAYS', 'HRS', 'MIN'];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(children: [
        const AspectRatio(aspectRatio: 16 / 10, child: ImageFallbackWidget(fit: BoxFit.cover)),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.75), Colors.black.withOpacity(0.15)])))),
        Positioned(left: 18, right: 18, bottom: 18, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            if ((content.layoutSubTitle ?? '').isNotEmpty)
              Text(content.layoutSubTitle!.toUpperCase(), style: FontUtils.primaryFontStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70)),
            const SizedBox(height: 4),
            Text(content.layoutTitle ?? 'Dropping Soon', style: FontUtils.primaryFontStyle(
              fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 12),
            Row(children: [
              for (int i = 0; i < 3; i++) ...[
                Column(children: [
                  Container(height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(10)),
                    child: Text(parts[i], style: FontUtils.primaryFontStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
                  const SizedBox(height: 3),
                  Text(labels[i], style: FontUtils.primaryFontStyle(
                    fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white54)),
                ]),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 18), alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Notify me',
                  style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kInk))),
            ]),
          ])),
      ])),
    );
  }
}
