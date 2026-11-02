import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// AppDownloadBanner1 — a rounded promo card inviting the user to get the app.
// Left column: layoutTitle (maxLines 2), layoutSubTitle (maxLines 2), and two
// small store pill buttons ("App Store" / "Google Play"). Right: a phone-ish
// hero image (layoutBannerImage, else fallback) in a fixed ~110x120 box. Row
// uses CrossAxisAlignment.center. The whole card taps through and redirects.
class AppDownloadBanner1 extends StatelessWidget {
  final Content content;
  const AppDownloadBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Get the app';
    final subtitle = content.layoutSubTitle ?? '';

    void onTap() => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        );

    final panel = cmsPanel(context, const Color(0xFF1A0B2E));
    final onPanel = cmsText(context, Colors.white);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: onPanel,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: onPanel.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _StorePill(
                            icon: Icons.apple,
                            label: 'App Store',
                            onPanel: onPanel,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StorePill(
                            icon: Icons.shop,
                            label: 'Google Play',
                            onPanel: onPanel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 120,
                  width: 98,
                  child: merchImageOrFallback(
                    content.layoutBannerImage ?? '',
                    fit: BoxFit.cover,
                    height: 120,
                    width: 98,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color onPanel;
  const _StorePill({
    required this.icon,
    required this.label,
    required this.onPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: onPanel.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: onPanel.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: onPanel),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: onPanel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
