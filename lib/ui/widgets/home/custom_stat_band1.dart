import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomStatBand1 — a stats / social-proof band of CUSTOM content. A single Row
// of up to 4 Expanded stat cells on a cmsPanel band; each cell shows a big bold
// number (title, e.g. "10k+" / "4.9★") over a small centered caption
// (featureText/subTitle, maxLines 2), separated by vertical hairline dividers.
// No images, no scroll. Editorial — NOT products.
class CustomStatBand1 extends StatelessWidget {
  final Content content;
  const CustomStatBand1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final all = content.layoutData ?? [];
    if (all.isEmpty) return const SizedBox.shrink();
    final items = all.length > 4 ? all.sublist(0, 4) : all;

    final numberColor = cmsCardText(context, AppColors.textColor);
    final captionColor = cmsCardText(context, AppColors.textColor50);

    final cells = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final caption = merchSubtitle(item);
      cells.add(
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: FontUtils.primaryFontStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: numberColor,
                ),
              ),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 11,
                    color: captionColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
      if (i != items.length - 1) {
        cells.add(
          Container(
            width: 1,
            height: 40,
            color: captionColor.withValues(alpha: 0.25),
          ),
        );
      }
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
            const SizedBox(height: 14),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            decoration: BoxDecoration(
              color: cmsPanel(context, AppColors.secondary),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: cells,
            ),
          ),
        ],
      ),
    );
  }
}
