import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// CustomNewsletterSignup1 — an email-capture CARD of CUSTOM content (NOT a
// product tile, no images required). A rounded cmsPanel card carries a headline
// (layoutTitle, maxLines 2), a supporting line (layoutSubTitle, maxLines 2) and
// a FAUX input row: a rounded cmsCard "field" showing hint text "you@email.com"
// with a trailing solid cmsAccent CTA button (layoutRedirectTitle). There is no
// real input logic — tapping the field or the button routes via a content
// redirect so the merchant can send users to a real signup destination.
class CustomNewsletterSignup1 extends StatelessWidget {
  final Content content;
  const CustomNewsletterSignup1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final headline = (content.layoutTitle ?? '').trim();
    final subtitle = (content.layoutSubTitle ?? '').trim();
    if (headline.isEmpty && subtitle.isEmpty) return const SizedBox.shrink();

    final ctaText = (content.layoutRedirectTitle ?? '').trim().isNotEmpty
        ? content.layoutRedirectTitle!.trim()
        : 'Subscribe';

    final panelColor = cmsPanel(context, AppColors.secondary);
    final onPanel = cmsCardText(context, AppColors.textColor);
    final onPanelMuted = cmsCardText(context, AppColors.textColor50);
    final accent = cmsAccent(context, Colors.black);

    void redirect() => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: items.isNotEmpty ? items.first : LayoutDatum(),
        );

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: redirect,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (headline.isNotEmpty)
                Text(
                  headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: onPanel,
                  ),
                ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 13,
                    color: onPanelMuted,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Faux input row — a rounded field + a solid CTA button. No real
              // text input; the whole row routes through a content redirect.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: cmsCard(context, Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mail_outline_rounded,
                            size: 18,
                            color: onPanelMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'you@email.com',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                color: cmsCardText(context, AppColors.textColor50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 48,
                    constraints: const BoxConstraints(maxWidth: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      ctaText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cmsOn(accent),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
