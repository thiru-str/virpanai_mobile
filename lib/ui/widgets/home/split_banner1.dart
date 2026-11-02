import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// SplitBanner1 — a rounded 50/50 Row: left half is an image panel (the layout
// banner image, or the first item's image), right half is a coloured cmsCard/
// cmsPanel with eyebrow + headline + CTA pill. Whole banner is tappable.
class SplitBanner1 extends StatelessWidget {
  final Content content;
  const SplitBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final firstItem = items.isNotEmpty ? items.first : null;
    final image = (content.layoutBannerImage?.isNotEmpty == true)
        ? content.layoutBannerImage!
        : (firstItem != null ? merchImage(firstItem) : '');
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Shop now';

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: firstItem ?? LayoutDatum(),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: merchImageOrFallback(image, fit: BoxFit.cover),
                ),
                Expanded(
                  child: Container(
                    color: cmsPanel(context, const Color(0xFF111111)),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if ((content.layoutSubTitle ?? '').isNotEmpty) ...[
                          Text(
                            content.layoutSubTitle!.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: cmsText(context, Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          content.layoutTitle ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: cmsText(context, Colors.white),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cmsCard(context, Colors.white),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ctaLabel,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: cmsCardText(context, AppColors.textColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
