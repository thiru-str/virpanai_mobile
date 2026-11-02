import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/widgets/floating_cart.dart';

Future<void> _open(WidgetTester tester, {VoidCallback? onTap}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      floatingActionButton: FloatingCart(onTap: onTap),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ),
  ));
  await tester.pump();
}

Future<void> _publish(WidgetTester tester, int items) async {
  eventBus.fire(ViewCartModel(items, const []));
  await tester.pump(); // delivers the event
  await tester.pump(); // draws it
}

void main() {
  testWidgets('hidden until the cart holds something', (t) async {
    await _open(t);
    await _publish(t, 0);
    expect(find.textContaining('Item'), findsNothing);

    await _publish(t, 2);
    expect(find.text('2 Items'), findsOneWidget);
  });

  testWidgets('follows the count, and leaves when the cart empties', (t) async {
    await _open(t);
    await _publish(t, 1);
    expect(find.text('1 Item'), findsOneWidget);

    await _publish(t, 3);
    expect(find.text('3 Items'), findsOneWidget);

    await _publish(t, 0);
    expect(find.textContaining('Item'), findsNothing);
  });

  testWidgets('tapping runs the page\'s own action', (t) async {
    var opened = 0;
    await _open(t, onTap: () => opened++);
    await _publish(t, 1);
    await t.tap(find.text('1 Item'));
    expect(opened, 1);
  });
}
