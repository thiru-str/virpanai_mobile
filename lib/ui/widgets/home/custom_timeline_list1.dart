import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomTimelineList1 — a vertical "how it works / steps" list of CUSTOM
// content. Each row has a left numbered circle (1, 2, 3…) joined by a connecting
// vertical line, and to the right the title (bold) plus a featureText/subTitle
// description. No images required. Editorial process content — NOT products.
class CustomTimelineList1 extends StatelessWidget {
  final Content content;
  const CustomTimelineList1({super.key, required this.content});

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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final description = merchSubtitle(item);
              final isLast = index == items.length - 1;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cmsAccent(context, AppColors.primary),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: cmsOn(
                                    cmsAccent(context, AppColors.primary)),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: cmsAccent(context, AppColors.primary)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 4,
                            bottom: isLast ? 0 : 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: cmsText(context, AppColors.textColor),
                                ),
                              ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: FontUtils.primaryFontStyle(
                                    fontSize: 12,
                                    color: cmsText(
                                        context, AppColors.textColor50),
                                  ),
                                ),
                              ],
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
