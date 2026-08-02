import 'package:flutter/material.dart';
import 'cms_text_color.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';

// TrustStrip1 — reassurance row (shipping, returns, secure, support).
class TrustStrip1 extends StatelessWidget {
  final Content content;
  const TrustStrip1({super.key, required this.content});
  static const _icons = [Icons.local_shipping, Icons.restart_alt, Icons.verified_user, Icons.headset_mic];
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kInk.withOpacity(0.08))),
        child: Row(
          children: [
            for (int i = 0; i < (items.length > 4 ? 4 : items.length); i++)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 40, width: 40,
                      decoration: BoxDecoration(color: kFresh.withOpacity(0.10), shape: BoxShape.circle),
                      child: Icon(_icons[i % _icons.length], color: kFresh, size: 20)),
                    const SizedBox(height: 6),
                    Text(items[i].title ?? '',
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cmsCardText(context, AppColors.textColor))),
                    if ((items[i].featureText ?? '').isNotEmpty)
                      Text(items[i].featureText!,
                        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                        style: FontUtils.primaryFontStyle(fontSize: 9, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// EmailCapture1 — newsletter sign-up on a dark panel.
class EmailCapture1 extends StatelessWidget {
  final Content content;
  const EmailCapture1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 44, width: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.mail_outline, color: Colors.white, size: 22)),
            const SizedBox(height: 12),
            Text(content.layoutTitle ?? '', textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 6),
            if ((content.layoutSubTitle ?? '').isNotEmpty)
              Text(content.layoutSubTitle!, textAlign: TextAlign.center,
                style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
                    child: Text('Enter your email',
                      style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white54)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 42, padding: const EdgeInsets.symmetric(horizontal: 18), alignment: Alignment.center,
                  decoration: BoxDecoration(color: cmsCard(context, Colors.white), borderRadius: BorderRadius.circular(12)),
                  child: Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : 'Subscribe',
                    style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kInk)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
