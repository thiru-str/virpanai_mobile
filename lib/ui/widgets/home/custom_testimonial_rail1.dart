import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomTestimonialRail1 — a horizontal rail of CUSTOM testimonial/quote cards.
// Each card shows a large quote glyph, the featureText/subTitle as the quote
// body, and the title as an attributed name plus a small 5-star row. Editorial
// social-proof content — NOT products: no prices, images or cart.
class CustomTestimonialRail1 extends StatelessWidget {
  final Content content;
  const CustomTestimonialRail1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((content.layoutTitle ?? '').isNotEmpty ||
              (content.layoutSubTitle ?? '').isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HomeMerchSectionHeader(
                title: content.layoutTitle ?? '',
                subtitle: content.layoutSubTitle ?? '',
                ctaText: content.layoutRedirectTitle ?? '',
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: items.first,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final item = items[index];
                final quote = merchSubtitle(item);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: item,
                  ),
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                    decoration: BoxDecoration(
                      color: cmsPanel(context, const Color(0xFF1F1B2E)),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '“',
                          style: FontUtils.primaryFontStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: cmsText(context, Colors.white)
                                .withValues(alpha: 0.65),
                          ),
                        ),
                        if (quote.isNotEmpty)
                          Expanded(
                            child: Text(
                              quote,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 13,
                                color: cmsText(context, Colors.white)
                                    .withValues(alpha: 0.88),
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        const SizedBox(height: 10),
                        Text(
                          item.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cmsText(context, Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (_) => Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: cmsAccent(context, AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
