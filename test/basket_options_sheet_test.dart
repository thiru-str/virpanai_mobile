import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/basket/basket_options_sheet.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';

const _main = 'https://cdn.example.com/rice.webp';
const _bagPhoto = 'https://cdn.example.com/rice-5kg.webp';
const _options = [
  BasketOption('v-1kg', '1 kg', '95', '120', '', true),
  BasketOption('v-5kg', '5 kg', '440', '550', _bagPhoto, true),
  BasketOption('v-10kg', '10 kg', '860', '1100', '', false),
];

// 1×1 transparent PNG, so no test touches the network.
final _pixel = Uint8List.fromList(const [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
  0, 0, 0, 13, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
]);

Future<List<String>> _open(WidgetTester tester, {bool fail = false, List<BasketOption> options = _options}) async {
  final added = <String>[];
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: BasketOptionsSheet(
          item: LayoutDatum.fromJson({'id': 'prod_rice', 'title': 'Sona Masoori Rice', 'image': _main}),
          colors: const BasketColors(Colors.white, Color(0xFF0F7A3D), Colors.white, kBasketInk),
          onCartQtyChanged: (delta, id) => added.add('$delta:$id'),
          load: (_, __) async {
            if (fail) throw Exception('offline');
            return (label: 'Weight', options: options);
          },
        ),
      ),
    ),
  ));
  await tester.pump();
  await tester.pump();
  return added;
}

// The first BasketImage is the packshot at the top of the sheet.
String? _shown(WidgetTester t) => t.widget<BasketImage>(find.byType(BasketImage).first).url;

void main() {
  setUp(() => BasketImage.debugProvider = (_) => MemoryImage(_pixel));
  tearDown(() => BasketImage.debugProvider = null);

  testWidgets('names the option the way the product does', (t) async {
    await _open(t);
    expect(find.text('CHOOSE WEIGHT'), findsOneWidget);
    expect(find.text('1 kg'), findsWidgets);
  });

  testWidgets('picking an option shows its own price, MRP, saving and photo', (t) async {
    await _open(t);
    expect(_shown(t), _main);

    await t.tap(find.text('5 kg').first);
    await t.pump();
    expect(_shown(t), _bagPhoto);
    expect(find.text('₹440'), findsWidgets);
    expect(find.text('₹550'), findsOneWidget);
    expect(find.text('20% OFF'), findsOneWidget);
  });

  testWidgets('adds the picked option, not the first one', (t) async {
    final added = await _open(t);
    await t.tap(find.text('5 kg').first);
    await t.pump();
    await t.tap(find.text('Add to cart'));
    expect(added, ['1:v-5kg']);
  });

  testWidgets('a sold-out option cannot be picked or added', (t) async {
    final added = await _open(t);
    expect(find.text('Sold out'), findsOneWidget);
    await t.tap(find.text('10 kg'));
    await t.pump();
    expect(_shown(t), _main);
    await t.tap(find.text('Add to cart'));
    expect(added, ['1:v-1kg']);
  });

  testWidgets('opens on the first option in stock', (t) async {
    final added = await _open(t, options: const [
      BasketOption('v-500g', '500 g', '50', '', '', false),
      BasketOption('v-1kg', '1 kg', '95', '', '', true),
    ]);
    await t.tap(find.text('Add to cart'));
    expect(added, ['1:v-1kg']);
  });

  testWidgets('with the product unreachable and no options it offers the page', (t) async {
    await _open(t, fail: true);
    expect(t.takeException(), isNull);
    expect(find.text("Couldn't load the options"), findsOneWidget);
    expect(find.text('View product'), findsOneWidget);
  });
}
