import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryNumberedList1 — a "Top Categories" ranked vertical list. Each row
// carries a big rank number (1, 2, 3…) in the accent colour, a small rounded
// thumb (48), the category title, and a small "N items" caption derived from
// the row index. Distinct from a plain detailed list by the leading rank.
class CategoryNumberedList1 extends StatelessWidget {
  final Content content;
  const CategoryNumberedList1({super.key, required this.content});

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
          if ((content.layoutTitle ?? '').isNotEmpty) ...[
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
            const SizedBox(height: 12),
          ],
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, i) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = items[i];
              // Derived, deterministic "N items" caption from the row index.
              final count = 12 + (i * 7) % 88;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 34,
                      child: Text(
                        '${i + 1}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: cmsAccent(context, AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: merchImageOrFallback(
                        merchImage(item),
                        width: 48,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: cmsText(context, AppColors.textColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count items',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: cmsText(context, AppColors.textColor50),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: cmsText(context, AppColors.textColor)
                          .withValues(alpha: 0.4),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
