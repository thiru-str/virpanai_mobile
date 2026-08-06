import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// SpinWheelBanner1 — a gamified "Spin to Win" banner. A cmsAccent gradient
// rounded card carries a left circular wheel graphic (a segmented disc with a
// casino icon, ~72 dia), a headline (layoutTitle, e.g. "Spin to win up to 40%
// off", maxLines 2), a supporting line (layoutSubTitle, maxLines 1) and a solid
// contrasting CTA button (layoutRedirectTitle, e.g. "Spin now"). No per-item
// images needed. The CTA and the whole card tap through. Fixed height ~130.
class SpinWheelBanner1 extends StatelessWidget {
  final Content content;
  const SpinWheelBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Spin to win up to 40% off';
    final subtitle = content.layoutSubTitle?.isNotEmpty == true
        ? content.layoutSubTitle!
        : 'One free spin every day';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Spin now';

    final accent = cmsAccent(context, const Color(0xFFEF3E6D));
    final onAccent = cmsOn(accent);
    // The CTA sits on the accent card, so it must contrast against it.
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
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent,
                accent.withValues(alpha: 0.78),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Segmented wheel disc.
              Container(
                height: 72,
                width: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: onAccent.withValues(alpha: 0.16),
                  border: Border.all(
                    color: onAccent.withValues(alpha: 0.55),
                    width: 3,
                  ),
                  gradient: SweepGradient(
                    colors: [
                      onAccent.withValues(alpha: 0.10),
                      onAccent.withValues(alpha: 0.32),
                      onAccent.withValues(alpha: 0.10),
                      onAccent.withValues(alpha: 0.32),
                      onAccent.withValues(alpha: 0.10),
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
                child: Icon(Icons.casino, size: 34, color: onAccent),
              ),
              const SizedBox(width: 16),
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
                        fontWeight: FontWeight.w900,
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
                        color: onAccent.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: redirect,
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ctaFill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 15, color: ctaText),
                            const SizedBox(width: 5),
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
