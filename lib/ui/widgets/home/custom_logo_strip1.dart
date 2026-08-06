import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomLogoStrip1 — an "As seen in / Trusted by" strip of CUSTOM content:
// a section header over a horizontal Wrap of brand chips. Each chip is a
// cmsPanel rounded capsule showing a brand name (item title, maxLines 1) in a
// muted style. Purely presentational; chips may tap through. No images
// required. Editorial — NOT products.
class CustomLogoStrip1 extends StatelessWidget {
  final Content content;
  const CustomLogoStrip1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final chipTextColor = cmsCardText(context, AppColors.textColor50);

    final chips = <Widget>[];
    for (final item in items) {
      final name = (item.title ?? '').trim();
      if (name.isEmpty) continue;
      chips.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => RedirectUtils.handleContentRedirect(
            context: context,
            layoutOption: content.layoutOption ?? '',
            layoutData: item,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cmsPanel(context, AppColors.secondary),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: chipTextColor,
              ),
            ),
          ),
        ),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();

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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: chips,
          ),
        ],
      ),
    );
  }
}
