import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/ui/cashfree_plans_page.dart';
import 'package:waioz/utility/app_colors.dart';

class CashfreeEmiOptions extends StatefulWidget {
  final num amount;
  final String placement;
  const CashfreeEmiOptions({
    super.key,
    required this.amount,
    this.placement = 'pdp',
  });

  @override
  State<CashfreeEmiOptions> createState() => _CashfreeEmiOptionsState();
}

class _CashfreeEmiOptionsState extends State<CashfreeEmiOptions> {
  Future<Map<String, dynamic>>? _emiOptions;
  Future<Map<String, dynamic>>? _displayOptions;

  @override
  void didUpdateWidget(covariant CashfreeEmiOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount ||
        oldWidget.placement != widget.placement) {
      _emiOptions = null;
      _displayOptions = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.amount <= 0) return const SizedBox.shrink();
    final content = widget.placement == 'checkout'
        ? _buildEligibilityList()
        : _buildCompactPreview();
    return widget.placement == 'cart'
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: content,
          )
        : content;
  }

  Widget _buildCompactPreview() {
    _displayOptions ??= ApiService().getCashfreeDisplayOptions(widget.amount);
    return FutureBuilder<Map<String, dynamic>>(
      future: _displayOptions,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final emiOptions = _asList(data?['emi_options']);
        if (data?['enabled'] != true || emiOptions.isEmpty) {
          return const SizedBox.shrink();
        }

        final lowestMonthlyEmi = _lowestMonthlyEmi(emiOptions);
        final label = lowestMonthlyEmi == null
            ? 'EMI plans available'
            : 'EMI starts at ${_formatCurrency(lowestMonthlyEmi)}/month';

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF596273),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CashfreePlansPage(
                          amount: widget.amount,
                          initialTab: 'emiDetails',
                        ),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View EMI Plans',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.chevron_right,
                                size: 19, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEligibilityList() {
    _emiOptions ??= ApiService().getCashfreeEmiOptions(widget.amount);
    return FutureBuilder<Map<String, dynamic>>(
      future: _emiOptions,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final options = data?['options'] as List? ?? [];
        if (data?['enabled'] != true || options.isEmpty)
          return const SizedBox.shrink();
        final rows = <String>[];
        for (final option in options) {
          final details = option is Map ? option['entity_details'] : null;
          final plans = details is Map
              ? (details['emi_plans'] ?? details['payment_method_details'])
                      as List? ??
                  []
              : <dynamic>[];
          for (final plan in plans) {
            if (plan is Map) {
              final name = plan['display'] ??
                  plan['bank_name'] ??
                  option['entity_value'] ??
                  'Eligible bank';
              final tenure = plan['tenure'];
              final interest = plan['interest_rate'];
              rows.add(
                  '$name${tenure != null ? ' · $tenure months' : ''}${interest != null ? ' · $interest% p.a.' : ''}');
            }
          }
        }
        if (rows.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(10)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('EMI options available with Cashfree',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(row, style: const TextStyle(fontSize: 12)))),
          ]),
        );
      },
    );
  }

  static List<Map<String, dynamic>> _asList(dynamic value) => value is List
      ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
      : <Map<String, dynamic>>[];

  static double? _asAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    final normalized = value.toString().replaceAll(RegExp(r'[^0-9.-]'), '');
    final amount = double.tryParse(normalized);
    return amount != null && amount > 0 ? amount : null;
  }

  static double? _lowestMonthlyEmi(List<Map<String, dynamic>> options) {
    final monthlyAmounts = <double>[];
    for (final option in options) {
      final details = option['entity_details'];
      final detailsMap = details is Map ? details : const <String, dynamic>{};
      final plans = _asList(detailsMap['emi_plans'] ??
          detailsMap['payment_method_details'] ??
          option['schemes']);
      for (final plan in plans) {
        final amount = _asAmount(plan['monthly_emi'] ??
            plan['emi_amount'] ??
            plan['emiAmount'] ??
            plan['monthlyEmi'] ??
            plan['emi']);
        if (amount != null) monthlyAmounts.add(amount);
      }
    }
    if (monthlyAmounts.isEmpty) return null;
    return monthlyAmounts.reduce((a, b) => a < b ? a : b);
  }

  static String _formatCurrency(double value) {
    final decimalDigits = value == value.roundToDouble() ? 0 : 2;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: decimalDigits,
    ).format(value);
  }
}
