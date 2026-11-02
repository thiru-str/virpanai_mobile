import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomEditorialCta1 — a large CENTERED, text-forward CTA block of CUSTOM
// content (no image). A small kicker chip (layoutSubTitle), a big centered
// heading (layoutTitle, maxLines 3), a centered supporting paragraph (the
// first item's featureText/subTitle, maxLines 3) and a solid cmsAccent CTA
// button (layoutRedirectTitle). Generous vertical padding on a cmsPanel band.
// The whole block taps through. Editorial — NOT a product tile.
class CustomEditorialCta1 extends StatelessWidget {
  final Content content;
  const CustomEditorialCta1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final LayoutDatum? first = items.isNotEmpty ? items.first : null;

    final kicker = (content.layoutSubTitle ?? '').trim();
    final heading = (content.layoutTitle ?? '').trim();
    final paragraph = first != null ? merchSubtitle(first) : '';
    if (heading.isEmpty && paragraph.isEmpty) return const SizedBox.shrink();

    final ctaText = (content.layoutRedirectTitle ?? '').trim().isNotEmpty
        ? content.layoutRedirectTitle!.trim()
        : 'Explore now';

    final accent = cmsAccent(context, AppColors.primary);
    final onPanel = cmsText(context, Colors.white);

    void redirect() => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: first ?? LayoutDatum(),
        );

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: redirect,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: cmsPanel(context, const Color(0xFF1F1B2E)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (kicker.isNotEmpty) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    kicker,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (heading.isNotEmpty)
                Text(
                  heading,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: onPanel,
                  ).copyWith(height: 1.2),
                ),
              if (paragraph.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  paragraph,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 14,
                    color: onPanel.withValues(alpha: 0.78),
                  ).copyWith(height: 1.4),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: redirect,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: accent,
                  foregroundColor: cmsOn(accent),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  ctaText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: cmsOn(accent),
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
