import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryFlatIconCards1 — a horizontal rail of FLAT icon+label cards with NO
// network image. Each card is a rounded cmsCard (~120 wide) holding a Material
// icon (cycled from a list) inside a tinted cmsAccent circle, with the category
// label below. Distinct from the image-based horizontal category cards — this
// is a lightweight, icon-only rail.
class CategoryFlatIconCards1 extends StatelessWidget {
  final Content content;
  const CategoryFlatIconCards1({super.key, required this.content});

  static const _icons = [
    Icons.category_rounded,
    Icons.local_offer_rounded,
    Icons.storefront_rounded,
    Icons.auto_awesome_rounded,
    Icons.favorite_rounded,
    Icons.bolt_rounded,
    Icons.shopping_bag_rounded,
    Icons.diamond_rounded,
  ];

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
            height: 120,
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
                    width: 120,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cmsCard(context, Colors.white),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: cmsAccent(context, AppColors.primary)
                                .withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _icons[i % _icons.length],
                            size: 24,
                            color: cmsAccent(context, AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
