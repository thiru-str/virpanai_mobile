import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomBrandStory1 — a brand-story SPLIT card of CUSTOM content. A single
// editorial cmsCard: a rounded ~150-tall image on top (from the first item, or
// layoutBannerImage), then a heading (layoutTitle), a paragraph (layoutSubTitle
// or the first item's featureText, maxLines 4) and a text CTA "Read our story
// ›" (layoutRedirectTitle). Taps through via a content redirect. NOT a product
// tile — no price, rating or cart.
class CustomBrandStory1 extends StatelessWidget {
  final Content content;
  const CustomBrandStory1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final LayoutDatum? first = items.isNotEmpty ? items.first : null;

    final heading = (content.layoutTitle ?? '').trim();
    final paragraph = (content.layoutSubTitle ?? '').trim().isNotEmpty
        ? content.layoutSubTitle!.trim()
        : (first != null ? merchSubtitle(first) : '');
    if (heading.isEmpty && paragraph.isEmpty) return const SizedBox.shrink();

    final image = first != null && merchImage(first).isNotEmpty
        ? merchImage(first)
        : (content.layoutBannerImage ?? '');

    final ctaText = (content.layoutRedirectTitle ?? '').trim().isNotEmpty
        ? content.layoutRedirectTitle!.trim()
        : 'Read our story';

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
          decoration: BoxDecoration(
            color: cmsCard(context, Colors.white),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image.isNotEmpty)
                merchImageOrFallback(
                  image,
                  width: double.infinity,
                  height: 150,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (heading.isNotEmpty)
                      Text(
                        heading,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: cmsCardText(context, AppColors.textColor),
                        ),
                      ),
                    if (paragraph.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        paragraph,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          color: cmsCardText(context, AppColors.textColor50),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            ctaText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: cmsAccent(context, AppColors.textColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: cmsAccent(context, AppColors.textColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
