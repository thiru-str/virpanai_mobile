import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// PromoStripBanner1 — a SLIM full-width announcement strip: a small leading
// badge icon, an inline headline + subtitle on the left, and a pill CTA on the
// right. Honours the merchant's layout background when set, else falls back to
// a soft accent surface (cmsPanel). The whole strip is tappable and redirects.
class PromoStripBanner1 extends StatelessWidget {
  final Content content;
  const PromoStripBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // Honour a merchant-set layout background; else fall back to a soft accent
    // surface so the strip always reads as a distinct announcement.
    final merchantBg = AppUtils.buildLayoutBackground(content);
    final hasMerchantBg = merchantBg != null &&
        (merchantBg.color != null ||
            merchantBg.gradient != null ||
            merchantBg.image != null);
    final decoration = hasMerchantBg
        ? merchantBg.copyWith(borderRadius: BorderRadius.circular(14))
        : BoxDecoration(
            color: cmsPanel(context, const Color(0xFFF1EEFB)),
            borderRadius: BorderRadius.circular(14),
          );

    final title = content.layoutTitle ?? '';
    final subtitle = content.layoutSubTitle ?? '';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Shop now';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        ),
        child: Container(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 34,
                width: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cmsAccent(context, const Color(0xFF8E6CEF)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  size: 18,
                  color: cmsOn(cmsAccent(context, const Color(0xFF8E6CEF))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: cmsText(context, const Color(0xFF1A1A1A)),
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: cmsText(context, const Color(0xFF1A1A1A))
                              .withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cmsAccent(context, const Color(0xFF8E6CEF)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  ctaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: cmsOn(cmsAccent(context, const Color(0xFF8E6CEF))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
