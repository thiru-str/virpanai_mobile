import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// SlimOfferBar1 — a THIN single-line offer bar (~48h tall), deliberately
// slimmer than the promo strip. A cmsPanel/cmsAccent band with a small leading
// tag icon, a single-line offer headline (layoutTitle, Expanded, maxLines 1),
// and a trailing rounded CTA chip (layoutRedirectTitle). The whole bar is
// tappable and redirects via the component's layout option/data. Distinct from
// the promo strip (no subtitle, no two-line stack, much thinner).
class SlimOfferBar1 extends StatelessWidget {
  final Content content;
  const SlimOfferBar1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final panel = cmsPanel(context, const Color(0xFF1F1B2E));
    final accent = cmsAccent(context, const Color(0xFF8E6CEF));
    final onPanel = cmsIsLight(panel)
        ? const Color(0xFF0B0B0B)
        : const Color(0xFFFFFFFF);

    final title = content.layoutTitle ?? '';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Grab';

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        ),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.local_offer,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: onPanel,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  ctaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: cmsOn(accent),
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
