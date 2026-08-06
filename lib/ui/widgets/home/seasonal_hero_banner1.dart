import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// SeasonalHeroBanner1 — a tall (260px) full-bleed seasonal hero: banner image
// (or fallback) as background, a bottom-to-top dark scrim, a season kicker
// chip at the top-left, and bottom-left stacked layoutTitle (big, maxLines 2)
// + layoutSubTitle (maxLines 2) + a solid rounded CTA button. Taller and
// chip-styled to stay distinct from HeroImageBanner1. Whole hero taps through.
class SeasonalHeroBanner1 extends StatelessWidget {
  final Content content;
  const SeasonalHeroBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle ?? '';
    final subtitle = content.layoutSubTitle ?? '';
    final kicker = content.layoutSubTitle?.isNotEmpty == true
        ? 'Seasonal'
        : 'New season';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Shop the season';

    final accent = cmsAccent(context, const Color(0xFF1E7A5A));
    final onAccent = cmsOn(accent);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: merchImageOrFallback(
                    content.layoutBannerImage ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.70),
                          Colors.black.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                // Season kicker chip, top-left.
                Positioned(
                  left: 18,
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco_rounded, size: 13, color: onAccent),
                        const SizedBox(width: 5),
                        Text(
                          kicker.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: onAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom-left content.
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
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
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(24),
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: onAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded,
                                size: 16, color: onAccent),
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
