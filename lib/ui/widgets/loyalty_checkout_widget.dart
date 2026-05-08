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
          if (statusData['status'] == true &&
              statusData['data']?['applied'] == true) {
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
    if (mounted)
      setState(() {
        _busy = true;
        _error = null;
      });

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
          setState(() {
            _applied = false;
            _appliedPoints = 0;
            _discountAmount = 0;
          });
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
    if (_account == null || _account!.checkoutApplyEnabled != true)
      return const SizedBox.shrink();
    final balance = _account!.pointsBalance ?? 0;
    if (balance <= 0 && !_applied) return const SizedBox.shrink();

    // Effective remaining the gateway would charge if loyalty weren't applied.
    // Priority is coupon → wallet → loyalty, so this is the redeemable cap for
    // points: cart.total (post-coupon) − wallet_amount. When this hits 0
    // (wallet already covers the cart) there's nothing left for points to
    // bite into — hide the section entirely so the customer doesn't see a
    // useless redemption row.
    final cartTotal = (widget.cartTotal ?? 0).toDouble();
    final walletAmount = (widget.walletAmount ?? 0).toDouble();
    final remaining =
        (cartTotal - walletAmount).clamp(0, double.infinity).toInt();

    if (remaining <= 0 && !_applied) return const SizedBox.shrink();

    final canUsePoints = remaining > 0 || _applied;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _applied
              ? AppColors.primary.withOpacity(0.4)
              : Colors.grey.shade200,
          width: _applied ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: canUsePoints
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.stars_outlined,
                    color: canUsePoints ? AppColors.primary : Colors.grey,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use Loyalty Points',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              canUsePoints ? AppColors.textColor : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Available: $balance points',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _error!,
                            style: TextStyle(
                                fontSize: 11, color: Colors.red.shade600),
                          ),
                        ),
                    ],
                  ),
                ),
                _busy
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Switch(
                        value: _applied,
                        onChanged: canUsePoints ? (_) => _toggle() : null,
                        activeColor: AppColors.primary,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade200,
                      ),
              ],
            ),
          ),
          if (_applied && _discountAmount > 0) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green.shade600, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${CurrencyUtil.appendCurrency(_discountAmount.toStringAsFixed(2))} off · $_appliedPoints pts applied',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
