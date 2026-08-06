import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomIconFeatureGrid1 — a 2-column GRID of value-prop cells of CUSTOM
// content. Each cell shows a Material icon (cycled from a small set) inside a
// tinted cmsAccent rounded square, a bold title (maxLines 1) and a short
// description (featureText/subTitle, maxLines 2). Distinct from the vertical
// feature LIST: no thumbnails, laid out as a compact 2-up grid. Editorial —
// NOT products: no prices, ratings or cart.
class CustomIconFeatureGrid1 extends StatelessWidget {
  final Content content;
  const CustomIconFeatureGrid1({super.key, required this.content});

  static const List<IconData> _icons = [
    Icons.local_shipping_outlined,
    Icons.verified_outlined,
    Icons.autorenew_rounded,
    Icons.support_agent_outlined,
    Icons.lock_outline,
    Icons.eco_outlined,
    Icons.favorite_border,
    Icons.workspace_premium_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final accent = cmsAccent(context, AppColors.primary);

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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 136,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              final description = merchSubtitle(item);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cmsCard(context, Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _icons[i % _icons.length],
                          size: 22,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 11.5,
                            color: cmsCardText(context, AppColors.textColor50),
                          ),
                        ),
                      ],
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
