import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/ui/widgets/home/maison/maison_shared.dart';

const _pink = MaisonVariant('v-pink', 'PINK', Color(0xFFFFC0CB), '', '23950');
const _yellow = MaisonVariant('v-yellow', 'YELLOW', Color(0xFFFFFF00), '', '23950');
const _main = 'https://cdn.example.com/main.webp';
const _yellowPhoto = 'https://cdn.example.com/yellow.webp';

// 1×1 transparent PNG, so no test touches the network.
final _pixel = Uint8List.fromList(const [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
  0, 0, 0, 13, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
]);

Future<void> _open(WidgetTester tester, Map<String, String> photos, {bool fail = false, String? onAddTo}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: MaisonColourSheet(
          item: LayoutDatum.fromJson({'id': 'prod_1', 'title': 'Silk Saree', 'image': _main}),
          variants: const [_pink, _yellow],
          colors: const MaisonColors(Colors.white, Colors.brown, Color(0xFF5A0A1E)),
          onAdd: (_) {},
          loadPhotos: (_, __) async {
            if (fail) throw Exception('offline');
            return photos;
          },
        ),
      ),
    ),
  ));
  await tester.pump();
  await tester.pump();
}

// The first BasketImage is the large photo at the top of the sheet.
String? _shown(WidgetTester t) => t.widget<BasketImage>(find.byType(BasketImage).first).url;

void main() {
  setUp(() => BasketImage.debugProvider = (_) => MemoryImage(_pixel));
  tearDown(() => BasketImage.debugProvider = null);

  testWidgets('picking a colour shows that colour\'s photo', (t) async {
    await _open(t, const {'v-yellow': _yellowPhoto});
    expect(_shown(t), _main);

    await t.tap(find.text('YELLOW'));
    await t.pump();
    expect(_shown(t), _yellowPhoto);
    expect(find.text('Colour · YELLOW'), findsOneWidget);
  });

  testWidgets('a tile shows the colour\'s own photo', (t) async {
    await _open(t, const {'v-yellow': _yellowPhoto});
    final urls = t.widgetList<BasketImage>(find.byType(BasketImage)).map((b) => b.url).toList();
    expect(urls.where((u) => u == _yellowPhoto), hasLength(1));
  });

  testWidgets('a colour with no photo says so instead of passing off another', (t) async {
    await _open(t, const {'v-yellow': _yellowPhoto});
    expect(find.text('Photo shows another colour'), findsOneWidget);

    await t.tap(find.text('YELLOW'));
    await t.pump();
    expect(find.text('Photo shows another colour'), findsNothing);
  });

  testWidgets('with photos unavailable the sheet still works', (t) async {
    await _open(t, const {}, fail: true);
    expect(t.takeException(), isNull);
    expect(_shown(t), _main);
    await t.tap(find.text('YELLOW'));
    await t.pump();
    expect(find.text('Colour · YELLOW'), findsOneWidget);
  });
}
