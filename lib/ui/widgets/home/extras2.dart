import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// TwoColProducts1 — standard 2-up product grid.
class TwoColProducts1 extends StatelessWidget {
  final Content content;
  const TwoColProducts1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '',
          ctaText: content.layoutRedirectTitle ?? ''),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length > 4 ? 4 : items.length, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 288),
          itemBuilder: (context, i) => GroceryTile(data: items[i], width: 0),
        ),
      ]),
    );
  }
}

// OfferDuo1 — two stacked offer strips.
class OfferDuo1 extends StatelessWidget {
  final Content content;
  const OfferDuo1({super.key, required this.content});
  static const _c = [0xFFEF6C1A, 0xFF3B5BDB];
  static const _ic = [Icons.percent, Icons.bolt];
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(2).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Color(_c[i % 2]).withOpacity(0.08), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Color(_c[i % 2]).withOpacity(0.22))),
            child: Row(children: [
              Container(height: 38, width: 38,
                decoration: BoxDecoration(color: Color(_c[i % 2]), borderRadius: BorderRadius.circular(10)),
                child: Icon(_ic[i % 2], color: cmsCard(context, Colors.white), size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(items[i].salesText ?? items[i].title ?? 'Special Offer',
                  style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
                if ((items[i].featureText ?? '').isNotEmpty)
                  Text(items[i].featureText!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50))),
              ])),
              const Icon(Icons.chevron_right, color: AppColors.tabInActivecolor),
            ])),
        ],
      ]),
    );
  }
}

// NewInTabs1 — tabbed new-arrivals rail.
class NewInTabs1 extends StatelessWidget {
  final Content content;
  const NewInTabs1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final tabs = ['New In', 'Bestsellers', 'Under Rs 999'];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '')),
        const SizedBox(height: 10),
        SizedBox(height: 34, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tabs.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) => Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: i == 0 ? kInk : Colors.white, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kInk.withOpacity(0.12))),
            child: Text(tabs[i], style: FontUtils.primaryFontStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: i == 0 ? Colors.white : AppColors.textColor))))),
        const SizedBox(height: 12),
        SizedBox(height: 246, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => GroceryTile(data: items[i], width: 138))),
      ]),
    );
  }
}

// TrustBadges1 — payment / trust badges row.
class TrustBadges1 extends StatelessWidget {
  final Content content;
  const TrustBadges1({super.key, required this.content});
  static const _items = [
    [Icons.payments, 'COD'], [Icons.lock, 'Secure'], [Icons.account_balance_wallet, 'UPI'], [Icons.credit_card, 'Cards'],
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kInk.withOpacity(0.08))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          for (final it in _items) Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(it[0] as IconData, color: cmsCardText(context, AppColors.textColor), size: 22),
            const SizedBox(height: 6),
            Text(it[1] as String, style: FontUtils.primaryFontStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: cmsCardText(context, AppColors.textColor50))),
          ]),
        ]),
      ),
    );
  }
}
