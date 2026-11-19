import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/minipos/minipos_cart_widgets.dart';

void main() {
  testWidgets('cart CTA does not reveal subtotal, platform fee or total',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MiniPosCartTotalBar(onCheckout: () {}),
      ),
    ));

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Choose card or EMI securely'), findsOneWidget);
    expect(find.text('Total'), findsNothing);
    expect(find.textContaining('Subtotal'), findsNothing);
    expect(find.textContaining('Platform fee'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [280.0, 320.0, 393.0]) {
    testWidgets('cart CTA fits ${width}px width at 2x text', (tester) async {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: MiniPosCartTotalBar(onCheckout: () {}),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
