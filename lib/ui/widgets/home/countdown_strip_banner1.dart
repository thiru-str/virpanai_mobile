import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// CountdownStripBanner1 — a COMPACT full-width horizontal strip on a solid
// accent band. Left: an "SALE ENDS" style label (from layoutTitle, else a
// default) with a row of three small STATIC time boxes (HH / MM / SS shown as
// "12" "45" "30" — never computed live). Right: a rounded CTA chip built from
// layoutRedirectTitle. The whole strip taps through and redirects. Single row,
// ~72px tall. Distinct from CountdownBanner1 (tall dark panel with 4 boxes).
class CountdownStripBanner1 extends StatelessWidget {
  final Content content;
  const CountdownStripBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // Static countdown values — never computed from DateTime / Timer.
    const times = ['12', '45', '30'];

    final label = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'SALE ENDS';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Shop now';

    final band = cmsAccent(context, const Color(0xFF8E6CEF));
    final onBand = cmsOn(band);

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
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: band,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: onBand.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < times.length; i++) ...[
                          _TimeBox(value: times[i], onBand: onBand),
                          if (i != times.length - 1)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: Text(
                                ':',
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: onBand.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cmsCard(context, Colors.white),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  ctaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: cmsCardText(context, const Color(0xFF0B0B0B)),
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

class _TimeBox extends StatelessWidget {
  final String value;
  final Color onBand;
  const _TimeBox({required this.value, required this.onBand});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: onBand.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: onBand.withValues(alpha: 0.25)),
      ),
      child: Text(
        value,
        maxLines: 1,
        style: FontUtils.primaryFontStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: onBand,
        ),
      ),
    );
  }
}
