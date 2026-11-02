import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// CountdownBanner1 — an urgent campaign banner on a dark panel with a subtitle
// pill, a bold headline, a row of four STATIC digit boxes (Days:Hours:Min:Sec)
// separated by ':' with labels beneath, and a prominent CTA. The digits are
// hardcoded — no live time, no Timer, no DateTime.now. Whole banner → redirect.
class CountdownBanner1 extends StatelessWidget {
  final Content content;
  const CountdownBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // Static countdown values — never computed live.
    const digits = ['02', '14', '37', '05'];
    const labels = ['DAYS', 'HRS', 'MIN', 'SEC'];

    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Shop now';

    void onTap() => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        );

    final panelColor = cmsPanel(context, const Color(0xFF1A0B2E));

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: CmsTextColor.cardOf(context) == null
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2B1055), Color(0xFF1A0B2E)],
                  )
                : null,
            color: CmsTextColor.cardOf(context) != null ? panelColor : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((content.layoutSubTitle ?? '').isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                  ),
                  child: Text(
                    content.layoutSubTitle!.toUpperCase(),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: cmsText(context, Colors.white),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                content.layoutTitle ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: cmsText(context, Colors.white),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  for (int i = 0; i < digits.length; i++) ...[
                    _DigitBox(value: digits[i], label: labels[i]),
                    if (i != digits.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          ':',
                          style: FontUtils.primaryFontStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: cmsText(context, Colors.white70),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cmsAccent(context, const Color(0xFFFF3D71)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ctaLabel,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: cmsOn(cmsAccent(context, const Color(0xFFFF3D71))),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: cmsOn(cmsAccent(context, const Color(0xFFFF3D71))),
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

class _DigitBox extends StatelessWidget {
  final String value;
  final String label;
  const _DigitBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 52,
          width: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Text(
            value,
            style: FontUtils.primaryFontStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: cmsText(context, Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: FontUtils.primaryFontStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: cmsText(context, Colors.white54),
          ),
        ),
      ],
    );
  }
}
