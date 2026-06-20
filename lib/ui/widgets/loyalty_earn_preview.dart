import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../utility/app_colors.dart';
import '../../utility/extensions_util.dart';
import '../../utility/font_utils.dart';
import '../../utility/shared_preferences_util.dart';

/// Loyalty intimation strip for cart + checkout.
///
/// Four states (Item 1 of QA sprint):
///   - Guest, cart < min     → "Add ₹X more + sign up to earn ~N pts"
///   - Guest, cart ≥ min     → "Sign up to earn ~N pts on this order"
///   - Logged-in, cart < min → "Add ₹X more to earn ~N pts"
///   - Logged-in, cart ≥ min → "You'll earn N pts on this order ✓"
///
/// Renders nothing when loyalty is disabled globally (`earn_enabled = false`)
/// or when extension isn't enabled — never surfaces negative messaging.
class LoyaltyEarnPreview extends StatefulWidget {
  final num orderTotal;
  final String? cartId;
  /// PDP-only — when present, backend short-circuits if the merchant has
  /// restricted earning to specific products / categories and this product
  /// isn't in the allowed set. Avoids promising points the order subscriber
  /// will later refuse.
  final String? productId;
  const LoyaltyEarnPreview({
    super.key,
    required this.orderTotal,
    this.cartId,
    this.productId,
  });

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
  num _minOrderValue = 0;
  num _earnableAmount = 0;
  num _earnRatio = 1;
  bool _isLoggedIn = false;
  // Backend sets status="not_eligible" when the merchant restricts earning
  // to specific products / categories and the current product (PDP context)
  // isn't allowed. Render nothing instead of the deceptive "Add ₹X more to
  // earn …" copy that would otherwise still show because earn_enabled=true.
  bool _notEligible = false;
  int _orderNumber = 0;
  Map<String, dynamic>? _nextMilestone;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
    _load();
  }

  @override
  void didUpdateWidget(LoyaltyEarnPreview old) {
    super.didUpdateWidget(old);
    if (old.orderTotal != widget.orderTotal ||
        old.cartId != widget.cartId ||
        old.productId != widget.productId) {
      _load();
    }
  }

  Future<void> _checkLoginState() async {
    // App stores the auth token under the 'token' key (see ApiService.addToken).
    // Earlier 'access_token' was a typo and made the preview stay in guest copy
    // ("Sign up to earn…") for users who were actually logged in.
    final token = await SharedPreferencesUtil().getString('token');
    if (mounted) setState(() => _isLoggedIn = (token ?? '').isNotEmpty);
  }

  Future<void> _load() async {
    final hasCart = widget.cartId != null && widget.cartId!.isNotEmpty;
    if (!ExtensionsUtil.has('loyalty') || (!hasCart && widget.orderTotal <= 0)) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final resp = await ApiService().getLoyaltyPreview(
        widget.orderTotal,
        cartId: widget.cartId,
        productId: widget.productId,
      );
      final d = resp.data;
      if (d['status'] == true && d['data'] != null) {
        final data = d['data'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _earnEnabled = data['earn_enabled'] == true;
            _notEligible = data['status'] == 'not_eligible';
            _points = data['points_to_earn'] ?? 0;
            _basePoints = data['base_points'] ?? _points;
            _multiplier = double.tryParse(data['multiplier']?.toString() ?? '1') ?? 1.0;
            _hasBonus = (data['rule_applied'] == true) && _multiplier > 1.01;
            _minOrderValue = double.tryParse(data['minimum_order_value']?.toString() ?? '0') ?? 0;
            _earnableAmount = double.tryParse(data['earnable_amount']?.toString() ?? '0') ?? widget.orderTotal.toDouble();
            _earnRatio = double.tryParse(data['earn_ratio']?.toString() ?? '1') ?? 1;
            _orderNumber = (data['order_number'] as num?)?.toInt() ?? 0;
            _nextMilestone = data['next_milestone'] as Map<String, dynamic>?;
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

  // Estimate points the user WOULD earn once they hit min order value.
  // Uses the same formula the service uses: floor(earnable / earn_ratio).
  int _estimatedPointsAtMin() {
    if (_earnRatio <= 0) return 0;
    final basis = _minOrderValue > _earnableAmount ? _minOrderValue : _earnableAmount;
    return (basis / _earnRatio).floor();
  }

  num _amountToAdd() {
    final gap = _minOrderValue - _earnableAmount;
    return gap > 0 ? gap : 0;
  }

  bool get _isAboveMin => _earnableAmount >= _minOrderValue;
  bool get _hasMinOrderValue => _minOrderValue > 0;

  String _ordinalSuffix(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  String _multStr(double m) =>
      m.toStringAsFixed(m == m.roundToDouble() ? 0 : 1);

  String _bonusCopy() {
    final mult = _multStr(_multiplier);
    if (_orderNumber > 0) return 'Your ${_ordinalSuffix(_orderNumber)} order! ${mult}× bonus';
    return '${mult}× bonus applied!';
  }

  String? _milestoneCopy() {
    final m = _nextMilestone;
    if (m == null) return null;
    final away = (m['orders_away'] as num?)?.toInt() ?? 0;
    final mult = _multStr(double.tryParse(m['multiplier']?.toString() ?? '1') ?? 1.0);
    return '${away == 1 ? '1 more order' : '$away more orders'} → ${mult}× bonus!';
  }

  // Builds the inline copy for the 4 states. Never returns a negative string —
  // when loyalty is off or earn fails, we render nothing (caller decides).
  String _copy() {
    final estPts = _isAboveMin ? _points : _estimatedPointsAtMin();
    if (_isLoggedIn) {
      if (_isAboveMin) return "You'll earn $_points points on this order";
      return 'Add ₹${_amountToAdd().toStringAsFixed(0)} more to earn ~$estPts points';
    }
    // Guest
    if (_isAboveMin) return 'Sign up to earn ~$estPts points on this order';
    return 'Add ₹${_amountToAdd().toStringAsFixed(0)} more + sign up to earn ~$estPts points';
  }

  @override
  Widget build(BuildContext context) {
    if (!ExtensionsUtil.has('loyalty')) return const SizedBox.shrink();
    if (_loading || !_earnEnabled) return const SizedBox.shrink();

    // Product-restricted earn: backend told us this product isn't in the
    // allowed list / category. Rendering the "Add ₹X more …" copy here
    // would lie — the order subscriber would later refuse to credit pts.
    if (_notEligible) return const SizedBox.shrink();

    // Pure no-op when there's nothing meaningful to say: no minimum AND no
    // points to earn yet (e.g. earn_enabled but ratio configured oddly).
    if (!_hasMinOrderValue && _points <= 0) return const SizedBox.shrink();

    final isPositive = _isLoggedIn && _isAboveMin;
    final accentColor = isPositive ? AppColors.primary : Colors.orange.shade700;
    final accentBg = isPositive
        ? AppColors.primary.withOpacity(0.06)
        : Colors.orange.shade50;
    final accentBorder = isPositive
        ? AppColors.primary.withOpacity(0.12)
        : Colors.orange.shade200;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.stars_rounded, color: accentColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _copy(),
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                if (_hasBonus && _isAboveMin)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      _bonusCopy(),
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 10,
                        color: accentColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                if (_milestoneCopy() != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      _milestoneCopy()!,
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700.withOpacity(0.85),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isPositive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    '+$_points',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
