import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// StoreVisitBanner1 — a "Visit our store" banner. Left: a location-pin accent
// badge, the store name (layoutTitle, maxLines 1) and the address
// (layoutSubTitle, maxLines 2). Right: a "Get directions" CTA chip
// (layoutRedirectTitle) beneath a small map-ish tinted tile. A cmsPanel card,
// Row uses CrossAxisAlignment.center. The whole card taps through. Fixed height
// ~104.
class StoreVisitBanner1 extends StatelessWidget {
  final Content content;
  const StoreVisitBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Visit our store';
    final subtitle = content.layoutSubTitle?.isNotEmpty == true
        ? content.layoutSubTitle!
        : 'Find us at your nearest location';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Get directions';

    final panel = cmsPanel(context, const Color(0xFF14314A));
    final onPanel = cmsText(context, Colors.white);
    final accent = cmsAccent(context, const Color(0xFF37B679));
    final onAccent = cmsOn(accent);

    void redirect() => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        );

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: redirect,
        child: Container(
          width: double.infinity,
          height: 104,
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Map-ish tinted tile with a location pin badge.
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.40)),
                ),
                child: Icon(Icons.location_on, size: 30, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: onPanel,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: onPanel.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_rounded, size: 15, color: onAccent),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        ctaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: onAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
