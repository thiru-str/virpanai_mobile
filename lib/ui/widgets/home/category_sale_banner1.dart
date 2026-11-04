import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategorySaleBanner1 — a category-targeted sale banner: a wide rounded image
// (layoutBannerImage, else the first item's image) with a LEFT-aligned dark
// scrim so the text sits on the shaded side. Overlaid, left-aligned:
// layoutTitle (e.g. "Up to 50% Off Sarees", maxLines 2), a layoutSubTitle line,
// and a solid CTA button. Fixed height 170. The whole banner taps through.
class CategorySaleBanner1 extends StatelessWidget {
  final Content content;
  const CategorySaleBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final title = content.layoutTitle ?? '';
    final subtitle = content.layoutSubTitle ?? '';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Shop the sale';

    final image = (content.layoutBannerImage?.isNotEmpty == true)
        ? content.layoutBannerImage!
        : (items.isNotEmpty ? merchImage(items.first) : '');

    final accent = cmsAccent(context, const Color(0xFFC2185B));
    final onAccent = cmsOn(accent);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: items.isNotEmpty ? items.first : LayoutDatum(),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 170,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: merchImageOrFallback(image, fit: BoxFit.cover),
                ),
                // Left-aligned dark scrim: strong on the left, fading right.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.72),
                          Colors.black.withValues(alpha: 0.30),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 16,
                  bottom: 16,
                  right: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
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
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded,
                                size: 15, color: onAccent),
                          ],
                        ),
                      ),
                    ],
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
