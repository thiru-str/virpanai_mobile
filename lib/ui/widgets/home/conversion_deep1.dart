import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// SizeGuide1 — fit-finder / size-guide prompt.
class SizeGuide1 extends StatelessWidget {
  final Content content;
  const SizeGuide1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kInk.withOpacity(0.08))),
        child: Row(children: [
          Container(height: 44, width: 44,
            decoration: BoxDecoration(color: kInk.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.straighten, color: kInk, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(content.layoutTitle ?? 'Not sure about your size?',
              style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
            const SizedBox(height: 2),
            Text(content.layoutSubTitle ?? 'Use our fit finder for a recommendation',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50))),
          ])),
          Container(height: 34, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center,
            decoration: BoxDecoration(color: cmsAccent(context, kInk), borderRadius: BorderRadius.circular(10)),
            child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Find',
              style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cmsOn(cmsAccent(context, kInk))))),
        ]),
      ),
    );
  }
}

// PincodeCheck1 — delivery / pincode availability checker.
class PincodeCheck1 extends StatelessWidget {
  final Content content;
  const PincodeCheck1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kInk.withOpacity(0.08))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.location_on, color: kFresh, size: 20),
            const SizedBox(width: 8),
            Text(content.layoutTitle ?? 'Check Delivery',
              style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.centerLeft,
              decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
              child: Text('Enter pincode',
                style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50))))),
            const SizedBox(width: 8),
            Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 18), alignment: Alignment.center,
              decoration: BoxDecoration(color: cmsAccent(context, kInk), borderRadius: BorderRadius.circular(12)),
              child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Check',
                style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cmsOn(cmsAccent(context, kInk))))),
          ]),
        ]),
      ),
    );
  }
}

// AppPromo1 — cross-promo / app feature banner (dark).
class AppPromo1 extends StatelessWidget {
  final Content content;
  const AppPromo1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: cmsPanel(context, kInk), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(content.layoutTitle ?? 'Exclusive App Deals',
              style: FontUtils.primaryFontStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cmsText(context, Colors.white))),
            const SizedBox(height: 4),
            Text(content.layoutSubTitle ?? 'Unlock app-only offers & faster checkout',
              maxLines: 2, style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: cmsText(context, Colors.white70))),
            const SizedBox(height: 12),
            Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.center,
              decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(10)),
              child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Explore',
                style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kInk))),
          ])),
          const SizedBox(width: 12),
          Container(height: 72, width: 72,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.smartphone, color: Colors.white, size: 34)),
        ]),
      ),
    );
  }
}

// Membership1 — premium membership promo with perks.
class Membership1 extends StatelessWidget {
  final Content content;
  const Membership1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final perks = (content.layoutData ?? []).map((e) => e.featureText ?? e.title ?? '').where((s) => s.isNotEmpty).take(3).toList();
    final list = perks.isNotEmpty ? perks : ['Free shipping on all orders', 'Early access to sales', 'Exclusive member pricing'];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2A2A2A), Color(0xFF0B0B0B)]),
          borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFF5A623), size: 22),
            const SizedBox(width: 8),
            Text(content.layoutTitle ?? 'Join Premium',
              style: FontUtils.primaryFontStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ]),
          const SizedBox(height: 12),
          for (final p in list) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            const Icon(Icons.check_circle, color: Color(0xFF1BA672), size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(p, style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white))),
          ])),
          const SizedBox(height: 4),
          Container(height: 40, alignment: Alignment.center,
            decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(12)),
            child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Become a member',
              style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kInk))),
        ]),
      ),
    );
  }
}
