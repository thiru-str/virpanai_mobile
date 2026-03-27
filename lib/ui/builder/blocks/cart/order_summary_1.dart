import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';
import '../../../../utility/currency_util.dart';

/// OrderSummary1 - Collapsible price breakdown.
/// Extracted from cart_page.dart price breakdown section
class OrderSummary1Widget extends StatefulWidget {
  final String? subtotal;
  final String? discount;
  final String? shipping;
  final String? tax;
  final String? total;
  final String? platformFee;
  final BlockConfig config;

  const OrderSummary1Widget({
    super.key,
    required this.config,
    this.subtotal,
    this.discount,
    this.shipping,
    this.tax,
    this.total,
    this.platformFee,
  });

  @override
  State<OrderSummary1Widget> createState() => _OrderSummary1WidgetState();
}

class _OrderSummary1WidgetState extends State<OrderSummary1Widget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price Breakdown',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textColor50,
                  ),
                ],
              ),
            ),

            // Expanded details
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    _buildRow('Subtotal', widget.subtotal),
                    if (widget.discount != null && widget.discount != '0')
                      _buildRow('Discount', '-${widget.discount}', valueColor: Colors.green),
                    _buildRow('Shipping', widget.shipping ?? 'Free'),
                    if (widget.platformFee != null && widget.platformFee != '0')
                      _buildRow('Platform Fee', widget.platformFee),
                    if (widget.config.getBool('show_tax_breakdown', defaultValue: true))
                      _buildRow('Tax', widget.tax),
                    const Divider(),
                    _buildRow(
                      'Total',
                      widget.total,
                      keyStyle: FontUtils.primaryFontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                      valueStyle: FontUtils.primaryFontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String key,
    String? value, {
    TextStyle? keyStyle,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: keyStyle ??
                FontUtils.secondaryFontStyle(
                  fontSize: 14,
                  color: AppColors.textColor50,
                ),
          ),
          Text(
            value != null ? CurrencyUtil.appendCurrency(value) : '-',
            style: valueStyle ??
                FontUtils.secondaryFontStyle(
                  fontSize: 14,
                  color: valueColor ?? AppColors.textColor,
                ),
          ),
        ],
      ),
    );
  }
}
