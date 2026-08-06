import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryScrollStrip1 — a thin horizontal strip of compact rounded chips, each
// with a tiny leading image/dot + label. A lightweight quick-nav rail that sits
// under the section header. Categories only — no prices/ratings/cart.
class CategoryScrollStrip1 extends StatelessWidget {
  final Content content;
  const CategoryScrollStrip1({super.key, required this.content});

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
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final item = items[i];
                final image = merchImage(item);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: item,
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                    decoration: BoxDecoration(
                      color: cmsCard(context, Colors.white),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: Container(
                            height: 32,
                            width: 32,
                            color: cmsCard(context, AppColors.secondary),
                            child: image.isEmpty
                                ? const SizedBox.shrink()
                                : merchImageOrFallback(
                                    image,
                                    width: 32,
                                    height: 32,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 13,
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
