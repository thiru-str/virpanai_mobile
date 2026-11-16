import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/basket/basket_options_sheet.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/utility/variant_order.dart';

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

  // ── order and default: the same rule as the product page ──────────────────
  // The home payload can list variants most expensive first; the product page
  // shows them cheapest first and opens on the cheapest in stock.
  Map<String, dynamic> candy({String cardVariant = 'v-12'}) => {
        'id': 'prod_candy',
        'title': 'Groundnut Candy',
        'image': _main,
        'prices': {'selling_price': '10', 'original_price': '12'},
        'variant_details': {'variant_id': cardVariant},
        'product_options': [
          {'title': 'Quantity', 'values': ['50Pcs', '24Pcs', '12Pcs']}
        ],
        'product_variants': [
          {'variant_id': 'v-50', 'variant_price': '35', 'variant_options': [{'option_title': 'optval_x', 'option_value': '50Pcs'}]},
          {'variant_id': 'v-24', 'variant_price': '20', 'variant_options': [{'option_title': 'optval_y', 'option_value': '24Pcs'}]},
          {'variant_id': 'v-12', 'variant_price': '10', 'variant_options': [{'option_title': 'optval_z', 'option_value': '12Pcs'}]},
        ],
      };

  List<String> chips(WidgetTester t) => t
      .widgetList<Text>(find.byType(Text))
      .map((x) => x.data ?? '')
      .where((x) => const {'12Pcs', '24Pcs', '50Pcs'}.contains(x))
      .skip(1) // the first is the picked option's name under the title
      .toList();

  Future<List<String>> openCandy(WidgetTester t, Completer<({String label, List<BasketOption> options})> detail) async {
    final added = <String>[];
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(
              child: BasketOptionsSheet(
        item: LayoutDatum.fromJson(candy()),
        colors: const BasketColors(Colors.white, Color(0xFF0F7A3D), Colors.white, kBasketInk),
        onCartQtyChanged: (d, id) => added.add('$d:$id'),
        load: (_, __) => detail.future,
      ))),
    ));
    await t.pump();
    return added;
  }

  testWidgets('opens cheapest first on the cheapest option, with the right heading, before details load', (t) async {
    final detail = Completer<({String label, List<BasketOption> options})>();
    final added = await openCandy(t, detail);
    expect(chips(t), ['12Pcs', '24Pcs', '50Pcs']);
    expect(find.text('CHOOSE QUANTITY'), findsOneWidget);
    expect(find.text('17% OFF'), findsOneWidget); // the card's MRP for its own variant
    await t.tap(find.text('Add to cart'));
    expect(added, ['1:v-12']);
  });

  testWidgets('loading the details moves nothing: same order, pick, price and heading', (t) async {
    final detail = Completer<({String label, List<BasketOption> options})>();
    await openCandy(t, detail);
    List<String> visible() => t
        .widgetList<Text>(find.byType(Text))
        .map((x) => x.data ?? '')
        .where((x) => x.isNotEmpty && !x.contains('Add to cart'))
        .toList();
    final before = visible();
    // the API returns them in yet another order
    detail.complete((label: 'Quantity', options: basketSortOptions(const [
      BasketOption('v-24', '24Pcs', '20', '20', '', true),
      BasketOption('v-50', '50Pcs', '35', '35', '', true),
      BasketOption('v-12', '12Pcs', '10', '12', '', true),
    ])));
    await t.pump();
    await t.pump();
    expect(visible(), before);
  });

  testWidgets('when the cheapest turns out sold out, it opens on the next cheapest like the product page', (t) async {
    final detail = Completer<({String label, List<BasketOption> options})>();
    final added = await openCandy(t, detail);
    detail.complete((label: 'Quantity', options: basketSortOptions(const [
      BasketOption('v-12', '12Pcs', '10', '12', '', false),
      BasketOption('v-24', '24Pcs', '20', '20', '', true),
      BasketOption('v-50', '50Pcs', '35', '35', '', true),
    ])));
    await t.pump();
    await t.pump();
    await t.tap(find.text('Add to cart'));
    expect(added, ['1:v-24']);
  });

  testWidgets("a chip the shopper tapped stays picked when the details arrive", (t) async {
    final detail = Completer<({String label, List<BasketOption> options})>();
    final added = await openCandy(t, detail);
    await t.tap(find.text('50Pcs').first);
    await t.pump();
    detail.complete((label: 'Quantity', options: basketSortOptions(const [
      BasketOption('v-12', '12Pcs', '10', '12', '', true),
      BasketOption('v-24', '24Pcs', '20', '20', '', true),
      BasketOption('v-50', '50Pcs', '35', '35', '', true),
    ])));
    await t.pump();
    await t.pump();
    await t.tap(find.text('Add to cart'));
    expect(added, ['1:v-50']);
  });

  test('variant order: cheapest first, equal prices keep their order, unknown prices last', () {
    final sorted = sortCheapestFirst(['c:30', 'a:10', 'x:', 'b:10', 'd:5'], (s) => variantPriceValue(s.split(':')[1]));
    expect(sorted, ['d:5', 'a:10', 'b:10', 'c:30', 'x:']);
    expect(cheapestInStock(sorted, (s) => s != 'd:5'), 'a:10');
    expect(cheapestInStock(<String>[], (_) => true), isNull);
  });
}
