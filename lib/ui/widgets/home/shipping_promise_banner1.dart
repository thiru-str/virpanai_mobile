import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// ShippingPromiseBanner1 — a single delivery-promise banner: a cmsPanel card
// with a left truck accent badge, a bold delivery headline (layoutTitle, up to
// 2 lines), a supporting sub-line (layoutSubTitle, 1 line), and a right faux
// "Enter pincode" capsule chip (layoutRedirectTitle). The whole card taps
// through via the component's layout option/data. Distinct from the 3-icon
// trust strip (single delivery focus, one badge + headline + pincode chip).
class ShippingPromiseBanner1 extends StatelessWidget {
  final Content content;
  const ShippingPromiseBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final panel = cmsPanel(context, const Color(0xFFF1EEFB));
    final accent = cmsAccent(context, const Color(0xFF8E6CEF));
    final textColor = cmsText(context, const Color(0xFF1A1A1A));

    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Free delivery by tomorrow';
    final subtitle = content.layoutSubTitle ?? '';
    final chipLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Enter pincode';

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
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
          height: 96,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.local_shipping, size: 24, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cmsCard(context, Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: accent),
                    const SizedBox(width: 4),
                    Text(
                      chipLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cmsCardText(context, const Color(0xFF1A1A1A)),
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
