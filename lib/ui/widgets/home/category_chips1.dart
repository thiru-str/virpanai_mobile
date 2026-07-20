import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'homepage_merch_shared.dart';
import 'grocery_shared.dart';

// CategoryChips1 — grocery category shortcuts (icon chip + label).
class CategoryChips1 extends StatelessWidget {
  final Content content;
  const CategoryChips1({super.key, required this.content});

  static const _icons = [
    Icons.eco, Icons.set_meal, Icons.egg_alt, Icons.bakery_dining,
    Icons.local_drink, Icons.icecream, Icons.rice_bowl, Icons.cleaning_services,
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
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: kFresh.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icons[i % _icons.length], color: kFresh, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
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
