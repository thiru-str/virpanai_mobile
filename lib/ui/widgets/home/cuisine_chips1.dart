import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CuisineChips1 — cuisine / dish-type shortcuts for a food storefront.
class CuisineChips1 extends StatelessWidget {
  final Content content;
  const CuisineChips1({super.key, required this.content});

  static const _icons = [
    Icons.local_pizza, Icons.ramen_dining, Icons.rice_bowl, Icons.cake,
    Icons.lunch_dining, Icons.local_cafe, Icons.set_meal, Icons.icecream,
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
            ),
            const SizedBox(height: 12),
          ],
          GridView.builder(
            itemCount: items.length > 8 ? 8 : items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              mainAxisExtent: 92,
            ),
            itemBuilder: (context, i) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 58, width: 58,
                    decoration: const BoxDecoration(
                      color: Color(0x1AEF6C1A), shape: BoxShape.circle),
                    child: Icon(_icons[i % _icons.length],
                        color: const Color(0xFFEF6C1A), size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].title ?? '',
                    maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: cmsCardText(context, AppColors.textColor)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
