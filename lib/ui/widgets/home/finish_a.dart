import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

class MinimalHero1 extends StatelessWidget {
  final Content content;
  const MinimalHero1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    child: Column(children: [
      if ((content.layoutSubTitle ?? '').isNotEmpty)
        Text(content.layoutSubTitle!.toUpperCase(), style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cmsCardText(context, AppColors.textColor50))),
      const SizedBox(height: 10),
      Text(content.layoutTitle ?? 'Timeless. Effortless.', textAlign: TextAlign.center,
        style: FontUtils.primaryFontStyle(fontSize: 30, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
      const SizedBox(height: 16),
      Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 28), alignment: Alignment.center,
        decoration: BoxDecoration(color: cmsAccent(context, kInk), borderRadius: BorderRadius.circular(22)),
        child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Discover',
          style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cmsOn(cmsAccent(context, kInk))))),
    ]),
  );
}

class IconActionNav1 extends StatelessWidget {
  final Content content;
  const IconActionNav1({super.key, required this.content});
  static const _ic = [Icons.receipt_long, Icons.favorite_border, Icons.account_balance_wallet, Icons.headset_mic];
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16), border: Border.all(color: kInk.withOpacity(0.08))),
        child: Row(children: [
          for (int i = 0; i < items.length; i++) Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(height: 44, width: 44, decoration: BoxDecoration(color: kInk.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
              child: Icon(_ic[i % _ic.length], color: kInk, size: 22)),
            const SizedBox(height: 6),
            Text(items[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cmsCardText(context, AppColors.textColor))),
          ])),
        ]),
      ),
    );
  }
}

class WideProductCard1 extends StatelessWidget {
  final Content content;
  const WideProductCard1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final h = items.first;
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(18), border: Border.all(color: kInk.withOpacity(0.08))),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: const SizedBox(height: 104, width: 104, child: ImageFallbackWidget(fit: BoxFit.cover))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            if ((content.layoutSubTitle ?? '').isNotEmpty)
              Text(content.layoutSubTitle!.toUpperCase(), style: FontUtils.primaryFontStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kFresh)),
            const SizedBox(height: 4),
            Text(h.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
            Text(merchSubtitle(h), maxLines: 1, overflow: TextOverflow.ellipsis, style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50))),
            const SizedBox(height: 8),
            Row(children: [
              Text(CurrencyUtil.appendCurrency(merchSellingPrice(h)), style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
              const Spacer(),
              const GroceryAddButton(),
            ]),
          ])),
        ]),
      ),
    );
  }
}

class CircleCategoryRail1 extends StatelessWidget {
  final Content content;
  const CircleCategoryRail1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((content.layoutTitle ?? '').isNotEmpty)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '')),
        const SizedBox(height: 12),
        SizedBox(height: 96, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) => SizedBox(width: 68, child: Column(children: [
            ClipOval(child: SizedBox(height: 64, width: 64, child: Container(color: AppColors.secondary, child: const ImageFallbackWidget(fit: BoxFit.cover)))),
            const SizedBox(height: 6),
            Text(items[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cmsCardText(context, AppColors.textColor))),
          ]))),
        ),
      ]),
    );
  }
}

class SpotlightDuo1 extends StatelessWidget {
  final Content content;
  const SpotlightDuo1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(2).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(height: 180, child: Row(children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(width: 12),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Stack(children: [
            const Positioned.fill(child: ImageFallbackWidget(fit: BoxFit.cover)),
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Colors.black.withOpacity(0.55), Colors.transparent])))),
            Positioned(left: 12, right: 12, bottom: 12, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(items[i].title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(CurrencyUtil.appendCurrency(merchSellingPrice(items[i])), style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70)),
            ])),
          ]))),
        ],
      ])),
    );
  }
}
