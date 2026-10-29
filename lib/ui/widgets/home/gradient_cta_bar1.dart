import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// GradientCtaBar1 — a slim, full-width promo bar with a gradient background
// (a vivid indigo→magenta default, or the merchant's layout background if set),
// white headline + subtitle on the left and a pill CTA on the right. The whole
// bar is tappable and redirects.
class GradientCtaBar1 extends StatelessWidget {
  final Content content;
  const GradientCtaBar1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // Honour a merchant-set layout background; else fall back to the default
    // indigo→magenta gradient.
    final merchantBg = AppUtils.buildLayoutBackground(content);
    final hasMerchantBg =
        merchantBg != null && (merchantBg.color != null || merchantBg.gradient != null);
    final decoration = hasMerchantBg
        ? merchantBg.copyWith(borderRadius: BorderRadius.circular(18))
        : BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF4F46E5), Color(0xFFC026D3)],
            ),
          );
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Shop now';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      content.layoutTitle ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if ((content.layoutSubTitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        content.layoutSubTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cmsCard(context, Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ctaLabel,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: cmsCardText(context, const Color(0xFF4F46E5)),
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
