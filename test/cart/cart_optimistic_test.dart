import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/utility/cart_optimistic.dart';

void main() {
  final fee = {
    'id': 'li_fee',
    'quantity': 1,
    'metadata': {'type': 'platform_fee'},
  };
  final loyalty = {
    'id': 'li_loyalty',
    'quantity': 1,
    'metadata': {'type': 'loyalty_discount'},
  };
  CartJson cart() => {
        'id': 'cart_1',
        'total': 500,
        'items': [
          {'id': 'li_1', 'variant_id': 'var_1', 'quantity': 2, 'unit_price': 100},
          fee,
          loyalty,
        ],
      };

  test('adding a new variant appends a provisional line the cart model can read', () {
    final view = addItem(
      cart(),
      const ProvisionalLine(variantId: 'var_2', quantity: 1, productTitle: 'Tea'),
    );
    final added = findLineByVariant(view, 'var_2')!;
    expect(added['id'], provisionalLineId('var_2'));
    expect(isProvisionalLineId(added['id'] as String), isTrue);
    expect(CartResponse.fromJson({'cart': view}).cart!.items!.length, 4);
  });

  test('adding an existing variant raises its quantity', () {
    final view = addItem(cart(), const ProvisionalLine(variantId: 'var_1', quantity: 3));
    expect(findLineByVariant(view, 'var_1')!['quantity'], 5);
  });

  test('never changes totals or backend lines', () {
    final view = setQuantity(cart(), 'li_1', 7);
    expect(view['total'], 500);
    expect(setQuantity(cart(), 'li_fee', 4), cart());
    expect(removeLine(cart(), 'li_loyalty'), cart());
  });

  test('a quantity of zero removes the line', () {
    expect(findLineByVariant(setQuantity(cart(), 'li_1', 0), 'var_1'), isNull);
  });

  test('a provisional id resolves to the real line once the server has it', () {
    expect(resolveLine(cart(), provisionalLineId('var_1'))!['id'], 'li_1');
    expect(resolveLine(cart(), provisionalLineId('var_missing')), isNull);
  });

  test('badge counts product quantities only', () {
    expect(countCartItems(cart()), 2);
    expect(variantQuantities(cart()), {'var_1': 2});
  });

  test('lines differing from the server cart are pending', () {
    final server = cart();
    final view = addItem(setQuantity(server, 'li_1', 3),
        const ProvisionalLine(variantId: 'var_2', quantity: 1));
    expect(unconfirmedLineIds(server, view), {'li_1', provisionalLineId('var_2')});
    expect(unconfirmedLineIds(server, server), isEmpty);
  });
}
