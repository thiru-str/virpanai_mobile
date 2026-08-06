import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryWidePillRail1 — a single horizontal rail of WIDE image-pill category
// chips. Each pill is a rounded cmsCard capsule holding a small circular thumb
// (ClipOval) and the category label side by side. Distinct from the plain
// text pill WRAP by the leading image thumb and the horizontal scroll (rather
// than a multi-line wrap).
class CategoryWidePillRail1 extends StatelessWidget {
  final Content content;
  const CategoryWidePillRail1({super.key, required this.content});

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
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                    padding: const EdgeInsets.fromLTRB(6, 6, 18, 6),
                    decoration: BoxDecoration(
                      color: cmsCard(context, Colors.white),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 34,
                            height: 34,
                            child: merchImageOrFallback(
                              merchImage(item),
                              width: 34,
                              height: 34,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cmsCardText(context, AppColors.textColor),
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
