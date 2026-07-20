import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

// Reviews1 — customer review cards rail.
class Reviews1 extends StatelessWidget {
  final Content content;
  const Reviews1({super.key, required this.content});
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '')),
          const SizedBox(height: 12),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final r = items[i];
                final rating = (num.tryParse(r.rating?.toString() ?? '5') ?? 5).round();
                return Container(
                  width: 260,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kInk.withOpacity(0.08))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        for (int s = 0; s < 5; s++)
                          Icon(Icons.star, size: 14, color: s < rating ? const Color(0xFFF5A623) : kInk.withOpacity(0.15)),
                      ]),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Text('"${r.featureText ?? ''}"',
                          maxLines: 3, overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColor)),
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(
                          height: 30, width: 30, alignment: Alignment.center,
                          decoration: BoxDecoration(color: kFresh.withOpacity(0.12), shape: BoxShape.circle),
                          child: Text((r.title ?? 'A').substring(0, 1),
                            style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kFresh))),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title ?? '',
                              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColor)),
                            Text('Verified buyer',
                              style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
                          ],
                        ),
                      ]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// CouponRow1 — coupon-code tickets rail.
class CouponRow1 extends StatelessWidget {
  final Content content;
  const CouponRow1({super.key, required this.content});
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '')),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final c = items[i];
                return Container(
                  width: 240,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kFresh.withOpacity(0.35), width: 1.5, style: BorderStyle.solid)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.salesText ?? 'FLAT 20% OFF',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textColor)),
                            const SizedBox(height: 2),
                            Text(c.featureText ?? 'On your order',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: kFresh.withOpacity(0.10), borderRadius: BorderRadius.circular(8)),
                        child: Text(c.title ?? 'SAVE20',
                          style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kFresh)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
