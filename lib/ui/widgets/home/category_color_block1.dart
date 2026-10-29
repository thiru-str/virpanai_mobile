import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryColorBlock1 — a 2-column grid of IMAGE-LESS colour-block tiles. Each
// tile is a rounded tinted-accent panel with a leading Material icon (cycled
// from a small list), the category title and a tiny caption. No network images,
// so it stays distinct from every image-based category widget.
class CategoryColorBlock1 extends StatelessWidget {
  final Content content;
  const CategoryColorBlock1({super.key, required this.content});

  static const _tints = [
    Color(0xFFEEF2FF),
    Color(0xFFFEF2F2),
    Color(0xFFECFDF5),
    Color(0xFFFFFBEB),
    Color(0xFFF5F3FF),
    Color(0xFFECFEFF),
  ];

  static const _icons = [
    Icons.category_rounded,
    Icons.local_offer_rounded,
    Icons.storefront_rounded,
    Icons.auto_awesome_rounded,
    Icons.favorite_rounded,
    Icons.bolt_rounded,
  ];

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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 96,
            ),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cmsPanel(context, _tints[i % _tints.length]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: cmsCard(context, Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _icons[i % _icons.length],
                          size: 22,
                          color: cmsAccent(context, AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: cmsText(context, AppColors.textColor),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Browse all',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: cmsText(context, AppColors.textColor50),
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
        ],
      ),
    );
  }
}
