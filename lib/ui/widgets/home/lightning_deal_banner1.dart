import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// LightningDealBanner1 — a "Deal of the Day" card. Left = the first item's
// product thumbnail (96x96 rounded). Right = a lightning ⚡ accent kicker, the
// headline/item title (maxLines 2), a price row (selling + struck original),
// a thin static "sold" progress bar with a "Hurry, almost gone" caption, and a
// small CTA chip. Guards when there are no items. The whole card taps through.
class LightningDealBanner1 extends StatelessWidget {
  final Content content;
  const LightningDealBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final first = items.first;

    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : (first.title ?? 'Deal of the Day');
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Grab now';

    final sellingPrice = merchSellingPrice(first);
    final originalPrice = merchOriginalPrice(first);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;

    final accent = cmsAccent(context, const Color(0xFFF5A524));
    final onAccent = cmsOn(accent);
    final cardBg = cmsCard(context, Colors.white);
    final onCard = cmsCardText(context, const Color(0xFF141414));

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: items.first,
        ),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 96,
                  width: 96,
                  child: merchImageOrFallback(
                    merchImage(first),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lightning kicker.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, size: 15, color: accent),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'DEAL OF THE DAY',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: onCard,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            CurrencyUtil.appendCurrency(sellingPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: onCard,
                            ),
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              CurrencyUtil.appendCurrency(originalPrice),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: onCard.withValues(alpha: 0.55),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Static "sold" progress bar (~0.7).
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 6,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ColoredBox(
                                color: onCard.withValues(alpha: 0.10),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 0.7,
                              child: ColoredBox(color: accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Hurry, almost gone',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: onCard.withValues(alpha: 0.60),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            ctaLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: onAccent,
                            ),
                          ),
                        ),
                      ],
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
