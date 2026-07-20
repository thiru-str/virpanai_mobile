import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

// BrandWall1 — shop-by-brand logo grid.
class BrandWall1 extends StatelessWidget {
  final Content content;
  const BrandWall1({super.key, required this.content});
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
          HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: items.length > 6 ? 6 : items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 72),
            itemBuilder: (context, i) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kInk.withOpacity(0.08))),
              child: Text(items[i].title ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textColor50)),
            ),
          ),
        ],
      ),
    );
  }
}

// FaqList1 — frequently-asked-questions list (first expanded).
class FaqList1 extends StatelessWidget {
  final Content content;
  const FaqList1({super.key, required this.content});
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
          HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
          const SizedBox(height: 12),
          for (int i = 0; i < (items.length > 4 ? 4 : items.length); i++) ...[
            if (i != 0) const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kInk.withOpacity(0.08))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(items[i].title ?? '',
                          style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor))),
                      Icon(i == 0 ? Icons.remove : Icons.add, size: 18, color: AppColors.textColor),
                    ],
                  ),
                  if (i == 0 && (items[i].featureText ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(items[i].featureText!,
                      style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
