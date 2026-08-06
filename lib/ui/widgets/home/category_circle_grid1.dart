import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryCircleGrid1 — a 4-column WRAP grid of circular category images, each
// a ~68px ClipOval with a single-line label beneath. Distinct from the
// horizontal circle rail: this wraps onto multiple rows in a fixed grid.
class CategoryCircleGrid1 extends StatelessWidget {
  final Content content;
  const CategoryCircleGrid1({super.key, required this.content});

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
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              mainAxisExtent: 104,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 68,
                      width: 68,
                      decoration: BoxDecoration(
                        color: cmsCard(context, Colors.white),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: ClipOval(
                        child: merchImageOrFallback(
                          merchImage(item),
                          width: 68,
                          height: 68,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
