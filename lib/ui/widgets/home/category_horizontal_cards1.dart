import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryHorizontalCards1 — a horizontally scrolling rail of medium category
// cards. Each card has a rounded top image (height ~110) sitting above a
// cmsCard body carrying the title and an "Explore" caption. Distinct from the
// vertical grids/lists and from the circle/pill rails: fixed-width solid cards.
class CategoryHorizontalCards1 extends StatelessWidget {
  final Content content;
  const CategoryHorizontalCards1({super.key, required this.content});

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
          if ((content.layoutTitle ?? '').isNotEmpty) ...[
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
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 185,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final item = items[i];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: item,
                  ),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: cmsCard(context, Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Container(
                            height: 110,
                            width: double.infinity,
                            color: cmsCard(context, AppColors.secondary),
                            child: merchImageOrFallback(
                              merchImage(item),
                              width: double.infinity,
                              height: 110,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: cmsCardText(context, AppColors.textColor),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Explore',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      cmsCardText(context, AppColors.textColor50),
                                ),
                              ),
                            ],
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
