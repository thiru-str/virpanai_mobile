import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// HeroBanner1 — full-bleed promotional hero with headline + CTA.
class HeroBanner1 extends StatelessWidget {
  final Content content;
  const HeroBanner1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AspectRatio(aspectRatio: 16 / 10,
              child: merchImageOrFallback(content.layoutBannerImage ?? '', fit: BoxFit.cover)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.55), Colors.transparent]),
                ),
              ),
            ),
            Positioned(
              left: 18, right: 18, bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((content.layoutSubTitle ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22), borderRadius: BorderRadius.circular(20)),
                      child: Text(content.layoutSubTitle!,
                        style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  const SizedBox(height: 8),
                  Text(content.layoutTitle ?? '',
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 12),
                  Container(
                    height: 38, padding: const EdgeInsets.symmetric(horizontal: 18), alignment: Alignment.center,
                    decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(20)),
                    child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Shop now',
                      style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kInk)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SaleCountdown1 — dark sale-urgency banner with a countdown.
class SaleCountdown1 extends StatelessWidget {
  final Content content;
  const SaleCountdown1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    const parts = ['02', '11', '45', '30'];
    const labels = ['DAYS', 'HRS', 'MIN', 'SEC'];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: cmsPanel(context, kInk), borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((content.layoutSubTitle ?? '').isNotEmpty)
              Text(content.layoutSubTitle!.toUpperCase(),
                style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cmsText(context, Colors.white70))),
            const SizedBox(height: 6),
            Text(content.layoutTitle ?? '',
              style: FontUtils.primaryFontStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cmsText(context, Colors.white))),
            const SizedBox(height: 14),
            Row(
              children: [
                for (int i = 0; i < 4; i++) ...[
                  Column(
                    children: [
                      Container(
                        height: 44, width: 44, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: Text(parts[i],
                          style: FontUtils.primaryFontStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cmsText(context, Colors.white))),
                      ),
                      const SizedBox(height: 4),
                      Text(labels[i],
                        style: FontUtils.primaryFontStyle(fontSize: 9, fontWeight: FontWeight.w600, color: cmsText(context, Colors.white54))),
                    ],
                  ),
                  if (i != 3) const SizedBox(width: 10),
                ],
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
