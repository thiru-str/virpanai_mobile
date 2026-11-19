import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/ui/minipos/minipos_page.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

void main() {
  const sizes = <Size>[
    Size(280, 640),
    Size(320, 568),
    Size(360, 640),
    Size(393, 852),
    Size(412, 915),
    Size(600, 960),
    Size(800, 360),
  ];
  const scales = [1.0, 1.3, 1.6, 2.0];
  const statuses = ['not_submitted', 'processing', 'active'];

  Future<void> showHome(
      WidgetTester tester, Size size, double scale, String status,
      {VoidCallback? onVendor, VoidCallback? onAction}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final connected = status == 'active';
    await tester.pumpWidget(MaterialApp(
      // Poppins is the app font. Include simulated OS/status/navigation insets
      // and the shell's bottom bar, not a full-height isolated card.
      theme: ThemeData(fontFamily: 'Poppins'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          padding: const EdgeInsets.only(top: 24, bottom: 24),
        ),
        child: child!,
      ),
      home: Scaffold(
        bottomNavigationBar: const SizedBox(height: 72),
        body: MiniPosScaffold(
          appBar: AppBar(title: const Text('MiniPOS')),
          body: MiniPosHomeContent(
            status: status,
            connected: connected,
            onVendor: onVendor ?? () {},
            onOrders: connected ? onAction ?? () {} : null,
            onSettings: connected ? onAction ?? () {} : null,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  for (final size in sizes) {
    for (final scale in scales) {
      for (final status in statuses) {
        testWidgets(
            'home ${size.width}x${size.height} text=$scale status=$status has no overflow',
            (tester) async {
          await showHome(tester, size, scale, status);
          expect(tester.takeException(), isNull);
          expect(find.text('Vendor'), findsOneWidget);
          expect(find.text('Products'), findsNothing);
          expect(find.text('Vendor details'), findsNothing);
          for (final title in ['Orders', 'Settings']) {
            await tester.scrollUntilVisible(find.text(title), 120,
                scrollable: find.byType(Scrollable).first);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final rect = tester.getRect(find.text(title));
            final body = tester.getRect(find.byType(MiniPosHomeContent));
            expect(rect.left, greaterThanOrEqualTo(body.left));
            expect(rect.right, lessThanOrEqualTo(body.right));
            expect(rect.top, greaterThanOrEqualTo(body.top));
            expect(rect.bottom, lessThanOrEqualTo(body.bottom));
          }
        });
      }
    }
  }

  testWidgets('vendor banner grows when the description wraps', (tester) async {
    await showHome(tester, const Size(320, 640), 1.3, 'not_submitted');
    final text = find.text('Add your vendor details to accept payments');
    final card = find.ancestor(of: text, matching: find.byType(Ink)).first;
    final textRect = tester.getRect(text);
    final cardRect = tester.getRect(card);
    expect(cardRect.height, greaterThan(168));
    expect(textRect.bottom, lessThanOrEqualTo(cardRect.bottom - 18));
    expect(tester.takeException(), isNull);
  });

  testWidgets('disconnected sales stay disabled but vendor connection works',
      (tester) async {
    var vendorTaps = 0;
    var salesTaps = 0;
    await showHome(tester, const Size(360, 640), 1, 'not_submitted',
        onVendor: () => vendorTaps++, onAction: () => salesTaps++);
    await tester.tap(find.text('Vendor'));
    expect(vendorTaps, 1);
    await tester.scrollUntilVisible(find.text('Orders'), 120);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orders'));
    expect(salesTaps, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('connected actions remain tappable after scrolling',
      (tester) async {
    var taps = 0;
    await showHome(tester, const Size(320, 568), 2, 'active',
        onAction: () => taps++);
    for (final title in ['Orders', 'Settings']) {
      await tester.scrollUntilVisible(find.text(title), 120);
      await tester.pumpAndSettle();
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
    }
    expect(taps, 2);
    expect(tester.takeException(), isNull);
  });
}
