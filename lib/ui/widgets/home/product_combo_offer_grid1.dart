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

/// ProductComboOfferGrid1 — a 2-column "combo offer" grid. Each tile shows the
/// image, title, the unit price, and a highlighted "Buy 2 @ Rs X" COMBO line
/// (two units at the selling price with a small 5% multi-buy discount, computed
/// via double.tryParse + [CurrencyUtil]) sitting beside a [AddStepper].
/// Non-scrolling (shrinkWrap + NeverScrollableScrollPhysics) so it nests inside
/// the page scroll view. Composed from the shared merch/product helpers so
/// theming is inherited (no hardcoded text colours). Guards empty →
/// [SizedBox.shrink].
class ProductComboOfferGrid1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductComboOfferGrid1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

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
              layoutData: items.first,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // Generous, width-independent cell height for image + title +
              // unit price + combo-offer line + stepper so nothing overflows.
              mainAxisExtent: 295,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ComboTile(
                data: item,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                onCartQtyChanged: onCartQtyChanged,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ComboTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _ComboTile({
    required this.data,
    required this.onTap,
    this.onCartQtyChanged,
  });

  // "Buy 2" combo price: two units at the selling price, less a small 5%
  // multi-buy discount, rounded to a whole unit. Empty when price is unknown.
  String _comboPrice(String selling) {
    final s = double.tryParse(selling) ?? 0;
    if (s <= 0) return '';
    final combo = (s * 2 * 0.95).round();
    return combo.toString();
  }

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);
    final variantId = variantIdOf(data);
    final accent = cmsAccent(context, AppColors.primary);
    final combo = _comboPrice(sellingPrice);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  height: 120,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              CurrencyUtil.appendCurrency(sellingPrice),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            if (combo.isNotEmpty) ...[
              const SizedBox(height: 6),
              // Highlighted multi-buy combo line.
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_offer, size: 12, color: accent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Buy 2 @ ${CurrencyUtil.appendCurrency(combo)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: cmsCardText(context, AppColors.textColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: Center(
                child: AddStepper(
                  count: cartQtyOf(data),
                  onInc: () =>
                      onCartQtyChanged?.call(cartQtyOf(data) + 1, variantId),
                  onDec: () =>
                      onCartQtyChanged?.call(cartQtyOf(data) - 1, variantId),
                  accent: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
