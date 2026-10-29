import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';
import 'product_cards_shared.dart';

/// ProductBundleCard1 — a single WIDE "bundle / combo" card. It shows a row of
/// 2–3 small product thumbnails (taken from the first items) joined by "+"
/// glyphs, the bundle title ([Content.layoutTitle]), a combined price line
/// (sum of the shown items' selling prices), and a full-width [AddStepper]
/// "Add bundle" action. Tapping the card (or the header CTA) redirects on
/// `items.first`. Composed from the shared merch/product helpers so theming is
/// inherited (no hardcoded text colours).
class ProductBundleCard1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductBundleCard1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  // Sum the selling prices of the shown thumbnails; format without trailing .0.
  String _combinedPrice(List<LayoutDatum> thumbs) {
    var total = 0.0;
    for (final t in thumbs) {
      total += double.tryParse(merchSellingPrice(t)) ?? 0;
    }
    final rounded = total.roundToDouble();
    final asStr = total == rounded
        ? rounded.toStringAsFixed(0)
        : total.toStringAsFixed(2);
    return CurrencyUtil.appendCurrency(asStr);
  }

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final thumbs = items.take(3).toList();
    final first = items.first;
    final variantId = variantIdOf(first);

    void redirectFirst() => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: first,
        );

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? '',
            ctaText: content.layoutRedirectTitle ?? '',
            onTap: redirectFirst,
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: redirectFirst,
            child: Container(
              decoration: BoxDecoration(
                color: cmsCard(context, Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnails joined by "+" glyphs.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var i = 0; i < thumbs.length; i++) ...[
                        if (i > 0)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: cmsCardText(context, AppColors.textColor50),
                            ),
                          ),
                        Expanded(child: _BundleThumb(data: thumbs[i])),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    content.layoutTitle ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: cmsCardText(context, AppColors.textColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bundle price ${_combinedPrice(thumbs)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: cmsCardText(context, AppColors.textColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Full-width "Add bundle" action wired to add-to-cart on the
                  // first item's variant.
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${thumbs.length} items',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cmsCardText(context, AppColors.textColor50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AddStepper(
                        count: cartQtyOf(first),
                        onInc: () => onCartQtyChanged?.call(1, variantId),
                        onDec: () => onCartQtyChanged?.call(-1, variantId),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BundleThumb extends StatelessWidget {
  final LayoutDatum data;
  const _BundleThumb({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 92,
            width: double.infinity,
            child: merchImageOrFallback(
              merchImage(data),
              fit: BoxFit.cover,
              height: 92,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.title ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FontUtils.primaryFontStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cmsCardText(context, AppColors.textColor),
          ),
        ),
      ],
    );
  }
}
