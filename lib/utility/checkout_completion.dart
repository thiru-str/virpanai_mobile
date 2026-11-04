// How the app reads the result of POST /store/custom-carts/:id/complete and of
// gateway redirects to /order/transaction/failed/<id>. When completion fails
// the backend creates no order and refunds an online payment itself; the app
// only explains what happened. Wording matches the web storefront.

const String outOfStockCode = 'OUT_OF_STOCK';
const String paymentFailedCode = 'PAYMENT_FAILED';
const String placeOrderFailedCode = 'PLACE_ORDER_FAILED';

const String _inventoryFailureMessage =
    'Some items in your cart are no longer available in the requested quantity. Please update your cart.';
const String _defaultFailureMessage = 'Unable to place your order. Please try again.';

final RegExp _inventoryFailurePattern =
    RegExp(r'inventory|not enough stock|out of stock', caseSensitive: false);

const Map<String, String> _refundNotices = {
  'initiated':
      'Your full refund has been initiated and will reach your account in 5–7 working days.',
  'pending': 'Your refund is being processed by our team.',
  'not_required': 'You have not been charged.',
  'failed':
      'We could not start your refund automatically — our team has been notified and will refund you.',
};

/// The shopper-facing sentence for a refund status, or null when there is none.
String? refundNotice(String? refundStatus) => _refundNotices[refundStatus];

class CompletionFailure {
  final String code;
  final String message;

  /// `out_of_stock` or `payment_failed` when the backend settled the failure.
  final String? reason;
  final String? refundStatus;

  const CompletionFailure({
    required this.code,
    required this.message,
    this.reason,
    this.refundStatus,
  });

  bool get isOutOfStock => code == outOfStockCode;

  /// Failures checkout cannot fix — stock that ran out, or a charged payment
  /// that had to be refunded — get the full failure screen; anything else is
  /// shown as a message on the cart.
  bool get showsFailureScreen {
    if (reason == null || refundStatus == null) return false;
    return code == outOfStockCode ||
        (code == paymentFailedCode && refundStatus != 'not_required');
  }

  /// A completion response body that is not an order.
  factory CompletionFailure.fromBody(dynamic body) {
    final map = body is Map ? body : const {};
    final code = map['code']?.toString();
    final refund = map['refund_status']?.toString();
    final message = _bodyMessage(map);
    if ((code == outOfStockCode || code == paymentFailedCode) && refund != null) {
      return CompletionFailure(
        code: code!,
        message: message,
        reason: map['type']?.toString(),
        refundStatus: refund,
      );
    }
    if (_inventoryFailurePattern.hasMatch(message)) {
      return const CompletionFailure(
        code: outOfStockCode,
        message: _inventoryFailureMessage,
      );
    }
    return CompletionFailure(
      code: placeOrderFailedCode,
      message: message.isNotEmpty ? message : _defaultFailureMessage,
    );
  }

  /// A gateway callback redirect, e.g.
  /// `<store>/order/transaction/failed/<id>?reason=out_of_stock&refund=initiated`.
  static CompletionFailure? fromFailedRedirect(String url) {
    final params = Uri.tryParse(url)?.queryParameters ?? const <String, String>{};
    final reason = params['reason'];
    final refund = params['refund'];
    if (reason == null || refund == null) return null;
    return CompletionFailure(
      code: reason == 'out_of_stock' ? outOfStockCode : paymentFailedCode,
      message: '',
      reason: reason,
      refundStatus: refund,
    );
  }

  static String _bodyMessage(Map map) {
    final message = map['message'];
    if (message is String && message.trim().isNotEmpty) return message.trim();
    final error = map['error'];
    if (error is Map && error['message'] is String) {
      return (error['message'] as String).trim();
    }
    return '';
  }
}

class CartCompletionResult {
  final String? orderId;
  final CompletionFailure? failure;

  const CartCompletionResult.order(String this.orderId) : failure = null;
  const CartCompletionResult.failed(CompletionFailure this.failure) : orderId = null;

  /// Reads a 200 completion body; Medusa answers `type: "cart"` when it could
  /// not create the order.
  factory CartCompletionResult.fromSuccessBody(dynamic body) {
    final map = body is Map ? body : const {};
    final order = map['order'];
    final orderId = order is Map ? order['id']?.toString() : null;
    if (map['type'] == 'order' && orderId != null && orderId.isNotEmpty) {
      return CartCompletionResult.order(orderId);
    }
    return CartCompletionResult.failed(CompletionFailure.fromBody(map));
  }
}
