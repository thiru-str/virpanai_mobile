import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// Food / organic-store component batch (SATVA genre). Mirrors the web
// components Certifications1, NutritionFacts1, Recipe1, SubscriptionBox1 and
// FarmStory1. Earthy olive accent so the genre reads as a distinct brand.
const Color kOlive = Color(0xFF5C7A2F);
const Color kOliveSoft = Color(0xFFEEF2E0);

// Certifications1 — a row of trust badges (Certified Organic, FSSAI, …).
// layoutData items: { title, feature_text }.
class Certifications1 extends StatelessWidget {
  final Content content;
  const Certifications1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? '',
            centered: true),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final item in items)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cmsCard(context, Colors.white),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: kOlive.withOpacity(0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.verified_rounded, size: 18, color: kOlive),
                  const SizedBox(width: 8),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.title ?? '',
                            style: FontUtils.primaryFontStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: cmsCardText(context, AppColors.textColor))),
                        if ((item.featureText ?? '').trim().isNotEmpty)
                          Text(item.featureText!.trim(),
                              style: FontUtils.primaryFontStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: cmsCardText(context, AppColors.textColor50))),
                      ]),
                ]),
              ),
          ],
        ),
      ]),
    );
  }
}

// NutritionFacts1 — 2×2 stat cards (big olive value + label + sub).
// layoutData items: { title (value), feature_text (label), sub_title }.
class NutritionFacts1 extends StatelessWidget {
  final Content content;
  const NutritionFacts1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? ''),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 128),
          itemBuilder: (context, i) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cmsCard(context, Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kOlive.withOpacity(0.10)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(items[i].title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: kOlive)),
                  const SizedBox(height: 4),
                  Text(items[i].featureText ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cmsCardText(context, AppColors.textColor))),
                  if ((items[i].subTitle ?? '').trim().isNotEmpty)
                    Text(items[i].subTitle!.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: cmsCardText(context, AppColors.textColor50))),
                ]),
          ),
        ),
      ]),
    );
  }
}

// Recipe1 — horizontal rail of recipe cards (image, title, time, serves).
// layoutData items: { image, title, feature_text (time), sub_title (serves) }.
class Recipe1 extends StatelessWidget {
  final Content content;
  const Recipe1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
              ctaText: content.layoutRedirectTitle ?? ''),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => Container(
              width: 190,
              decoration: BoxDecoration(
                color: cmsCard(context, Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 16,
                      offset: Offset(0, 6)),
                ],
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      child: SizedBox(
                        height: 128,
                        width: double.infinity,
                        child: merchImageOrFallback(merchImage(items[i]),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items[i].title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: cmsCardText(context, AppColors.textColor))),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.schedule,
                                  size: 14, color: kOlive),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(items[i].featureText ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FontUtils.primaryFontStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: cmsCardText(context, AppColors.textColor50))),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.people_alt_outlined,
                                  size: 14, color: kOlive),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(items[i].subTitle ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FontUtils.primaryFontStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: cmsCardText(context, AppColors.textColor50))),
                              ),
                            ]),
                          ]),
                    ),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// SubscriptionBox1 — an olive "subscribe & save" panel with perks + CTA.
// layoutData items: { feature_text } perks; first item may carry an image.
class SubscriptionBox1 extends StatelessWidget {
  final Content content;
  const SubscriptionBox1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final perks = (content.layoutData ?? [])
        .map((d) => (d.featureText ?? d.title ?? '').trim())
        .where((t) => t.isNotEmpty)
        .take(4)
        .toList();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: kOlive, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if ((content.layoutSubTitle ?? '').trim().isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999)),
              child: Text(content.layoutSubTitle!.trim().toUpperCase(),
                  style: FontUtils.primaryFontStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white)),
            ),
          const SizedBox(height: 12),
          Text(content.layoutTitle ?? 'Subscribe & Save 15%',
              style: FontUtils.primaryFontStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 14),
          for (final p in perks)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Icon(Icons.check_circle,
                    size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(p,
                        style: FontUtils.primaryFontStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))),
              ]),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(content.layoutRedirectTitle ?? 'Start your box',
                  style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: kOlive)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 16, color: kOlive),
            ]),
          ),
        ]),
      ),
    );
  }
}

// FarmStory1 — farm-to-table story: image, narrative and 3 stats.
// layoutData: item[0] = { image, feature_text (narrative) }; rest = stats
// { title (value), feature_text (label) }.
class FarmStory1 extends StatelessWidget {
  final Content content;
  const FarmStory1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final hero = items.firstWhere((d) => (d.image ?? '').trim().isNotEmpty,
        orElse: () => items.first);
    final stats = items
        .where((d) =>
            (d.featureText ?? '').trim().isNotEmpty &&
            (d.image ?? '').trim().isEmpty)
        .take(3)
        .toList();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: merchImageOrFallback(merchImage(hero), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16),
        if ((content.layoutSubTitle ?? '').trim().isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: kOliveSoft, borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.eco, size: 14, color: kOlive),
              const SizedBox(width: 6),
              Flexible(
                child: Text(content.layoutSubTitle!.trim().toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: kOlive)),
              ),
            ]),
          ),
        const SizedBox(height: 10),
        Text(content.layoutTitle ?? '',
            style: FontUtils.primaryFontStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: cmsText(context, AppColors.textColor))),
        if ((hero.featureText ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(hero.featureText!.trim(),
              style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: cmsText(context, AppColors.textColor50))
                  .copyWith(height: 1.5)),
        ],
        if (stats.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(children: [
            for (final s in stats)
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: cmsText(context, AppColors.textColor))),
                  Text(s.featureText ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: cmsText(context, AppColors.textColor50))),
                ]),
              ),
          ]),
        ],
      ]),
    );
  }
}
