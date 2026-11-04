import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// ReferralBanner1 — a refer-a-friend reward banner. A rounded panel (cmsPanel,
// with a soft gradient sheen) carries a gift accent icon, a headline
// (layoutTitle, e.g. "Refer a friend, get Rs 200", maxLines 2), a supporting
// line (layoutSubTitle, maxLines 2) and a solid cmsAccent CTA button
// (layoutRedirectTitle, e.g. "Invite now"). No per-item images needed. The CTA
// and the whole panel tap through.
class ReferralBanner1 extends StatelessWidget {
  final Content content;
  const ReferralBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Refer a friend, get rewarded';
    final subtitle = content.layoutSubTitle?.isNotEmpty == true
        ? content.layoutSubTitle!
        : 'Share your code and you both earn.';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Invite now';

    final panel = cmsPanel(context, const Color(0xFF2B1E5A));
    final onPanel = cmsText(context, Colors.white);
    final accent = cmsAccent(context, const Color(0xFFFFC53D));
    final onAccent = cmsOn(accent);

    void redirect() => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        );

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: redirect,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                panel,
                panel.withValues(alpha: 0.82),
              ],
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.card_giftcard, size: 30, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: onPanel,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: onPanel.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: redirect,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ctaLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: onAccent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded,
                                size: 16, color: onAccent),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
