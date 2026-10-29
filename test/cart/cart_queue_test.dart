import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/utility/cart_optimistic.dart';
import 'package:waioz/utility/cart_queue.dart';

CartJson cartWith(List<Map<String, dynamic>> items, {num total = 0}) =>
    {'id': 'cart_1', 'total': total, 'items': items};

Map<String, dynamic> line(String id, String variantId, int quantity) =>
    {'id': id, 'variant_id': variantId, 'quantity': quantity, 'metadata': {}};

class Harness {
  DateTime clock = DateTime(2026);
  CartJson server;
  final published = <({CartJson view, bool syncing})>[];
  final errors = <String>[];
  final notices = <String>[];
  int reconciles = 0;
  late final CartQueue queue;

  Harness(this.server) {
    queue = CartQueue(CartQueueDeps(
      readCart: () => server,
      publish: (view, _, syncing) => published.add((view: view, syncing: syncing)),
      reconcile: () async {
        reconciles++;
        return server;
      },
      reportError: errors.add,
      reportNotice: notices.add,
      // Waiting moves the fake clock instead of real time.
      delay: (duration) async => clock = clock.add(duration),
      now: () => clock,
    ));
  }

  CartJson get lastView => published.last.view;
}

void main() {
  group('CartQueue', () {
    test('coalesces rapid quantity taps on one line into one request', () async {
      final harness = Harness(cartWith([line('li_1', 'var_1', 1)]));
      final sent = <int>[];
      Future<CartMutationResult> send(String id, int qty) async {
        sent.add(qty);
        harness.server = cartWith([line(id, 'var_1', qty)]);
        return CartMutationResult(cart: harness.server);
      }

      Future<CartMutationResult> remove(String id) async => const CartMutationResult();

      final first = harness.queue.setLineQuantity('li_1', 2, send: send, remove: remove);
      expect(cartLines(harness.lastView).single['quantity'], 2);
      final second = harness.queue.setLineQuantity('li_1', 3, send: send, remove: remove);
      expect(cartLines(harness.lastView).single['quantity'], 3);
      final third = harness.queue.setLineQuantity('li_1', 4, send: send, remove: remove);

      expect(await first, isNull, reason: 'superseded taps resolve null');
      expect(await second, isNull);
      expect((await third)?.cart, isNotNull);
      expect(sent, [4]);
      expect(harness.published.last.syncing, isFalse);
      expect(cartLines(harness.lastView).single['quantity'], 4);
    });

    test('never runs two mutations at once and keeps their order', () async {
      final harness = Harness(cartWith([]));
      var inFlight = 0;
      var maxInFlight = 0;
      final order = <String>[];

      Future<CartMutationResult> slow(String name) async {
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        await Future<void>.delayed(Duration.zero);
        order.add(name);
        inFlight--;
        return const CartMutationResult();
      }

      final a = harness.queue.enqueue((_) => slow('a'));
      final b = harness.queue.enqueue((_) => slow('b'));
      final c = harness.queue.enqueue((_) => slow('c'));
      await Future.wait([a, b, c]);

      expect(maxInFlight, 1);
      expect(order, ['a', 'b', 'c']);
    });

    test('a refused add disappears from the cart and reports the server message',
        () async {
      final harness = Harness(cartWith([line('li_1', 'var_1', 1)]));
      final result = harness.queue.enqueue(
        (_) async => throw const CartMutationException('Only 0 left in stock'),
        optimistic: (cart) =>
            addItem(cart, const ProvisionalLine(variantId: 'var_2', quantity: 1)),
        rollbackMessage: 'Could not add to cart',
      );

      expect(countCartItems(harness.lastView), 2, reason: 'shows instantly');
      expect(harness.published.last.syncing, isTrue);
      expect(isOptimisticCart(harness.lastView), isTrue);

      expect(await result, isNull);
      expect(harness.errors, ['Only 0 left in stock']);
      expect(harness.reconciles, 1);
      expect(findLineByVariant(harness.lastView, 'var_2'), isNull);
      expect(countCartItems(harness.lastView), 1);
      expect(variantQuantities(harness.lastView).containsKey('var_2'), isFalse);
      expect(harness.published.last.syncing, isFalse);
    });

    test('uses the rollback message when a request fails without one', () async {
      final harness = Harness(cartWith([]));
      await harness.queue.enqueue(
        (_) async => throw StateError('socket closed'),
        rollbackMessage: 'Could not add to cart',
      );
      expect(harness.errors, ['Could not add to cart']);
    });

    test('shows the notice of a clamped update', () async {
      final harness = Harness(cartWith([line('li_1', 'var_1', 5)]));
      await harness.queue.setLineQuantity(
        'li_1',
        4,
        send: (id, qty) async => CartMutationResult(
          cart: cartWith([line(id, 'var_1', 2)]),
          notice: 'Quantity adjusted to 2 — only 2 left in stock',
        ),
        remove: (_) async => const CartMutationResult(),
      );
      expect(harness.notices, ['Quantity adjusted to 2 — only 2 left in stock']);
      expect(cartLines(harness.lastView).single['quantity'], 2);
    });

    test('a change on a provisional line is sent with the id the server created',
        () async {
      final harness = Harness(cartWith([]));
      String? updatedId;
      harness.queue.enqueue(
        (_) async => CartMutationResult(cart: cartWith([line('li_new', 'var_9', 1)])),
        optimistic: (cart) =>
            addItem(cart, const ProvisionalLine(variantId: 'var_9', quantity: 1)),
      );
      final update = harness.queue.setLineQuantity(
        provisionalLineId('var_9'),
        2,
        send: (id, qty) async {
          updatedId = id;
          return CartMutationResult(cart: cartWith([line(id, 'var_9', qty)]));
        },
        remove: (_) async => const CartMutationResult(),
      );
      expect(cartLines(harness.lastView).single['quantity'], 2);
      await update;
      expect(updatedId, 'li_new');
    });

    test('removing a line drops its waiting quantity change', () async {
      final harness = Harness(cartWith([line('li_1', 'var_1', 1)]));
      var updates = 0;
      final update = harness.queue.setLineQuantity(
        'li_1',
        3,
        send: (id, qty) async {
          updates++;
          return const CartMutationResult();
        },
        remove: (_) async => const CartMutationResult(),
      );
      final removal = harness.queue.removeCartLine(
        'li_1',
        send: (id) async => CartMutationResult(cart: cartWith([])),
      );
      expect(cartLines(harness.lastView), isEmpty);
      expect(await update, isNull);
      await removal;
      expect(updates, 0);
      expect(countCartItems(harness.lastView), 0);
    });

    test('a cart read while mutations are pending does not replace the view',
        () async {
      final harness = Harness(cartWith([line('li_1', 'var_1', 1)]));
      final gate = Completer<CartMutationResult>();
      final pending = harness.queue.enqueue(
        (_) => gate.future,
        optimistic: (cart) => setQuantity(cart, 'li_1', 2),
      );
      harness.queue.acceptServerCart(cartWith([line('li_1', 'var_1', 1)]));
      expect(cartLines(harness.lastView).single['quantity'], 2);

      harness.server = cartWith([line('li_1', 'var_1', 2)]);
      gate.complete(const CartMutationResult());
      await pending;
      // Succeeded without a cart: re-read once idle.
      expect(harness.reconciles, 1);
      expect(cartLines(harness.lastView).single['quantity'], 2);
    });
  });
}
