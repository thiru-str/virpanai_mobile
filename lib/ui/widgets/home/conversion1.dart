import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// Loyalty1 — rewards / points programme banner (dark).
class Loyalty1 extends StatelessWidget {
  final Content content;
  const Loyalty1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(height: 46, width: 46,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(content.layoutTitle ?? 'Earn Points on Every Order',
              style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(content.layoutSubTitle ?? 'Unlock perks & birthday treats',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70)),
          ])),
          const SizedBox(width: 10),
          Container(height: 34, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center,
            decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(10)),
            child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Join',
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kInk))),
        ]),
      ),
    );
  }
}

// Referral1 — refer & earn card.
class Referral1 extends StatelessWidget {
  final Content content;
  const Referral1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kInk.withOpacity(0.08))),
        child: Row(children: [
          Container(height: 46, width: 46,
            decoration: BoxDecoration(color: kFresh.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.card_giftcard, color: kFresh, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(content.layoutTitle ?? 'Refer a Friend, Get Rs 300',
              style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
            const SizedBox(height: 2),
            Text(content.layoutSubTitle ?? 'They get Rs 300 off too',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50))),
          ])),
          const SizedBox(width: 10),
          Container(height: 34, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center,
            decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(10)),
            child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Invite',
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
        ]),
      ),
    );
  }
}

// Wishlist1 — saved-items rail with a wishlist header.
class Wishlist1 extends StatelessWidget {
  final Content content;
  const Wishlist1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Icon(Icons.favorite, color: Color(0xFFD64545), size: 20),
            const SizedBox(width: 8),
            Expanded(child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '')),
          ])),
        const SizedBox(height: 12),
        SizedBox(height: 246, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => GroceryTile(data: items[i], width: 138))),
      ]),
    );
  }
}

// StockUrgency1 — low-stock / high-demand urgency strip.
class StockUrgency1 extends StatelessWidget {
  final Content content;
  const StockUrgency1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: const Color(0x14D64545), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x33D64545))),
        child: Row(children: [
          Container(height: 32, width: 32,
            decoration: const BoxDecoration(color: Color(0xFFD64545), shape: BoxShape.circle),
            child: const Icon(Icons.local_fire_department, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(content.layoutTitle ?? 'Selling fast — 200+ sold in the last 24 hours',
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cmsCardText(context, AppColors.textColor)))),
        ]),
      ),
    );
  }
}
