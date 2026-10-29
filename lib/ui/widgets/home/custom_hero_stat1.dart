import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomHeroStat1 — a SINGLE giant hero stat of CUSTOM content (distinct from
// the multi-cell stat band). On a cmsPanel band: an optional small icon, then
// ONE very large bold number (layoutTitle, else the first item title — e.g.
// "1,00,000+") centred, with a supporting caption below (layoutSubTitle, else
// the first item featureText/subTitle, maxLines 2). No scroll. Editorial —
// NOT products.
class CustomHeroStat1 extends StatelessWidget {
  final Content content;
  const CustomHeroStat1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final first = items.isNotEmpty ? items.first : null;

    final number = (content.layoutTitle ?? '').trim().isNotEmpty
        ? content.layoutTitle!.trim()
        : (first?.title ?? '').trim();
    if (number.isEmpty) return const SizedBox.shrink();

    final caption = (content.layoutSubTitle ?? '').trim().isNotEmpty
        ? content.layoutSubTitle!.trim()
        : (first != null ? merchSubtitle(first) : '');

    final numberColor = cmsText(context, Colors.white);
    final captionColor = numberColor.withValues(alpha: 0.82);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: cmsPanel(context, AppColors.secondary),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 28,
              color: cmsAccent(context, AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              number,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: numberColor,
              ),
            ),
            if (caption.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: captionColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
