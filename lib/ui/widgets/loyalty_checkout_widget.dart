import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../model/loyalty_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/currency_util.dart';
import '../../utility/font_utils.dart';

/// Checkbox-style loyalty apply — deferred debit architecture.
/// Points are NOT debited on tap. Only intent is stored in cart metadata.
/// Actual debit happens on order.placed (server-side).
class LoyaltyCheckoutWidget extends StatefulWidget {
  final String cartId;
  final VoidCallback onApplied;
  final VoidCallback onRemoved;

  const LoyaltyCheckoutWidget({
    super.key,
    required this.cartId,
    required this.onApplied,
    required this.onRemoved,
  });

  @override
  State<LoyaltyCheckoutWidget> createState() => _LoyaltyCheckoutWidgetState();
}

class _LoyaltyCheckoutWidgetState extends State<LoyaltyCheckoutWidget> {
  final ApiService _api = ApiService();
  LoyaltyAccountData? _account;
  bool _loading = true;
  bool _busy = false; // Blocks ALL interaction until fully settled
  bool _applied = false;
  int _appliedPoints = 0;
  int _discountAmount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  double _ratio() {
    final r = _account?.redeemRatio;
    if (r == null) return 1.0;
    return double.tryParse(r.toString()) ?? 1.0;
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        _api.getLoyaltyAccount(),
        _api.getLoyaltyCheckoutStatus(widget.cartId),
      ]);

      final accountData = LoyaltyAccountResponse.fromJson(results[0].data);
      final statusData = results[1].data;

      if (mounted) {
        setState(() {
          _account = accountData.data;
          if (statusData['status'] == true && statusData['data']?['applied'] == true) {
            _applied = true;
            _appliedPoints = statusData['data']['points_applied'] ?? 0;
            _discountAmount = statusData['data']['discount_amount'] ?? 0;
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle() async {
    if (_busy) return;
    if (mounted) setState(() { _busy = true; _error = null; });

    try {
      if (!_applied) {
        final balance = _account?.pointsBalance ?? 0;
        final resp = await _api.applyLoyaltyCheckout(widget.cartId, balance);
        final result = resp.data;
        if (result['status'] == true) {
          if (mounted) {
            setState(() {
              _applied = true;
              _appliedPoints = result['data']?['points_applied'] ?? balance;
              _discountAmount = result['data']?['discount_amount'] ?? 0;
            });
          }
          widget.onApplied();
          // Wait for cart refresh to settle before unlocking
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          if (mounted) setState(() => _error = result['message'] ?? 'Failed');
        }
      } else {
        await _api.removeLoyaltyCheckout(widget.cartId);
        if (mounted) {
          setState(() { _applied = false; _appliedPoints = 0; _discountAmount = 0; });
        }
        widget.onRemoved();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Something went wrong');
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_account == null || _account!.checkoutApplyEnabled != true) return const SizedBox.shrink();
    final balance = _account!.pointsBalance ?? 0;
    if (balance <= 0 && !_applied) return const SizedBox.shrink();

    final ratio = _ratio();
    final worth = ratio > 0 ? (balance / ratio).floor() : 0;

    return GestureDetector(
      onTap: _busy ? null : _toggle,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: _busy ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _applied ? AppColors.primary.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _applied ? AppColors.primary.withOpacity(0.3) : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              _busy
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: _applied ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _applied ? AppColors.primary : Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: _applied
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: _applied
                    ? Text.rich(TextSpan(children: [
                        TextSpan(
                          text: '${CurrencyUtil.appendCurrency(_discountAmount.toStringAsFixed(0))} off ',
                          style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                        TextSpan(
                          text: '· $_appliedPoints pts applied',
                          style: FontUtils.secondaryFontStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ]))
                    : Text.rich(TextSpan(children: [
                        TextSpan(
                          text: 'Use $balance points ',
                          style: FontUtils.primaryFontStyle(fontSize: 13, color: Colors.black87),
                        ),
                        TextSpan(
                          text: '(${CurrencyUtil.appendCurrency(worth.toString())} off)',
                          style: FontUtils.secondaryFontStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
