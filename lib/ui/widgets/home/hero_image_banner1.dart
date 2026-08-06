import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// HeroImageBanner1 — a tall full-bleed hero: background image + dark bottom
// scrim + eyebrow + big headline + white pill CTA, all bottom-left. The whole
// banner is tappable and redirects via the component's layout option/data.
class HeroImageBanner1 extends StatelessWidget {
  final Content content;
  const HeroImageBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
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
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
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
                          Colors.black.withValues(alpha: 0.62),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((content.layoutSubTitle ?? '').isNotEmpty) ...[
                        Text(
                          content.layoutSubTitle!.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        content.layoutTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cmsCard(context, Colors.white),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          ctaLabel,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: cmsCardText(context, const Color(0xFF0B0B0B)),
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
      ),
    );
  }
}
