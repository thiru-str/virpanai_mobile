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

/// ProductFbtBundle1 — a "Frequently Bought Together" panel. The first 3 items
/// are shown as vertical rows, each with a leading toggle checkbox
/// (presentational), a thumbnail, title and price. A running TOTAL line sums the
/// selling prices of the currently CHECKED items, and a full-width
/// "Add N items to cart" button fires [onCartQtyChanged] (+1) on each checked
/// item's variant. StatefulWidget because the checkbox selection is local UI
/// state. Composed from the shared merch/product helpers so theming is inherited
/// (no hardcoded text colours). Guards empty → [SizedBox.shrink].
class ProductFbtBundle1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductFbtBundle1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  State<ProductFbtBundle1> createState() => _ProductFbtBundle1State();
}

class _ProductFbtBundle1State extends State<ProductFbtBundle1> {
  // Selection state keyed by the row index; all rows start checked.
  late List<bool> _checked;
  late List<LayoutDatum> _rows;

  @override
  void initState() {
    super.initState();
    _rows = (widget.content.layoutData ?? []).take(3).toList();
    _checked = List<bool>.filled(_rows.length, true);
  }

  double _rowPrice(LayoutDatum d) => double.tryParse(merchSellingPrice(d)) ?? 0;

  double get _total {
    var sum = 0.0;
    for (var i = 0; i < _rows.length; i++) {
      if (_checked[i]) sum += _rowPrice(_rows[i]);
    }
    return sum;
  }

  int get _checkedCount => _checked.where((c) => c).length;

  String _fmt(double v) {
    final rounded = v.roundToDouble();
    return v == rounded ? rounded.toStringAsFixed(0) : v.toStringAsFixed(2);
  }

  void _addChecked() {
    for (var i = 0; i < _rows.length; i++) {
      if (!_checked[i]) continue;
      final id = variantIdOf(_rows[i]);
      if (id.isEmpty) continue;
      widget.onCartQtyChanged?.call(cartQtyOf(_rows[i]) + 1, id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final accent = cmsAccent(context, AppColors.primary);

    void redirectFirst() => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: widget.content.layoutOption ?? '',
          layoutData: items.first,
        );

    return Container(
      decoration: AppUtils.buildLayoutBackground(widget.content),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeMerchSectionHeader(
            title: widget.content.layoutTitle ?? '',
            subtitle: widget.content.layoutSubTitle ?? '',
            ctaText: widget.content.layoutRedirectTitle ?? '',
            onTap: redirectFirst,
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: cmsCard(context, Colors.white),
              borderRadius: BorderRadius.circular(18),
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
                for (var i = 0; i < _rows.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        height: 1,
                        color: cmsCardText(context, AppColors.textColor50)
                            .withValues(alpha: 0.18),
                      ),
                    ),
                  _FbtRow(
                    data: _rows[i],
                    checked: _checked[i],
                    accent: accent,
                    onToggle: () =>
                        setState(() => _checked[i] = !_checked[i]),
                    onTap: () => RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: widget.content.layoutOption ?? '',
                      layoutData: _rows[i],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Running total of the checked items.
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cmsCardText(context, AppColors.textColor50),
                        ),
                      ),
                    ),
                    Text(
                      CurrencyUtil.appendCurrency(_fmt(_total)),
                      style: FontUtils.primaryFontStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: cmsCardText(context, AppColors.textColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Full-width add-to-cart action for every checked item.
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _checkedCount == 0 ? null : _addChecked,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: accent,
                      disabledBackgroundColor: accent.withValues(alpha: 0.4),
                      foregroundColor: cmsOn(accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _checkedCount == 0
                          ? 'Select items to add'
                          : 'Add $_checkedCount item${_checkedCount == 1 ? '' : 's'} to cart',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: cmsOn(accent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FbtRow extends StatelessWidget {
  final LayoutDatum data;
  final bool checked;
  final Color accent;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _FbtRow({
    required this.data,
    required this.checked,
    required this.accent,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);
    final originalPrice = merchOriginalPrice(data);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;

    return Row(
      // Top-align so a two-line title never pushes the checkbox/thumb off.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              size: 22,
              color: checked
                  ? accent
                  : cmsCardText(context, AppColors.textColor50),
            ),
          ),
        ),
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
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                            fontSize: 11,
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
        ),
      ],
    );
  }
}
