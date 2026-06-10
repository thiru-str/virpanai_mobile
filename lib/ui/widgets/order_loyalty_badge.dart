import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../utility/extensions_util.dart';
import '../../utility/font_utils.dart';

/// Shows loyalty points context on the order detail page.
/// Three states, driven by server response:
///   - earned      → "You earned X loyalty points" (green, from stored transaction)
///   - will_earn   → "You'll earn X pts on delivery" (amber)
///   - not_eligible → "Not eligible for loyalty points" (grey, for orders placed before loyalty was enabled)
/// Cancelled orders render nothing.
class OrderLoyaltyBadge extends StatefulWidget {
  final num orderTotal;
  final String orderStatus; // e.g. 'pending', 'completed', 'canceled'
  final String paymentStatus; // e.g. 'captured', 'pending', 'not_paid'
  final String? orderId;

  const OrderLoyaltyBadge({
    super.key,
    required this.orderTotal,
    required this.orderStatus,
    required this.paymentStatus,
    this.orderId,
  });

  @override
  State<OrderLoyaltyBadge> createState() => _OrderLoyaltyBadgeState();
}

class _OrderLoyaltyBadgeState extends State<OrderLoyaltyBadge>
    with SingleTickerProviderStateMixin {
  String _status = '';
  int _points = 0;
  int _basePoints = 0;
  double _multiplier = 1.0;
  bool _ruleApplied = false;
  bool _loading = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get _isCancelled =>
      widget.orderStatus == 'canceled' || widget.orderStatus == 'cancelled';

  // Net paid amount the customer actually paid for points-earn purposes.
  // Negative or zero means loyalty/discounts covered the full order, in which
  // case no points are earned — the loading skeleton would just flash orange
  // and disappear, which read as a UI bug to QA. Compute eagerly so we can
  // skip the skeleton entirely.
  bool get _hasZeroEarnableTotal => widget.orderTotal <= 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Skip the network round-trip + loading skeleton when earn is already
    // guaranteed to be 0 from local math. Avoids the orange flash.
    if (_hasZeroEarnableTotal) {
      _loading = false;
      return;
    }
    _load();
  }

  Future<void> _load() async {
    if (_isCancelled) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final resp = await ApiService()
          .getLoyaltyPreview(widget.orderTotal, orderId: widget.orderId);
      final data = resp.data;
      if (data['status'] == true && data['data'] != null) {
        final d = data['data'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _status = (d['status'] ?? '').toString();
            _points = d['points_to_earn'] ?? 0;
            _basePoints = d['base_points'] ?? _points;
            _multiplier =
                double.tryParse(d['multiplier']?.toString() ?? '1') ?? 1.0;
            _ruleApplied = d['rule_applied'] == true;
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
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ExtensionsUtil.has('loyalty')) return const SizedBox.shrink();
    if (_isCancelled) return const SizedBox.shrink();
    // Pre-empt the loading flicker — earn is already 0 by local math.
    if (_hasZeroEarnableTotal) return const SizedBox.shrink();

    if (_loading) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.amber.shade50.withOpacity(_pulseAnimation.value),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade100),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.stars_rounded,
                  color: Colors.amber.withOpacity(_pulseAnimation.value),
                  size: 20),
              const SizedBox(width: 10),
              Container(
                width: 180,
                height: 13,
                decoration: BoxDecoration(
                  color:
                      Colors.amber.shade100.withOpacity(_pulseAnimation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Item 3 (QA): ineligible orders render nothing (no negative chip).
    if (_status == 'not_eligible') return const SizedBox.shrink();

    if (_points <= 0) return const SizedBox.shrink();

    final bool hasMultiplier = _ruleApplied && _multiplier > 1.01;
    final String multiplierDisplay = _multiplier == _multiplier.toInt()
        ? '${_multiplier.toInt()}'
        : _multiplier.toStringAsFixed(1);

    // Already earned — green confirmed badge.
    if (_status == 'earned') {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: Colors.green.shade700, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You earned $_points loyalty points',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                    Text(
                      'Credited to your loyalty wallet',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 11,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+$_points pts',
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Eligible, pending delivery — amber "will earn" badge.
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.stars_rounded,
                  color: Colors.amber, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You\'ll earn $_points pts on delivery',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  if (hasMultiplier)
                    Text(
                      '$_basePoints base pts × ${multiplierDisplay}× bonus rule',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 11,
                        color: Colors.orange.shade600,
                      ),
                    )
                  else
                    Text(
                      'Points credited after order is delivered',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 11,
                        color: Colors.orange.shade600,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+$_points',
                style: FontUtils.primaryFontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
