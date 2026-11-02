import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// CustomPromoTicker1 — a SLIM single-line announcement / ticker bar of CUSTOM
// content (NO section header). A full-width cmsAccent band (~44h) with a leading
// campaign icon, the announcement text (layoutTitle, else the first item title;
// maxLines 1, Expanded) and a trailing small CTA + chevron
// (layoutRedirectTitle). The whole bar taps through. Compact and distinct from
// any card. Editorial — NOT products.
class CustomPromoTicker1 extends StatelessWidget {
  final Content content;
  const CustomPromoTicker1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final announcement = (content.layoutTitle ?? '').trim().isNotEmpty
        ? content.layoutTitle!.trim()
        : (items.isNotEmpty ? (items.first.title ?? '').trim() : '');
    if (announcement.isEmpty) return const SizedBox.shrink();

    final accent = cmsAccent(context, AppColors.primary);
    final onAccent = cmsOn(accent);
    final cta = (content.layoutRedirectTitle ?? '').trim();

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: items.isNotEmpty ? items.first : LayoutDatum(),
        ),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.campaign, size: 20, color: onAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  announcement,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: onAccent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (cta.isNotEmpty) ...[
                Text(
                  cta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: onAccent,
                  ),
                ),
                const SizedBox(width: 2),
              ],
              Icon(Icons.chevron_right, size: 20, color: onAccent),
            ],
          ),
        ),
      ),
    );
  }
}
