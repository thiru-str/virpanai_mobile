import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/minipos/minipos_temp_cart.dart';

Map<String, dynamic> _phone(String imei, String variantId) => {
      'imei': imei,
      'product_id': 'product-$variantId',
      'variant_id': variantId,
      'product_title': 'Test phone',
      'variant_title': variantId,
      'thumbnail': '',
      'selling_price': 1500000,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cart = MiniPosTempCart.instance;

  setUp(cart.clear);
  tearDown(cart.clear);

  test('MiniPOS cart accepts exactly one IMEI per checkout', () {
    cart.add(_phone('123456789012345', 'variant-1'));

    expect(cart.itemCount, 1);
    expect(
      () => cart.add(_phone('987654321098765', 'variant-2')),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('Only one phone'),
        ),
      ),
    );
    expect(cart.itemCount, 1);
  });
}
