import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// GiftCardBanner1 — a gift-card promo. A cmsAccent gradient rounded card is
// styled like a gift card: on the left a small "card" graphic tile carrying an
// Icons.card_giftcard mark and a faux "₹500" denomination, on the right a
// layoutTitle (maxLines 2) + layoutSubTitle (maxLines 1) and a solid contrast
// CTA button (layoutRedirectTitle, e.g. "Buy a gift card"). Fixed height ~140.
// The whole card taps through. Distinct from the reward/offer banners: it
// renders an actual gift-card graphic tile with a denomination.
class GiftCardBanner1 extends StatelessWidget {
  final Content content;
  const GiftCardBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Gift the perfect surprise';
    final subtitle = content.layoutSubTitle?.isNotEmpty == true
        ? content.layoutSubTitle!
        : 'Delivered instantly by email';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Buy a gift card';

    final accent = cmsAccent(context, const Color(0xFF127C71));
    final onAccent = cmsOn(accent);
    // CTA must contrast against the accent card.
    final ctaFill = cmsIsLight(accent) ? const Color(0xFF0B0B0B) : Colors.white;
    final ctaText = cmsOn(ctaFill);

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
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent,
                accent.withValues(alpha: 0.80),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Faux gift-card graphic tile with denomination.
              Container(
                width: 96,
                decoration: BoxDecoration(
                  color: onAccent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: onAccent.withValues(alpha: 0.35),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.card_giftcard, size: 26, color: onAccent),
                    Text(
                      '₹500',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: onAccent,
                      ),
                    ),
                    Text(
                      'GIFT CARD',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: onAccent.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: onAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: onAccent.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: redirect,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ctaFill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                ctaLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: ctaText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded,
                                size: 15, color: ctaText),
                          ],
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
