import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../utility/app_colors.dart';
import '../../utility/extensions_util.dart';
import '../../utility/font_utils.dart';

/// Slim earn preview: "Earn X points on this order".
///
/// Prefer passing [cartId] for cart/checkout views — the API will then
/// compute the earnable amount server-side (excludes platform_fee and
/// applies earn restriction). [orderTotal] is only used as a fallback when
/// [cartId] is null.
class LoyaltyEarnPreview extends StatefulWidget {
  final num orderTotal;
  final String? cartId;
  const LoyaltyEarnPreview({super.key, required this.orderTotal, this.cartId});

  @override
  State<LoyaltyEarnPreview> createState() => _LoyaltyEarnPreviewState();
}

class _LoyaltyEarnPreviewState extends State<LoyaltyEarnPreview> {
  int _points = 0;
  bool _earnEnabled = false;
  bool _loading = true;
  bool _hasBonus = false;
  int _basePoints = 0;
  double _multiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(LoyaltyEarnPreview old) {
    super.didUpdateWidget(old);
    if (old.orderTotal != widget.orderTotal || old.cartId != widget.cartId) _load();
  }

  Future<void> _load() async {
    final hasCart = widget.cartId != null && widget.cartId!.isNotEmpty;
    if (!ExtensionsUtil.has('loyalty') || (!hasCart && widget.orderTotal <= 0)) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final resp = await ApiService()
          .getLoyaltyPreview(widget.orderTotal, cartId: widget.cartId);
      final d = resp.data;
      if (d['status'] == true && d['data'] != null) {
        final data = d['data'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _earnEnabled = data['earn_enabled'] == true;
            _points = data['points_to_earn'] ?? 0;
            _basePoints = data['base_points'] ?? _points;
            _multiplier = double.tryParse(data['multiplier']?.toString() ?? '1') ?? 1.0;
            _hasBonus = (data['rule_applied'] == true) && _multiplier > 1.01;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ExtensionsUtil.has('loyalty')) return const SizedBox.shrink();
    if (_loading || !_earnEnabled || _points <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.stars_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: FontUtils.secondaryFontStyle(fontSize: 12, color: Colors.grey.shade700),
                    children: [
                      const TextSpan(text: 'Earn '),
                      TextSpan(
                        text: '$_points points',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const TextSpan(text: ' on this order'),
                    ],
                  ),
                ),
                if (_hasBonus)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      '${_multiplier.toStringAsFixed(_multiplier == _multiplier.toInt() ? 0 : 1)}× bonus applied!',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 10, color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$_points',
              style: FontUtils.primaryFontStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
