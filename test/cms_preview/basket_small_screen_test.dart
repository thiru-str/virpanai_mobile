// Small-screen guard for the BASKET offer carousel and brand rail, with the
// copy a real grocery store uses (two-line titles, a count line) — the shape
// that overflowed on small Android phones (Annachi, 2026-11-03). Any RenderFlex
// overflow fails the test.
//
//   flutter test test/cms_preview/basket_small_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/basket/basket_sections.dart';

Content _content(String layout, List<Map<String, dynamic>> items) => Content.fromJson({
      'layout_name': layout,
      'layout_title': 'Top brands',
      'layout_option': 'Custom',
      'layout_data': items,
    });

final _offers = [
  {'id': 'o1', 'title': 'Coffee, tea & drinks', 'sub_title': 'Health drinks and everyday favourites', 'feature_text': 'Up to 33% off', 'button_text': 'Shop drinks', 'image': ''},
  {'id': 'o2', 'title': 'Fresh fruits and vegetables delivered', 'sub_title': 'Picked every morning from local farms near you', 'feature_text': 'Flat 20% off today', 'button_text': 'Shop fresh produce', 'image': ''},
];
final _brands = ['Maggi', 'Garnier', 'Harpic', 'Sakthi', 'Aashirvaad', 'Britannia']
    .asMap()
    .entries
    .map((e) => {'id': 'b${e.key}', 'title': e.value, 'sub_title': '${12 + e.key} products', 'image': ''})
    .toList();

Future<void> _pump(WidgetTester tester, Widget child, double width, double scale) async {
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = Size(width * 3, 1400 * 3);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    builder: (ctx, w) => MediaQuery(data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)), child: w!),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  for (final width in [320.0, 360.0]) {
    for (final scale in [1.0, 1.1, 1.3]) {
      testWidgets('BasketOfferCarousel1 @${width.toInt()}w x$scale', (t) async {
        await _pump(t, BasketOfferCarousel1(content: _content('BasketOfferCarousel1', _offers)), width, scale);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox()); // stop the slide timer
      });
      testWidgets('BasketBrandRail1 @${width.toInt()}w x$scale', (t) async {
        await _pump(t, BasketBrandRail1(content: _content('BasketBrandRail1', _brands)), width, scale);
        expect(t.takeException(), isNull);
      });
    }
  }
}
