import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';

// CustomImageQuoteCard1 — a full-bleed BACKGROUND-IMAGE quote card of CUSTOM
// content. A fixed ~220-tall image (the first item's image, falling back to
// layoutBannerImage) under a dark scrim, with a centered tagline overlaid: a
// big headline (layoutTitle, white, maxLines 3), a supporting line
// (layoutSubTitle, white, maxLines 2) and an optional pill CTA
// (layoutRedirectTitle). White-on-scrim is a deliberate legibility choice.
// Distinct from the image-less quote banner and the split brand story. Taps
// through. Editorial — NOT a product tile.
class CustomImageQuoteCard1 extends StatelessWidget {
  final Content content;
  const CustomImageQuoteCard1({super.key, required this.content});

  static const double _imageHeight = 220;

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final LayoutDatum? first = items.isNotEmpty ? items.first : null;

    final heading = (content.layoutTitle ?? '').trim();
    final subLine = (content.layoutSubTitle ?? '').trim();
    if (heading.isEmpty && subLine.isEmpty) return const SizedBox.shrink();

    final image = first != null && merchImage(first).isNotEmpty
        ? merchImage(first)
        : (content.layoutBannerImage ?? '');

    final ctaText = (content.layoutRedirectTitle ?? '').trim();

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: _imageHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                merchImageOrFallback(
                  image,
                  width: double.infinity,
                  height: _imageHeight,
                ),
                DecoratedBox(
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (heading.isNotEmpty)
                        Text(
                          heading,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ).copyWith(height: 1.2),
                        ),
                      if (subLine.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          subLine,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 13.5,
                            color: Colors.white.withValues(alpha: 0.9),
                          ).copyWith(height: 1.35),
                        ),
                      ],
                      if (ctaText.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 11),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            ctaText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: const Color(0xFF0B0B0B),
                            ),
                          ),
                        ),
                      ],
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
