import 'package:flutter/material.dart';
import 'cms_text_color.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';

class ContactSupport1 extends StatelessWidget {
  final Content content;
  const ContactSupport1({super.key, required this.content});
  static const _items = [[Icons.chat_bubble_outline, 'Chat', '9am-9pm'], [Icons.call, 'Call us', '1800-000'], [Icons.mail_outline, 'Email', 'care@brand']];
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(children: [
      for (int i = 0; i < _items.length; i++) ...[
        if (i != 0) const SizedBox(width: 10),
        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16), border: Border.all(color: kInk.withOpacity(0.08))),
          child: Column(children: [
            Icon(_items[i][0] as IconData, color: kInk, size: 24),
            const SizedBox(height: 8),
            Text(_items[i][1] as String, style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cmsCardText(context, AppColors.textColor))),
            Text(_items[i][2] as String, style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50))),
          ]))),
      ],
    ]),
  );
}

class FooterCta1 extends StatelessWidget {
  final Content content;
  const FooterCta1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Container(padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cmsPanel(context, kInk), borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(content.layoutTitle ?? 'Shop Anytime, Anywhere', textAlign: TextAlign.center,
          style: FontUtils.primaryFontStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cmsText(context, Colors.white))),
        const SizedBox(height: 14),
        Container(height: 42, padding: const EdgeInsets.symmetric(horizontal: 26), alignment: Alignment.center,
          decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(22)),
          child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Start shopping',
            style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kInk))),
        const SizedBox(height: 16),
        Wrap(spacing: 16, runSpacing: 8, alignment: WrapAlignment.center, children: [
          for (final l in ['About', 'Contact', 'Returns', 'Privacy', 'Terms'])
            Text(l, style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cmsText(context, Colors.white60))),
        ]),
      ]),
    ),
  );
}

class AnnouncementBar1 extends StatelessWidget {
  final Content content;
  const AnnouncementBar1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    child: Container(width: double.infinity, color: cmsPanel(context, kInk),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(content.layoutTitle ?? 'Free shipping on orders over Rs 499  •  Shop now',
        textAlign: TextAlign.center, style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cmsText(context, Colors.white)))),
  );
}

class StickyOffer1 extends StatelessWidget {
  final Content content;
  const StickyOffer1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => Container(
    decoration: AppUtils.buildLayoutBackground(content),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(24), border: Border.all(color: kInk.withOpacity(0.10)),
        boxShadow: [BoxShadow(color: kInk.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(14)),
          child: Text('OFFER', style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
        const SizedBox(width: 10),
        Expanded(child: Text(content.layoutTitle ?? 'Extra 10% off — code WELCOME10', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cmsCardText(context, AppColors.textColor)))),
        Container(height: 32, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center,
          decoration: BoxDecoration(color: cmsAccent(context, kFresh), borderRadius: BorderRadius.circular(16)),
          child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Apply', style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cmsOn(cmsAccent(context, kFresh))))),
      ]),
    ),
  );
}

class PromoMarquee1 extends StatelessWidget {
  final Content content;
  const PromoMarquee1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final msgs = (content.layoutData ?? []).map((e) => e.title ?? '').where((s) => s.isNotEmpty).toList();
    final list = msgs.isNotEmpty ? msgs : ['Free delivery over Rs 499', 'Easy 7-day returns', 'COD available', 'Extra 10% off first order'];
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(color: kFresh.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
        child: ListView.separated(scrollDirection: Axis.horizontal,
          itemCount: list.length, separatorBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4), child: Center(child: Container(height: 4, width: 4,
              decoration: BoxDecoration(color: kFresh.withOpacity(0.5), shape: BoxShape.circle)))),
          itemBuilder: (context, i) => Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(list[i], style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kFresh))))),
      ),
    );
  }
}
