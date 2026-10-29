import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomQuoteBanner1 — a single centered pull-quote / mission statement card of
// CUSTOM content. Shows a large decorative quote glyph, the quote body (from the
// first item's featureText/subTitle, falling back to layoutSubTitle) centered in
// a larger font (maxLines 4), and an attribution/brand line (item title, falling
// back to layoutTitle). Sits on a cmsPanel background with generous padding.
// Distinct from the testimonial RAIL: one static, centered statement — not a
// scrollable list of cards. Editorial — NOT products.
class CustomQuoteBanner1 extends StatelessWidget {
  final Content content;
  const CustomQuoteBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final first = items.isNotEmpty ? items.first : null;

    final quote = first != null && merchSubtitle(first).isNotEmpty
        ? merchSubtitle(first)
        : (content.layoutSubTitle ?? '');
    final attribution = (first?.title ?? '').trim().isNotEmpty
        ? first!.title!.trim()
        : (content.layoutTitle ?? '');

    if (quote.trim().isEmpty && attribution.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final onPanel = cmsText(context, Colors.white);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: first == null
            ? null
            : () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: first,
                ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: cmsPanel(context, const Color(0xFF1F1B2E)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '“',
                textAlign: TextAlign.center,
                style: FontUtils.primaryFontStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: cmsAccent(context, AppColors.primary),
                ),
              ),
              if (quote.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  quote.trim(),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: onPanel.withValues(alpha: 0.92),
                  ),
                ),
              ],
              if (attribution.trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  attribution.trim(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: onPanel.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
