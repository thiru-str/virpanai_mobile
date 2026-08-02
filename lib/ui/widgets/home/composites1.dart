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

// SpotlightList1 — a featured spotlight product on top + a companion list.
class SpotlightList1 extends StatelessWidget {
  final Content content;
  const SpotlightList1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final hero = items.first;
    final rest = items.length > 1 ? items.sublist(1, items.length > 4 ? 4 : items.length) : <LayoutDatum>[];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kInk.withOpacity(0.08))),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: SizedBox(height: 92, width: 92, child: merchImageOrFallback(merchImage(hero), fit: BoxFit.cover))),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: kFresh.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('FEATURED', style: FontUtils.primaryFontStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kFresh))),
                    const SizedBox(height: 6),
                    Text(hero.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
                    if ((merchSubtitle(hero)).isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 2),
                        child: Text(merchSubtitle(hero), maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50)))),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text(CurrencyUtil.appendCurrency(merchSellingPrice(hero)),
                        style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
                      const Spacer(),
                      const GroceryAddButton(),
                    ]),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < rest.length; i++) ...[
            if (i != 0) const Divider(height: 20),
            ListRow(data: rest[i]),
          ],
        ],
      ),
    );
  }
}

// CategoryCollection1 — category chips + a collection grid in one section.
class CategoryCollection1 extends StatelessWidget {
  final Content content;
  const CategoryCollection1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final chips = items.take(5).map((e) => e.title ?? '').toList();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '')),
          const SizedBox(height: 12),
          SizedBox(height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: chips.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Container(
                alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: i == 0 ? kInk : Colors.white, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kInk.withOpacity(0.12))),
                child: Text(chips[i], style: FontUtils.primaryFontStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: i == 0 ? Colors.white : AppColors.textColor)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: items.length > 4 ? 4 : items.length, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5),
              itemBuilder: (context, i) => ClipRRect(borderRadius: BorderRadius.circular(16),
                child: Stack(children: [
                  Positioned.fill(child: merchImageOrFallback(merchImage(items[i]), fit: BoxFit.cover)),
                  Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center,
                      colors: [Colors.black.withOpacity(0.5), Colors.transparent])))),
                  Positioned(left: 12, bottom: 12, child: Text(items[i].title ?? '',
                    style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white))),
                ])),
            ),
          ),
        ],
      ),
    );
  }
}

// ListCard1 — a ranked "top picks" vertical list card.
class ListCard1 extends StatelessWidget {
  final Content content;
  const ListCard1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(5).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '',
            ctaText: content.layoutRedirectTitle ?? ''),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kInk.withOpacity(0.08))),
            child: Column(children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i != 0) const Divider(height: 20),
                ListRow(data: items[i], rank: i + 1),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

// StoryRail1 — story-style circular collection covers.
class StoryRail1 extends StatelessWidget {
  final Content content;
  const StoryRail1({super.key, required this.content});
  static const _colors = [0xFF8E6CEF, 0xFFEF6C1A, 0xFF1BA672, 0xFF3B5BDB, 0xFFD6336C, 0xFF0E9C95, 0xFFF5A623, 0xFFE64980];
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '')),
          const SizedBox(height: 12),
          SizedBox(height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => StoryCircle(label: items[i].title ?? '', color: Color(_colors[i % _colors.length]), imageUrl: merchImage(items[i])),
            ),
          ),
        ],
      ),
    );
  }
}
