import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomComparisonTable1 — a simple 3-column "Us vs Others" feature comparison
// table of CUSTOM content. A header row (blank / "Us" / "Others"), then one row
// per layoutData item where the row label is the item title and the two cells
// show a check (accent) for "Us" and a muted cross for "Others". Rows are
// vertically centred and the label wraps to 2 lines. Editorial — NOT products.
class CustomComparisonTable1 extends StatelessWidget {
  final Content content;
  const CustomComparisonTable1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final accent = cmsAccent(context, AppColors.primary);
    final labelColor = cmsCardText(context, AppColors.textColor);
    final mutedColor = cmsCardText(context, AppColors.textColor50);
    final dividerColor = mutedColor.withValues(alpha: 0.2);

    final usLabel = (content.layoutRedirectTitle ?? '').trim().isNotEmpty
        ? content.layoutRedirectTitle!.trim()
        : 'Us';

    Widget headerCell(String text, {required bool emphasise}) => Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: FontUtils.primaryFontStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: emphasise ? accent : mutedColor,
          ),
        );

    final rows = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(flex: 5, child: SizedBox.shrink()),
            Expanded(flex: 2, child: headerCell(usLabel, emphasise: true)),
            Expanded(
                flex: 2, child: headerCell('Others', emphasise: false)),
          ],
        ),
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      rows.add(Container(height: 1, color: dividerColor));
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  items[i].title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Icon(Icons.check_circle, size: 22, color: accent),
              ),
              Expanded(
                flex: 2,
                child: Icon(Icons.cancel, size: 22, color: dividerColor),
              ),
            ],
          ),
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
              onTap: () => RedirectUtils.handleContentRedirect(
                context: context,
                layoutOption: content.layoutOption ?? '',
                layoutData: items.first,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cmsCard(context, Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: rows,
            ),
          ),
        ],
      ),
    );
  }
}
