import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

class RecentlyViewed1 extends StatelessWidget {
  final Content content;
  const RecentlyViewed1({super.key, required this.content});
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
        SizedBox(height: 238, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => GroceryTile(data: items[i], width: 116))),
      ]),
    );
  }
}

class LimitedStock1 extends StatelessWidget {
  final Content content;
  const LimitedStock1({super.key, required this.content});
  static const _left = ['Only 3 left', 'Only 5 left', 'Only 2 left', 'Selling fast', 'Only 4 left', 'Low stock'];
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
        SizedBox(height: 300, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => SizedBox(width: 138, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            GroceryTile(data: items[i], width: 138),
            const SizedBox(height: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0x14D64545), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.local_fire_department, size: 12, color: Color(0xFFD64545)),
                const SizedBox(width: 4),
                Text(_left[i % _left.length], style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFD64545))),
              ])),
          ]))),
        ),
      ]),
    );
  }
}

class GiftBanner1 extends StatelessWidget {
  final Content content;
  const GiftBanner1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD6336C), Color(0xFF8E4B6E)]), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        const Icon(Icons.card_giftcard, color: Colors.white, size: 30),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(content.layoutTitle ?? 'The Perfect Gift', style: FontUtils.primaryFontStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(content.layoutSubTitle ?? 'Gift cards delivered instantly', maxLines: 1, overflow: TextOverflow.ellipsis, style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70)),
        ])),
        Container(height: 34, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Gift now', style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFD6336C)))),
      ]),
    ),
  );
}

class LoyaltyProgress1 extends StatelessWidget {
  final Content content;
  const LoyaltyProgress1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kInk.withOpacity(0.08))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.stars, color: Color(0xFFF5A623), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(content.layoutTitle ?? 'You are 250 points away from Gold', style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textColor))),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(children: [
          Container(height: 10, color: AppColors.secondary),
          FractionallySizedBox(widthFactor: 0.65, child: Container(height: 10, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1BA672), Color(0xFF0E9C95)])))),
        ])),
        const SizedBox(height: 8),
        Text(content.layoutSubTitle ?? '750 / 1000 points', style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
      ]),
    ),
  );
}

class RatingSummary1 extends StatelessWidget {
  final Content content;
  const RatingSummary1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kInk.withOpacity(0.08))),
      child: Row(children: [
        Column(children: [
          Text('4.8', style: FontUtils.primaryFontStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textColor)),
          Row(children: [for (int i = 0; i < 5; i++) const Icon(Icons.star, size: 12, color: Color(0xFFF5A623))]),
          const SizedBox(height: 2),
          Text('24k reviews', style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
        ]),
        const SizedBox(width: 20),
        Expanded(child: Column(children: [
          for (final r in [['5', 0.8], ['4', 0.14], ['3', 0.04], ['2', 0.01], ['1', 0.01]])
            Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(children: [
              Text('${r[0]}', style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColor50)),
              const SizedBox(width: 6),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Stack(children: [
                Container(height: 6, color: AppColors.secondary),
                FractionallySizedBox(widthFactor: (r[1] as double), child: Container(height: 6, color: const Color(0xFFF5A623))),
              ]))),
            ])),
        ])),
      ]),
    ),
  );
}
