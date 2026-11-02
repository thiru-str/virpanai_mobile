import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// CustomValuePropsRow1 — a COMPACT single horizontal Row of 3–4 mini value
// props of CUSTOM content. Each cell is an Expanded column: a Material icon
// (cycled from a small trust-signal set) above a short 1–2 word label (item
// title, centered, maxLines 2). No descriptions, no thumbnails, no scroll —
// it sits as a single band on a cmsPanel background. Distinct from the icon
// feature GRID (2-up, with descriptions). Editorial — NOT products.
class CustomValuePropsRow1 extends StatelessWidget {
  final Content content;
  const CustomValuePropsRow1({super.key, required this.content});

  static const List<IconData> _icons = [
    Icons.local_shipping_outlined,
    Icons.verified_outlined,
    Icons.autorenew_rounded,
    Icons.support_agent_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final all = content.layoutData ?? [];
    if (all.isEmpty) return const SizedBox.shrink();

    // Compact single row — cap to the first 4 items so nothing overflows.
    final items = all.length > 4 ? all.sublist(0, 4) : all;
    final accent = cmsAccent(context, AppColors.primary);
    final onPanel = cmsText(context, Colors.white);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: cmsPanel(context, const Color(0xFF1F1B2E)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: items[i],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[i % _icons.length],
                        size: 26,
                        color: accent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (items[i].title ?? '').trim(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: onPanel.withValues(alpha: 0.92),
                        ).copyWith(height: 1.15),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
