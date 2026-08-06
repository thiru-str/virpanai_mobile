import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomChecklistCard1 — a "What's included / Benefits" checklist card of
// CUSTOM content (distinct from the comparison table). A single cmsCard rounded
// card with a heading and ONE vertical list of rows, each a check_circle
// (accent) icon + benefit text (title, maxLines 2). No columns, no cross/other
// side. Editorial — NOT products.
class CustomChecklistCard1 extends StatelessWidget {
  final Content content;
  const CustomChecklistCard1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final accent = cmsAccent(context, AppColors.primary);
    final textColor = cmsCardText(context, AppColors.textColor);

    final rows = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i != 0) rows.add(const SizedBox(height: 14));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, size: 22, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  items[i].title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
            ),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: cmsCard(context, Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
        ],
      ),
    );
  }
}
