import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryCircleRail1 — horizontal rail of circular category avatars, each a
// tappable ~66px circle image with the category label below.
class CategoryCircleRail1 extends StatelessWidget {
  final Content content;
  const CategoryCircleRail1({super.key, required this.content});

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
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final item = items[i];
                return GestureDetector(
                  onTap: () => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: item,
                  ),
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 66,
                          width: 66,
                          decoration: BoxDecoration(
                            color: cmsCard(context, Colors.white),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black12),
                          ),
                          child: ClipOval(
                            child: merchImageOrFallback(
                              merchImage(item),
                              width: 66,
                              height: 66,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
