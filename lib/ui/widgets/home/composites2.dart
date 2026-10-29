import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';
import 'composites_shared.dart';

// CollectionCover1 — large collection cover with an overlaid product peek strip.
class CollectionCover1 extends StatelessWidget {
  final Content content;
  const CollectionCover1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          AspectRatio(aspectRatio: 16 / 11,
            child: merchImageOrFallback(content.layoutBannerImage ?? '', fit: BoxFit.cover)),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent])))),
          Positioned(left: 16, right: 16, bottom: 16, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
            children: [
              Text(content.layoutTitle ?? '', style: FontUtils.primaryFontStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              if ((content.layoutSubTitle ?? '').isNotEmpty)
                Text(content.layoutSubTitle!, style: FontUtils.primaryFontStyle(
                  fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70)),
              const SizedBox(height: 12),
              Row(children: [
                for (int i = 0; i < (items.length > 3 ? 3 : items.length); i++)
                  Padding(padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: Container(height: 48, width: 48, color: Colors.white,
                        child: merchImageOrFallback(merchImage(items[i]), fit: BoxFit.cover)))),
                Container(height: 48, width: 48, alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                  child: Text('+${items.length}', style: FontUtils.primaryFontStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
              ]),
            ],
          )),
        ]),
      ),
    );
  }
}

// MegaSpotlight1 — "max of all": category chips + spotlight + mini rail in one card.
class MegaSpotlight1 extends StatelessWidget {
  final Content content;
  const MegaSpotlight1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final hero = items.first;
    final rail = items.length > 1 ? items.sublist(1) : items;
    final chips = ['All', 'New', 'Popular', 'Deals'];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kInk.withOpacity(0.08))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(content.layoutTitle ?? '', style: FontUtils.primaryFontStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
          const SizedBox(height: 10),
          Row(children: [
            for (int i = 0; i < chips.length; i++)
              Padding(padding: const EdgeInsets.only(right: 8),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: i == 0 ? kInk : kInk.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                  child: Text(chips[i], style: FontUtils.primaryFontStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: i == 0 ? Colors.white : AppColors.textColor50)))),
          ]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(14), child: Stack(children: [
            AspectRatio(aspectRatio: 16 / 8, child: merchImageOrFallback(merchImage(hero), fit: BoxFit.cover)),
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
                colors: [Colors.black.withOpacity(0.55), Colors.transparent])))),
            Positioned(left: 14, top: 0, bottom: 0, child: Center(child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hero.title ?? '', style: FontUtils.primaryFontStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text(CurrencyUtil.appendCurrency(merchSellingPrice(hero)), style: FontUtils.primaryFontStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ]))),
          ])),
          const SizedBox(height: 12),
          SizedBox(height: 238, child: ListView.separated(
            scrollDirection: Axis.horizontal, itemCount: rail.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => GroceryTile(data: rail[i], width: 124))),
        ]),
      ),
    );
  }
}

// TabbedList1 — tab pills + a vertical product list.
class TabbedList1 extends StatelessWidget {
  final Content content;
  const TabbedList1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final tabs = ['Trending', 'New In', 'Top Rated'];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
        const SizedBox(height: 12),
        Row(children: [
          for (int i = 0; i < tabs.length; i++)
            Padding(padding: const EdgeInsets.only(right: 8),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: i == 0 ? kInk : Colors.white, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kInk.withOpacity(0.12))),
                child: Text(tabs[i], style: FontUtils.primaryFontStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: i == 0 ? Colors.white : AppColors.textColor)))),
        ]),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kInk.withOpacity(0.08))),
          child: Column(children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i != 0) const Divider(height: 20),
              ListRow(data: items[i]),
            ],
          ])),
      ]),
    );
  }
}

// PickForYou1 — one big spotlight tile beside a mini pick list.
class PickForYou1 extends StatelessWidget {
  final Content content;
  const PickForYou1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final hero = items.first;
    final rest = items.length > 1 ? items.sublist(1, items.length > 3 ? 3 : items.length) : <LayoutDatum>[];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
        const SizedBox(height: 12),
        IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Stack(children: [
            Positioned.fill(child: merchImageOrFallback(merchImage(hero), fit: BoxFit.cover)),
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.55), Colors.transparent])))),
            Positioned(left: 12, right: 12, bottom: 12, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(hero.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(CurrencyUtil.appendCurrency(merchSellingPrice(hero)),
                  style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ])),
          ]))),
          const SizedBox(width: 12),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (int i = 0; i < rest.length; i++) ...[
              if (i != 0) const SizedBox(height: 10),
              Expanded(child: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kInk.withOpacity(0.08))),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(10),
                    child: SizedBox(height: 44, width: 44, child: merchImageOrFallback(merchImage(rest[i]), fit: BoxFit.cover))),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    Text(rest[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cmsCardText(context, AppColors.textColor))),
                    Text(CurrencyUtil.appendCurrency(merchSellingPrice(rest[i])),
                      style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
                  ])),
                ]))),
            ],
          ])),
        ])),
      ]),
    );
  }
}
