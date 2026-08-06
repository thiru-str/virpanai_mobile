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

/// ProductFilterGrid1 — a 2-column product grid preceded by a horizontal row of
/// filter / sort chips (All / Popular / Under Rs 1499 / New). Selecting a chip
/// only re-highlights it (presentational — the grid is unchanged). Distinct
/// from the plain add-grid: the sticky filter bar makes it read as a filterable
/// catalogue block. StatefulWidget for the chip selection. Each tile has image,
/// title, price and an [AddStepper]. Composed from the shared merch/product
/// helpers so theming is inherited (no hardcoded text colours).
class ProductFilterGrid1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductFilterGrid1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  State<ProductFilterGrid1> createState() => _ProductFilterGrid1State();
}

class _ProductFilterGrid1State extends State<ProductFilterGrid1> {
  static const _filters = ['All', 'Popular', 'Under Rs 1499', 'New'];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
              ctaText: content.layoutRedirectTitle ?? '',
              onTap: () => RedirectUtils.handleContentRedirect(
                context: context,
                layoutOption: content.layoutOption ?? '',
                layoutData: items.first,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter / sort chips — local selection state, presentational.
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _FilterChip(
                label: _filters[i],
                selected: i == _selected,
                onTap: () => setState(() => _selected = i),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Generous, width-independent cell height for image + title +
                // price + a stepper row so nothing overflows on narrow phones.
                mainAxisExtent: 285,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _FilterGridTile(
                  data: item,
                  onTap: () => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: item,
                  ),
                  onCartQtyChanged: widget.onCartQtyChanged,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = cmsAccent(context, AppColors.primary);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
            fontSize: 13,
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

class _FilterGridTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _FilterGridTile({
    required this.data,
    required this.onTap,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);
    final originalPrice = merchOriginalPrice(data);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;
    final variantId = variantIdOf(data);

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
                height: 140,
                width: double.infinity,
                child: merchImageOrFallback(
                  image,
                  fit: BoxFit.cover,
                  height: 140,
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
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(height: 2),
              Text(
                CurrencyUtil.appendCurrency(originalPrice),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 11,
                  color: cmsCardText(context, AppColors.textColor50),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AddStepper(
                  count: cartQtyOf(data),
                  onInc: () =>
                      onCartQtyChanged?.call(cartQtyOf(data) + 1, variantId),
                  onDec: () =>
                      onCartQtyChanged?.call(cartQtyOf(data) - 1, variantId),
                  accent: cmsAccent(context, AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
