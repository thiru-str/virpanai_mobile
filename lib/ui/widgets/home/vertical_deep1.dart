import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';
import 'verticals_shared.dart';

// SearchHeroVertical1 — search-led hero with vertical/quick tags.
class SearchHeroVertical1 extends StatelessWidget {
  final Content content;
  const SearchHeroVertical1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final tags = (content.layoutData ?? []).take(5).map((e) => e.title ?? '').toList();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(content.layoutTitle ?? 'What are you looking for?',
          style: FontUtils.primaryFontStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textColor)),
        const SizedBox(height: 12),
        Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kInk.withOpacity(0.10))),
          child: Row(children: [
            const Icon(Icons.search, size: 20, color: AppColors.tabInActivecolor),
            const SizedBox(width: 10),
            Text('Search across all categories',
              style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
          ])),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in (tags.isEmpty ? ['Grocery', 'Food', 'Pharmacy', 'Under Rs 99'] : tags))
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: kFresh.withOpacity(0.08), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kFresh.withOpacity(0.25))),
              child: Text(t, style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kFresh))),
        ]),
      ]),
    );
  }
}

// ServiceBooking1 — bookable services grid (salon, repair, cleaning...).
class ServiceBooking1 extends StatelessWidget {
  final Content content;
  const ServiceBooking1({super.key, required this.content});
  static const _icons = [Icons.content_cut, Icons.build, Icons.cleaning_services, Icons.plumbing, Icons.electrical_services, Icons.spa];
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length > 6 ? 6 : items.length, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 104),
          itemBuilder: (context, i) => Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kInk.withOpacity(0.08))),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 40, width: 40,
                decoration: BoxDecoration(color: const Color(0x143B5BDB), borderRadius: BorderRadius.circular(12)),
                child: Icon(_icons[i % _icons.length], color: const Color(0xFF3B5BDB), size: 22)),
              const SizedBox(height: 8),
              Text(items[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textColor)),
            ])),
        ),
      ]),
    );
  }
}

// WalletCashback1 — wallet balance + cashback banner.
class WalletCashback1 extends StatelessWidget {
  final Content content;
  const WalletCashback1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1BA672), Color(0xFF0E9C95)]),
          borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(height: 46, width: 46,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(content.layoutTitle ?? 'Wallet Balance Rs 250',
              style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(content.layoutSubTitle ?? 'Earn 5% cashback on every order',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70)),
          ])),
          const SizedBox(width: 10),
          Container(height: 34, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Add money',
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0E9C95)))),
        ]),
      ),
    );
  }
}

// StorePickup1 — store pickup / near-you availability banner.
class StorePickup1 extends StatelessWidget {
  final Content content;
  const StorePickup1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kInk.withOpacity(0.08))),
        child: Row(children: [
          Container(height: 44, width: 44,
            decoration: BoxDecoration(color: kInk.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.storefront, color: kInk, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(content.layoutTitle ?? 'Pickup in store',
              style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textColor)),
            const SizedBox(height: 2),
            Text(content.layoutSubTitle ?? 'Ready in 2 hours at your nearest store',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
          ])),
          const Icon(Icons.chevron_right, color: AppColors.tabInActivecolor),
        ]),
      ),
    );
  }
}
