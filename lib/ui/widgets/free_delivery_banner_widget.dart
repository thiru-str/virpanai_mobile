import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class FreeDeliveryBannerWidget extends StatefulWidget {
  final String cartId;
  final num cartTotal;

  const FreeDeliveryBannerWidget({
    super.key,
    required this.cartId,
    required this.cartTotal,
  });

  @override
  State<FreeDeliveryBannerWidget> createState() => _FreeDeliveryBannerWidgetState();
}

class _FreeDeliveryBannerWidgetState extends State<FreeDeliveryBannerWidget> {
  Map<String, dynamic>? _info;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(FreeDeliveryBannerWidget old) {
    super.didUpdateWidget(old);
    if (old.cartTotal != widget.cartTotal || old.cartId != widget.cartId) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    if (widget.cartId.isEmpty) return;
    try {
      final info = await ApiService().getFreeDeliveryInfo(context, widget.cartId);
      if (mounted) setState(() => _info = info);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    if (info == null) return const SizedBox.shrink();
    if (info['has_address'] == false) return const SizedBox.shrink();
    if (info['has_config'] == false) return const SizedBox.shrink();

    final eligible  = info['eligible'] == true;
    final remaining = (info['remaining'] as num?)?.toDouble() ?? 0;

    // ── Success strip ─────────────────────────────────────────────
    if (eligible) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(Icons.check_circle_rounded, size: 15, color: Colors.green.shade500),
          const SizedBox(width: 8),
          Text.rich(TextSpan(children: [
            TextSpan(
              text: 'FREE DELIVERY ',
              style: FontUtils.primaryFontStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.green.shade600),
            ),
            TextSpan(
              text: 'unlocked on this order',
              style: FontUtils.primaryFontStyle(
                  fontSize: 12, color: Colors.grey.shade500),
            ),
          ])),
        ]),
      );
    }

    // ── Nudge strip ───────────────────────────────────────────────
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(TextSpan(children: [
            TextSpan(
              text: '₹${remaining.toStringAsFixed(0)} ',
              style: FontUtils.primaryFontStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
            TextSpan(
              text: 'away from ',
              style: FontUtils.primaryFontStyle(
                  fontSize: 12, color: Colors.grey.shade500),
            ),
            TextSpan(
              text: 'FREE DELIVERY',
              style: FontUtils.primaryFontStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ])),
        ),
      ]),
    );
  }
}
