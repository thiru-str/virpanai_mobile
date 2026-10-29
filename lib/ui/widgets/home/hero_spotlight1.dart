import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// SplitHero1 — split hero: image beside a content panel.
class SplitHero1 extends StatelessWidget {
  final Content content;
  const SplitHero1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kInk.withOpacity(0.08))),
        child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            child: merchImageOrFallback(content.layoutBannerImage ?? '', fit: BoxFit.cover))),
          Expanded(child: Padding(padding: const EdgeInsets.all(16), child: Column(
            mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
              if ((content.layoutSubTitle ?? '').isNotEmpty)
                Text(content.layoutSubTitle!.toUpperCase(),
                  style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cmsCardText(context, AppColors.textColor50))),
              const SizedBox(height: 6),
              Text(content.layoutTitle ?? '', maxLines: 3, overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
              const SizedBox(height: 12),
              Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.center,
                decoration: BoxDecoration(color: cmsAccent(context, kInk), borderRadius: BorderRadius.circular(10)),
                child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Shop now',
                  style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cmsOn(cmsAccent(context, kInk))))),
            ]))),
        ])),
      ),
    );
  }
}

// ProductSpotlight1 — vertical product spotlight (big image, details, CTA).
class ProductSpotlight1 extends StatelessWidget {
  final Content content;
  const ProductSpotlight1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final hero = items.first;
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kInk.withOpacity(0.08))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(aspectRatio: 16 / 9, child: merchImageOrFallback(merchImage(hero), fit: BoxFit.cover))),
          Padding(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: kFresh.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text((content.layoutSubTitle ?? 'FEATURED').toUpperCase(),
                  style: FontUtils.primaryFontStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kFresh))),
              const SizedBox(height: 8),
              Text(hero.title ?? '', style: FontUtils.primaryFontStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
              const SizedBox(height: 6),
              Text(merchSubtitle(hero).isEmpty ? 'Crafted to last, designed for every day.' : merchSubtitle(hero),
                maxLines: 2, style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50))),
              const SizedBox(height: 12),
              Row(children: [
                Text(CurrencyUtil.appendCurrency(merchSellingPrice(hero)),
                  style: FontUtils.primaryFontStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
                const Spacer(),
                Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 22), alignment: Alignment.center,
                  decoration: BoxDecoration(color: cmsAccent(context, kInk), borderRadius: BorderRadius.circular(12)),
                  child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Add to bag',
                    style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cmsOn(cmsAccent(context, kInk))))),
              ]),
            ])),
        ]),
      ),
    );
  }
}

// TripleCollection1 — three collection tiles in a row.
class TripleCollection1 extends StatelessWidget {
  final Content content;
  const TripleCollection1({super.key, required this.content});
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
        SizedBox(height: 150, child: Row(children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i != 0) const SizedBox(width: 10),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Stack(children: [
              Positioned.fill(child: merchImageOrFallback(merchImage(items[i]), fit: BoxFit.cover)),
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent])))),
              Positioned(left: 10, right: 10, bottom: 10, child: Text(items[i].title ?? '',
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))),
            ]))),
          ],
        ])),
      ]),
    );
  }
}

// DualBanner1 — two side-by-side promo banners.
class DualBanner1 extends StatelessWidget {
  final Content content;
  const DualBanner1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(2).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(height: 130, child: Row(children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Stack(children: [
            Positioned.fill(child: merchImageOrFallback(merchImage(items[i]), fit: BoxFit.cover)),
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
                colors: [Colors.black.withOpacity(0.55), Colors.transparent])))),
            Positioned(left: 12, top: 0, bottom: 0, child: Center(child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(items[i].salesText ?? 'Up to 40% Off', style: FontUtils.primaryFontStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                Text(items[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
              ]))),
          ]))),
        ],
      ])),
    );
  }
}
