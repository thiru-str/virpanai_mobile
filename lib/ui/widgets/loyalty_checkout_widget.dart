import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../model/loyalty_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/currency_util.dart';
import '../../utility/extensions_util.dart';
import '../../utility/font_utils.dart';

/// Checkbox-style loyalty apply — deferred debit architecture.
/// Points are NOT debited on tap. Only intent is stored in cart metadata.
/// Actual debit happens on order.placed (server-side).
class LoyaltyCheckoutWidget extends StatefulWidget {
  final String cartId;
  final VoidCallback onApplied;
  final VoidCallback onRemoved;

  /// Latest loyalty_checkout_apply metadata from the cart response.
  /// When the backend recalculates loyalty (e.g. wallet now covers the cart
  /// in full and loyalty drops to 0), the parent rebuilds with the fresh
  /// values. didUpdateWidget syncs _applied / _appliedPoints / _discountAmount
  /// from this — without it the checkbox stays "applied" with stale points
  /// even though the price summary already shows ₹0 off.
  final Map<String, dynamic>? loyaltyApply;

  /// Cart total *after* coupon (Medusa-tracked) but before wallet/loyalty.
  /// Used together with walletAmount to compute what's actually redeemable.
  final num? cartTotal;

  /// Wallet amount currently applied (from cart.metadata.wallet_split).
  /// Priority order is coupon → wallet → loyalty, so the redeemable cap
  /// for points is `cartTotal - walletAmount`.
  final num? walletAmount;

  const LoyaltyCheckoutWidget({
    super.key,
    required this.cartId,
    required this.onApplied,
    required this.onRemoved,
    this.loyaltyApply,
    this.cartTotal,
    this.walletAmount,
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

  @override
  void didUpdateWidget(covariant LoyaltyCheckoutWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pick up backend recalcs (wallet apply zeroed loyalty, qty change
    // shrunk it, etc.) without waiting for the next refetch cycle.
    final next = widget.loyaltyApply;
    if (!_busy && next != null) {
      final discount = (next['discount_amount'] as num?)?.toInt() ?? 0;
      final pts = (next['points_to_apply'] as num?)?.toInt() ?? 0;
      final newApplied = discount > 0 && pts > 0;
      if (newApplied != _applied ||
          discount != _discountAmount ||
          pts != _appliedPoints) {
        setState(() {
          _applied = newApplied;
          _discountAmount = discount;
          _appliedPoints = pts;
        });
      }
    }
  }

  double _ratio() {
    final r = _account?.redeemRatio;
    if (r == null) return 1.0;
    return double.tryParse(r.toString()) ?? 1.0;
  }

  Future<void> _loadAll() async {
    if (!ExtensionsUtil.has('loyalty')) {
      if (mounted) setState(() => _loading = false);
      return;
    }
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
    if (!ExtensionsUtil.has('loyalty')) return const SizedBox.shrink();
    if (_loading) return const SizedBox.shrink();
    if (_account == null || _account!.checkoutApplyEnabled != true) return const SizedBox.shrink();
    final balance = _account!.pointsBalance ?? 0;
    if (balance <= 0 && !_applied) return const SizedBox.shrink();

    final ratio = _ratio();
    // Full conversion of balance to currency (e.g. 1000 pts × ratio 1 = ₹1000).
    // Always show this as "Use N points" so the customer sees their full
    // available redemption value, not a number that shifts as they move
    // wallet around.
    final worthFromBalance = ratio > 0 ? (balance / ratio).floor() : 0;

    // Effective remaining the gateway would charge if loyalty weren't applied.
    // Priority is coupon → wallet → loyalty, so this is the redeemable cap for
    // points: cart.total (post-coupon) − wallet_amount. When this hits 0
    // (wallet already covers the cart) there's nothing left for points to
    // bite into — hide the section entirely so the customer doesn't see a
    // useless redemption row.
    final cartTotal = (widget.cartTotal ?? 0).toDouble();
    final walletAmount = (widget.walletAmount ?? 0).toDouble();
    final remaining = (cartTotal - walletAmount).clamp(0, double.infinity).toInt();

    if (remaining <= 0 && !_applied) return const SizedBox.shrink();

    // The "off" the redemption can actually deliver right now: capped by
    // both balance value and remaining cart amount.
    final displayOff = remaining > 0
        ? (worthFromBalance < remaining ? worthFromBalance : remaining)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    ? Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: '${CurrencyUtil.appendCurrency(_discountAmount.toStringAsFixed(0))} off ',
                            style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          TextSpan(
                            text: '· $_appliedPoints pts applied',
                            style: FontUtils.secondaryFontStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Use $balance points ',
                            style: FontUtils.primaryFontStyle(fontSize: 13, color: Colors.black87),
                          ),
                          TextSpan(
                            text: '(${CurrencyUtil.appendCurrency(displayOff.toString())} off)',
                            style: FontUtils.secondaryFontStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _error!,
              style: FontUtils.secondaryFontStyle(fontSize: 12, color: Colors.red.shade600),
            ),
          ),
      ],
    );
  }
}
