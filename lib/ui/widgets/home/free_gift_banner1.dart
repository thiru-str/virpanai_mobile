import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// FreeGiftBanner1 — a "Free Gift With Purchase" strip. Left: a redeem accent
// badge (Icons.redeem) + layoutTitle (maxLines 2) + a layoutSubTitle threshold
// line (e.g. "On orders above Rs 1999", maxLines 1). Right: a small gift/product
// thumbnail (first item's image, else an Icons.card_giftcard fallback tile).
// Sits on a cmsPanel card. Fixed height 120. The whole strip taps through.
class FreeGiftBanner1 extends StatelessWidget {
  final Content content;
  const FreeGiftBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final title = content.layoutTitle ?? '';
    final subtitle = content.layoutSubTitle ?? '';

    final panel = cmsPanel(context, const Color(0xFF1F2430));
    final onPanel = cmsText(context, Colors.white);
    final accent = cmsAccent(context, const Color(0xFFE0A458));
    final onAccent = cmsOn(accent);

    final thumb = items.isNotEmpty ? merchImage(items.first) : '';

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: items.isNotEmpty ? items.first : LayoutDatum(),
        ),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gift accent badge.
              Container(
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.redeem, size: 24, color: onAccent),
              ),
              const SizedBox(width: 12),
              // Title + threshold line.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title.isNotEmpty ? title : 'Free gift with purchase',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: onPanel,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: onPanel.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Gift/product thumbnail.
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 72,
                  width: 72,
                  child: thumb.isEmpty
                      ? Container(
                          color: accent.withValues(alpha: 0.20),
                          alignment: Alignment.center,
                          child: Icon(Icons.card_giftcard,
                              size: 32, color: accent),
                        )
                      : merchImageOrFallback(thumb, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
