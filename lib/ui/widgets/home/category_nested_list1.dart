import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryNestedList1 — a vertical list where each row is a parent category
// (image thumb + title + chevron) with a horizontal wrap of 3–4 small
// sub-category chips beneath it. The chips are derived presentationally from
// nearby item titles; tapping anywhere in a row navigates to the parent item.
// Categories only — no prices/ratings/cart.
class CategoryNestedList1 extends StatelessWidget {
  final Content content;
  const CategoryNestedList1({super.key, required this.content});

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
            separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Colors.black12),
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              // Derive presentational sub-category chips from other item titles.
              final chips = <String>[];
              for (var k = 1; k <= 4 && chips.length < 4; k++) {
                final t = items[(i + k) % items.length].title;
                if (t != null && t.trim().isNotEmpty) chips.add(t.trim());
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 56,
                            width: 56,
                            color: cmsCard(context, AppColors.secondary),
                            child: merchImageOrFallback(
                              merchImage(item),
                              width: 56,
                              height: 56,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: cmsCardText(context, AppColors.textColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: cmsCardText(context, AppColors.textColor50),
                        ),
                      ],
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 68),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: chips
                              .map(
                                (c) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: cmsCard(context, Colors.white),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Text(
                                    c,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FontUtils.primaryFontStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: cmsCardText(
                                          context, AppColors.textColor),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
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
