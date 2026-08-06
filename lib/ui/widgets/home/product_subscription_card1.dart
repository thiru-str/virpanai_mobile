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

/// ProductSubscriptionCard1 — a single "Subscribe & Save" card built for the
/// FIRST item only. Image sits on the left; the right column shows the title,
/// price with a "Save 10%" chip, a row of delivery-frequency pills
/// (Weekly / Monthly / Every 2 months, one selected — presentational) and an
/// [AddStepper] with a "Subscribe" context label. Distinct from every grid /
/// rail / list widget: it is a one-item subscription CTA card. StatefulWidget
/// for the local frequency selection. Composed from the shared merch/product
/// helpers so theming is inherited (no hardcoded text colours).
class ProductSubscriptionCard1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductSubscriptionCard1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  State<ProductSubscriptionCard1> createState() =>
      _ProductSubscriptionCard1State();
}

class _ProductSubscriptionCard1State extends State<ProductSubscriptionCard1> {
  static const _frequencies = ['Weekly', 'Monthly', 'Every 2 months'];
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final data = items.first;
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);
    final originalPrice = merchOriginalPrice(data);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;
    final variantId = variantIdOf(data);
    final accent = cmsAccent(context, AppColors.primary);

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
            onTap: () => RedirectUtils.handleContentRedirect(
              context: context,
              layoutOption: content.layoutOption ?? '',
              layoutData: data,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => RedirectUtils.handleContentRedirect(
              context: context,
              layoutOption: content.layoutOption ?? '',
              layoutData: data,
            ),
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
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 120,
                      height: 168,
                      child: merchImageOrFallback(
                        image,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 168,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cmsCardText(context, AppColors.textColor),
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                  fontWeight: FontWeight.w800,
                                  color:
                                      cmsCardText(context, AppColors.textColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Save 10%',
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(height: 4),
                          Text(
                            CurrencyUtil.appendCurrency(originalPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 12,
                              color: cmsCardText(context, AppColors.textColor50),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Delivery-frequency pills — presentational selection.
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < _frequencies.length; i++)
                              _FreqPill(
                                label: _frequencies[i],
                                selected: i == _selected,
                                accent: accent,
                                onTap: () => setState(() => _selected = i),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              'Subscribe',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color:
                                    cmsCardText(context, AppColors.textColor50),
                              ),
                            ),
                            const Spacer(),
                            AddStepper(
                              count: cartQtyOf(data),
                              onInc: () =>
                                  widget.onCartQtyChanged?.call(
                                      cartQtyOf(data) + 1, variantId),
                              onDec: () =>
                                  widget.onCartQtyChanged?.call(
                                      cartQtyOf(data) - 1, variantId),
                              accent: accent,
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
        ],
      ),
    );
  }
}

class _FreqPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _FreqPill({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accent : cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? accent : Colors.black12),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FontUtils.primaryFontStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: selected
                ? cmsOn(accent)
                : cmsCardText(context, AppColors.textColor),
          ),
        ),
      ),
    );
  }
}
