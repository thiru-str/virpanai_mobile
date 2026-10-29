import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// SocialFollowBanner1 — a "Follow us" banner. A cmsPanel card: a layoutTitle
// headline (maxLines 2) + layoutSubTitle (maxLines 1) stacked on top, then a
// Row of fixed-size social icon chips (Instagram / Facebook / YouTube / Chat)
// each in a tinted cmsCard circle, followed by an optional CTA arrow chip.
// Fixed-size circles keep the Row from overflowing. Fixed height ~120. Every
// chip and the whole card tap through. Distinct from the reward/offer banners:
// its focus is a row of social channel chips, not a promo offer.
class SocialFollowBanner1 extends StatelessWidget {
  final Content content;
  const SocialFollowBanner1({super.key, required this.content});

  static const List<IconData> _socialIcons = [
    Icons.camera_alt, // Instagram
    Icons.facebook, // Facebook
    Icons.play_circle, // YouTube
    Icons.chat, // Chat / messaging
  ];

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Follow us for more';
    final subtitle = content.layoutSubTitle?.isNotEmpty == true
        ? content.layoutSubTitle!
        : 'Deals, drops and behind the scenes';
    final ctaLabel = content.layoutRedirectTitle ?? '';

    final panel = cmsPanel(context, const Color(0xFF1F1B2E));
    final onPanel = cmsText(context, Colors.white);
    final accent = cmsAccent(context, const Color(0xFFE04D8C));
    final onAccent = cmsOn(accent);
    final chipBg = cmsCard(context, onPanel.withValues(alpha: 0.12));

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
          height: 120,
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: onPanel,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: onPanel.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final icon in _socialIcons) ...[
                    _SocialChip(
                      icon: icon,
                      background: chipBg,
                      iconColor: onPanel,
                      onTap: redirect,
                    ),
                    const SizedBox(width: 10),
                  ],
                  const Spacer(),
                  if (ctaLabel.isNotEmpty)
                    Flexible(
                      child: GestureDetector(
                        onTap: redirect,
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            ctaLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: onAccent,
                            ),
                          ),
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

class _SocialChip extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  const _SocialChip({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
