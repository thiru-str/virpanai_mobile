import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/utility/app_colors.dart';

class CashfreeEmiOptions extends StatefulWidget {
  final num amount;
  const CashfreeEmiOptions({super.key, required this.amount});

  @override
  State<CashfreeEmiOptions> createState() => _CashfreeEmiOptionsState();
}

class _CashfreeEmiOptionsState extends State<CashfreeEmiOptions> {
  late Future<Map<String, dynamic>> _emiOptions;

  @override
  void initState() {
    super.initState();
    _emiOptions = ApiService().getCashfreeEmiOptions(widget.amount);
  }

  @override
  void didUpdateWidget(covariant CashfreeEmiOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _emiOptions = ApiService().getCashfreeEmiOptions(widget.amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.amount <= 0) return const SizedBox.shrink();
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
}
