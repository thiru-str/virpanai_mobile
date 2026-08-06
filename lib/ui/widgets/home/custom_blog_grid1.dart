import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomBlogGrid1 — a 2-column grid of CUSTOM blog/article cards: a rounded top
// image, a small "ARTICLE" kicker chip, the title, and a "Read ›" line.
// Editorial content for magazine/journal sections — NOT products: no prices,
// ratings or cart.
class CustomBlogGrid1 extends StatelessWidget {
  final Content content;
  const CustomBlogGrid1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((content.layoutTitle ?? '').isNotEmpty ||
              (content.layoutSubTitle ?? '').isNotEmpty) ...[
            HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
              ctaText: content.layoutRedirectTitle ?? '',
              onTap: () => RedirectUtils.handleContentRedirect(
                context: context,
                layoutOption: content.layoutOption ?? '',
                layoutData: items.first,
              ),
            ),
            const SizedBox(height: 14),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 250,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cmsCard(context, Colors.white),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: merchImageOrFallback(
                          merchImage(item),
                          width: double.infinity,
                          height: 120,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cmsAccent(context, AppColors.primary)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'ARTICLE',
                                  style: FontUtils.primaryFontStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color:
                                        cmsAccent(context, AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.title ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      cmsCardText(context, AppColors.textColor),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Read',
                                    style: FontUtils.primaryFontStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: cmsAccent(
                                          context, AppColors.textColor),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color:
                                        cmsAccent(context, AppColors.textColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
