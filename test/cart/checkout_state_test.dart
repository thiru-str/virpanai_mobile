import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/utility/checkout_completion.dart';
import 'package:waioz/utility/coupon_removed.dart';
import 'package:waioz/utility/payment_provider_selection.dart';

Cart cartWith({Map<String, dynamic>? metadata, List<Map<String, dynamic>> sessions = const []}) =>
    Cart.fromJson({
      'id': 'cart_1',
      'metadata': metadata,
      'items': [],
      'payment_collection': {'id': 'pc_1', 'payment_sessions': sessions},
    });

void main() {
  group('cart completion', () {
    test('an order body is an order', () {
      final result = CartCompletionResult.fromSuccessBody({
        'type': 'order',
        'order': {'id': 'order_1'},
      });
      expect(result.orderId, 'order_1');
      expect(result.failure, isNull);
    });

    test('a 200 cart body is not an order', () {
      final result = CartCompletionResult.fromSuccessBody({
        'type': 'cart',
        'error': {'message': 'Payment authorization failed'},
      });
      expect(result.orderId, isNull);
      expect(result.failure!.message, 'Payment authorization failed');
      expect(result.failure!.showsFailureScreen, isFalse);
    });

    test('a settled out-of-stock failure gets the failure screen', () {
      final failure = CompletionFailure.fromBody({
        'type': 'out_of_stock',
        'code': 'OUT_OF_STOCK',
        'message': 'One or more items went out of stock.',
        'refund_status': 'initiated',
      });
      expect(failure.showsFailureScreen, isTrue);
      expect(refundNotice(failure.refundStatus),
          startsWith('Your full refund has been initiated'));
    });

    test('a payment failure with nothing charged stays on the cart', () {
      final failure = CompletionFailure.fromBody({
        'type': 'payment_failed',
        'code': 'PAYMENT_FAILED',
        'message': 'Payment failed.',
        'refund_status': 'not_required',
      });
      expect(failure.showsFailureScreen, isFalse);
      expect(refundNotice('not_required'), 'You have not been charged.');
    });

    test('a refunded payment failure gets the failure screen', () {
      final failure = CompletionFailure.fromBody({
        'type': 'payment_failed',
        'code': 'PAYMENT_FAILED',
        'message': 'Payment failed.',
        'refund_status': 'failed',
      });
      expect(failure.showsFailureScreen, isTrue);
    });

    test('an unsettled stock error is reported as out of stock', () {
      final failure = CompletionFailure.fromBody({'message': 'Not enough stock for variant'});
      expect(failure.code, outOfStockCode);
      expect(failure.showsFailureScreen, isFalse);
    });

    test('reads a gateway failure redirect', () {
      final failure = CompletionFailure.fromFailedRedirect(
          'https://shop.test/order/transaction/failed/cart_1?reason=out_of_stock&refund=pending')!;
      expect(failure.code, outOfStockCode);
      expect(failure.refundStatus, 'pending');
      expect(failure.showsFailureScreen, isTrue);
      expect(CompletionFailure.fromFailedRedirect('https://shop.test/order/transaction/failed/x'),
          isNull);
    });
  });

  group('payment provider preselection', () {
    final razorpay = {'id': 'ps_1', 'provider_id': 'pp_razorpay_razorpay', 'status': 'pending'};
    final paytm = {'id': 'ps_2', 'provider_id': 'pp_paytm_paytm', 'status': 'pending'};

    test("the shopper's stored selection wins over a leftover session", () {
      final cart = cartWith(
        metadata: {'last_payment_provider_id': 'pp_razorpay_razorpay'},
        sessions: [paytm, razorpay],
      );
      expect(
          preferredPaymentProviderId(cart,
              availableProviderIds: ['pp_razorpay_razorpay', 'pp_paytm_paytm']),
          'pp_razorpay_razorpay');
      expect(sessionForProvider(cart, 'pp_razorpay_razorpay')!.id, 'ps_1');
    });

    test('a stored provider the store no longer offers is ignored', () {
      final cart = cartWith(
        metadata: {'last_payment_provider_id': 'pp_payu_payu'},
        sessions: [paytm],
      );
      expect(
          preferredPaymentProviderId(cart,
              availableProviderIds: ['pp_paytm_paytm', 'pp_system_default']),
          'pp_paytm_paytm');
    });

    test('the wallet session of a split payment is not the one to pay with', () {
      final cart = cartWith(sessions: [
        {'id': 'ps_w', 'provider_id': 'pp_wallet_wallet', 'status': 'pending'},
        razorpay,
      ]);
      expect(preferredPaymentProviderId(cart, availableProviderIds: const []),
          'pp_razorpay_razorpay');
    });

    test('falls back to cash on delivery', () {
      expect(preferredPaymentProviderId(cartWith(), availableProviderIds: const []),
          cashOnDeliveryProviderId);
      expect(sessionForProvider(cartWith(), 'pp_razorpay_razorpay'), isNull);
    });
  });

  group('coupon removed notice', () {
    test('reads the reason from cart metadata', () {
      final notice = CouponRemoved.fromCartMetadata({
        'coupon_removed': {'code': 'SAVE10', 'reason': 'Minimum order is ₹500', 'at': '2026-10-16'},
      })!;
      expect(notice.message, 'Coupon SAVE10 removed: Minimum order is ₹500');
      expect(notice.key, 'SAVE10|2026-10-16');
    });

    test('ignores incomplete metadata', () {
      expect(CouponRemoved.fromCartMetadata({'coupon_removed': {'code': 'X'}}), isNull);
      expect(CouponRemoved.fromCartMetadata(null), isNull);
    });
  });
}
