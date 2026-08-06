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

/// ProductCompareRow1 — a horizontal rail of "compare" cards. Each card stacks
/// TWO mini product rows (drawn from consecutive items) separated by a small
/// "vs" divider, plus one shared "Add top pick" [AddStepper] wired to the first
/// (top) item of the pair. Each mini row taps through to its own product. The
/// rail lives in a fixed-height [SizedBox] and each card is a fixed width so the
/// horizontal list never overflows. Composed from the shared merch helpers.
class ProductCompareRow1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductCompareRow1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    // Group items into consecutive pairs — each pair becomes one compare card.
    final pairs = <List<LayoutDatum>>[];
    for (var i = 0; i < items.length; i += 2) {
      pairs.add(items.sublist(i, (i + 2 > items.length) ? items.length : i + 2));
    }

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
          const SizedBox(height: 14),
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pairs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final pair = pairs[index];
                return _CompareCard(
                  top: pair[0],
                  bottom: pair.length > 1 ? pair[1] : null,
                  onTap: (item) => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: item,
                  ),
                  onCartQtyChanged: onCartQtyChanged,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  final LayoutDatum top;
  final LayoutDatum? bottom;
  final void Function(LayoutDatum item) onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _CompareCard({
    required this.top,
    required this.bottom,
    required this.onTap,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final variantId = variantIdOf(top);
    final accent = cmsAccent(context, AppColors.primary);

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: cmsCard(context, Colors.white),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniCompareRow(data: top, onTap: () => onTap(top)),
          const _VsDivider(),
          if (bottom != null)
            _MiniCompareRow(data: bottom!, onTap: () => onTap(bottom!)),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Top pick',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: cmsCardText(context, AppColors.textColor50),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AddStepper(
                count: cartQtyOf(top),
                onInc: () =>
                    onCartQtyChanged?.call(cartQtyOf(top) + 1, variantId),
                onDec: () =>
                    onCartQtyChanged?.call(cartQtyOf(top) - 1, variantId),
                accent: accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniCompareRow extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;

  const _MiniCompareRow({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);
    final originalPrice = merchOriginalPrice(data);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        // Top-align so a two-line title never shifts the thumbnail or overflows.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: merchImageOrFallback(
                image,
                fit: BoxFit.cover,
                width: 56,
                height: 56,
              ),
            ),
          ),
          const SizedBox(width: 10),
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: cmsCardText(context, AppColors.textColor),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        CurrencyUtil.appendCurrency(sellingPrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: cmsCardText(context, AppColors.textColor),
                        ),
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          CurrencyUtil.appendCurrency(originalPrice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 10.5,
                            color: cmsCardText(context, AppColors.textColor50),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small centred "vs" divider between the two compared rows.
class _VsDivider extends StatelessWidget {
  const _VsDivider();

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        color: cmsCardText(context, AppColors.textColor50).withValues(alpha: 0.2),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'vs',
              style: FontUtils.primaryFontStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: cmsCardText(context, AppColors.textColor50),
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}
