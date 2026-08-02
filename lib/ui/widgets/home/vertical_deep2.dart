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

// RestaurantOffers1 — restaurant offer cards rail (offer ribbon + cuisine/rating).
class RestaurantOffers1 extends StatelessWidget {
  final Content content;
  const RestaurantOffers1({super.key, required this.content});
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
        SizedBox(height: 196, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => SizedBox(width: 220, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(14), child: Stack(children: [
              const AspectRatio(aspectRatio: 16 / 9, child: ImageFallbackWidget(fit: BoxFit.cover)),
              Positioned(left: 0, bottom: 0, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(color: Color(0xFFEF6C1A),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10))),
                child: Text(items[i].salesText ?? 'FLAT 50% OFF',
                  style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)))),
            ])),
            const SizedBox(height: 8),
            Text(items[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.star, size: 12, color: Color(0xFF1BA672)),
              const SizedBox(width: 3),
              Text('${merchRating(items[i]).isEmpty ? '4.3' : merchRating(items[i])}  ·  ${items[i].featureText ?? 'North Indian'}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cmsCardText(context, AppColors.textColor50))),
            ]),
          ]))),
        ),
      ]),
    );
  }
}

// ElectronicsDeals1 — electronics deals rail with discount badges.
class ElectronicsDeals1 extends StatelessWidget {
  final Content content;
  const ElectronicsDeals1({super.key, required this.content});
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
        SizedBox(height: 246, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => GroceryTile(data: items[i], width: 138))),
      ]),
    );
  }
}

// PharmacyCategories1 — health & pharmacy category chips (teal).
class PharmacyCategories1 extends StatelessWidget {
  final Content content;
  const PharmacyCategories1({super.key, required this.content});
  static const _teal = Color(0xFF0E9C95);
  static const _icons = [Icons.medication, Icons.healing, Icons.monitor_heart, Icons.child_care, Icons.spa, Icons.fitness_center, Icons.visibility, Icons.vaccines];
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((content.layoutTitle ?? '').isNotEmpty) ...[
          HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
          const SizedBox(height: 12),
        ],
        GridView.builder(
          itemCount: items.length > 8 ? 8 : items.length, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 16, mainAxisExtent: 92),
          itemBuilder: (context, i) => Column(mainAxisSize: MainAxisSize.min, children: [
            Container(height: 58, width: 58,
              decoration: BoxDecoration(color: _teal.withOpacity(0.10), shape: BoxShape.circle),
              child: Icon(_icons[i % _icons.length], color: _teal, size: 26)),
            const SizedBox(height: 6),
            Text(items[i].title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cmsCardText(context, AppColors.textColor))),
          ]),
        ),
      ]),
    );
  }
}

// BeautyShades1 — beauty spotlight with selectable shade swatches.
class BeautyShades1 extends StatelessWidget {
  final Content content;
  const BeautyShades1({super.key, required this.content});
  static const _shades = [0xFFD64545, 0xFFB5462B, 0xFF8E4B6E, 0xFFCB6D51, 0xFF7A3B57, 0xFFE08A8A];
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final hero = items.first;
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kInk.withOpacity(0.08))),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12),
              child: const SizedBox(height: 96, width: 96, child: ImageFallbackWidget(fit: BoxFit.cover))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(hero.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
              const SizedBox(height: 6),
              Row(children: [
                for (int i = 0; i < _shades.length; i++)
                  Padding(padding: const EdgeInsets.only(right: 8),
                    child: Container(height: 22, width: 22,
                      decoration: BoxDecoration(color: Color(_shades[i]), shape: BoxShape.circle,
                        border: Border.all(color: i == 0 ? kInk : Colors.transparent, width: 2)))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Text(CurrencyUtil.appendCurrency(merchSellingPrice(hero)),
                  style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
                const Spacer(),
                Container(height: 32, padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.center,
                  decoration: BoxDecoration(color: cmsAccent(context, const Color(0xFFD6336C)), borderRadius: BorderRadius.circular(10)),
                  child: Text('ADD', style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w800, color: cmsOn(cmsAccent(context, const Color(0xFFD6336C)))))),
              ]),
            ])),
          ]),
        ),
      ]),
    );
  }
}
