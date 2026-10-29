/// The backend drops an applied coupon that is no longer eligible when it
/// reads the cart and records why in `cart.metadata.coupon_removed`.
class CouponRemoved {
  final String code;
  final String reason;
  final String at;

  const CouponRemoved({required this.code, required this.reason, required this.at});

  /// Identifies this removal, so a dismissed notice stays dismissed.
  String get key => '$code|$at';

  String get message => 'Coupon $code removed: $reason';

  static CouponRemoved? fromCartMetadata(dynamic metadata) {
    final notice = metadata is Map ? metadata['coupon_removed'] : null;
    if (notice is! Map) return null;
    final code = notice['code']?.toString() ?? '';
    final reason = notice['reason']?.toString() ?? '';
    final at = notice['at']?.toString() ?? '';
    if (code.isEmpty || reason.isEmpty || at.isEmpty) return null;
    return CouponRemoved(code: code, reason: reason, at: at);
  }
}
