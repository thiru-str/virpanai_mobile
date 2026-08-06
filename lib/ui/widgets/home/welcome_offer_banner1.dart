import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// WelcomeOfferBanner1 — a new-user welcome banner: a cmsAccent gradient rounded
// card with a "WELCOME" kicker chip, a big layoutTitle (e.g. "Get Rs 300 off
// your first order", maxLines 2), a layoutSubTitle (maxLines 2), and a solid
// contrasting CTA button (layoutRedirectTitle). No per-item images needed. The
// whole card taps through.
class WelcomeOfferBanner1 extends StatelessWidget {
  final Content content;
  const WelcomeOfferBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle ?? '';
    final subtitle = content.layoutSubTitle ?? '';
    final kicker = 'Welcome';
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Claim offer';

    final accent = cmsAccent(context, const Color(0xFF6D3BEA));
    final onAccent = cmsOn(accent);
    // CTA sits on the accent card, so it must contrast against it: a light
    // button on a dark accent, a dark button on a light accent.
    final ctaFill = cmsIsLight(accent) ? const Color(0xFF0B0B0B) : Colors.white;
    final ctaText = cmsOn(ctaFill);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
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
          width: double.infinity,
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
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // WELCOME kicker chip.
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: onAccent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.celebration_rounded, size: 13, color: onAccent),
                    const SizedBox(width: 5),
                    Text(
                      kicker.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: onAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (title.isNotEmpty)
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: onAccent,
                  ),
                ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: onAccent.withValues(alpha: 0.90),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ctaFill,
                  borderRadius: BorderRadius.circular(24),
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
                    Icon(Icons.arrow_forward_rounded, size: 16, color: ctaText),
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
