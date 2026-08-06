import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// VideoHeroBanner1 — a cinematic full-bleed hero using the banner image behind
// a dark scrim, with a centered translucent circular Play button and centered
// eyebrow + headline + CTA. Purely static presentation — there is no real
// video playback. Whole banner → redirect.
class VideoHeroBanner1 extends StatelessWidget {
  final Content content;
  const VideoHeroBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Shop now';

    void onTap() => RedirectUtils.handleContentRedirect(
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
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 268,
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
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 62,
                          width: 62,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.22),
                            border:
                                Border.all(color: Colors.white.withValues(alpha: 0.7),
                                    width: 2),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if ((content.layoutSubTitle ?? '').isNotEmpty)
                          Text(
                            content.layoutSubTitle!.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          content.layoutTitle ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 11),
                          decoration: BoxDecoration(
                            color: cmsCard(context, Colors.white),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ctaLabel,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: cmsCardText(
                                      context, const Color(0xFF0B0B0B)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: cmsCardText(
                                    context, const Color(0xFF0B0B0B)),
                              ),
                            ],
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
