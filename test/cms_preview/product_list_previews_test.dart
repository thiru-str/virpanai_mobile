// Golden harness for the NEW native product-list widgets (Area 1 mobile batch 1).
// Mirrors new_list_previews_test.dart. Generate:
//   flutter test test/cms_preview/product_list_previews_test.dart --update-goldens
// Output: test/cms_preview/goldens/<LayoutName>.png

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_grid_two1.dart';
import 'package:waioz/ui/widgets/home/product_rail_compact1.dart';
import 'package:waioz/ui/widgets/home/product_list_stack1.dart';
import 'package:waioz/ui/widgets/home/product_deal_grid1.dart';
import 'package:waioz/ui/widgets/home/product_editorial_rail1.dart';
import 'package:waioz/ui/widgets/home/product_quick_add_grid1.dart';

Future<ByteData> _bytes(String path) async =>
    ByteData.view((await File(path).readAsBytes()).buffer);

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)..addFont(_bytes(path));
  await loader.load();
}

Future<void> _loadMaterialIcons() async {
  final env = Platform.environment;
  final root = env['FLUTTER_ROOT'];
  final candidates = <String>[
    if (root != null)
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '${File(Platform.resolvedExecutable).parent.parent.parent.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ];
  for (final c in candidates) {
    if (File(c).existsSync()) {
      final loader = FontLoader('MaterialIcons')..addFont(_bytes(c));
      await loader.load();
      return;
    }
  }
}

final List<Map<String, String>> _products = [
  {'title': 'Silk Blend Kurta', 'feature': 'Handwoven everyday wear', 'badge': 'Best Seller', 'sell': '1,299', 'orig': '1,999', 'rating': '4.8'},
  {'title': 'Cotton Anarkali Set', 'feature': 'Floor-length with dupatta', 'badge': 'New', 'sell': '2,499', 'orig': '3,299', 'rating': '4.7'},
  {'title': 'Banarasi Dupatta', 'feature': 'Zari border, festive ready', 'badge': 'Trending', 'sell': '899', 'orig': '1,499', 'rating': '4.6'},
  {'title': 'Chikankari Tunic', 'feature': 'Lucknowi hand embroidery', 'badge': 'Best Seller', 'sell': '1,749', 'orig': '2,599', 'rating': '4.9'},
  {'title': 'Linen Palazzo', 'feature': 'Relaxed all-day comfort', 'badge': 'New', 'sell': '1,099', 'orig': '1,599', 'rating': '4.5'},
  {'title': 'Embroidered Saree', 'feature': 'Sequin work, party perfect', 'badge': 'Trending', 'sell': '3,299', 'orig': '4,999', 'rating': '4.8'},
];

List<LayoutDatum> _mockItems() => List.generate(_products.length, (i) {
      final p = _products[i];
      return LayoutDatum(
        id: 'mock-$i',
        image: '',
        title: p['title'],
        subTitle: p['feature'],
        featureText: p['feature'],
        salesText: p['badge'],
        rating: num.parse(p['rating']!),
        prices: Prices(sellingPrice: p['sell'], originalPrice: p['orig']),
      );
    });

Content _mockContent(String layout, String title, String subtitle, String cta) =>
    Content(
      layoutName: layout,
      layoutTitle: title,
      layoutSubTitle: subtitle,
      layoutRedirectTitle: cta,
      layoutRedirect: '#',
      layoutOption: 'Product',
      layoutData: _mockItems(),
    );

Future<void> _shoot(WidgetTester tester, String name, Widget child) async {
  final key = GlobalKey();
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: Colors.white),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: RepaintBoundary(
            key: key,
            child: Material(color: Colors.white, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
  await expectLater(find.byKey(key), matchesGoldenFile('goldens/$name.png'));
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadFont('CircularStd', 'fonts/circular_std_book_regular.ttf');
    await _loadFont('Gabarito', 'fonts/gabarito_regular.ttf');
    await _loadMaterialIcons();
  });

  testWidgets("ProductGridTwo1", (t) async =>
      _shoot(t, "ProductGridTwo1", ProductGridTwo1(content: _mockContent("ProductGridTwo1", "Bestsellers", "Loved this week", "View all"))));
  testWidgets("ProductRailCompact1", (t) async =>
      _shoot(t, "ProductRailCompact1", ProductRailCompact1(content: _mockContent("ProductRailCompact1", "New Arrivals", "Just landed", "Shop new"))));
  testWidgets("ProductListStack1", (t) async =>
      _shoot(t, "ProductListStack1", ProductListStack1(content: _mockContent("ProductListStack1", "All Products", "Sorted for you", "View all"))));
  testWidgets("ProductDealGrid1", (t) async =>
      _shoot(t, "ProductDealGrid1", ProductDealGrid1(content: _mockContent("ProductDealGrid1", "Deals of the Day", "Grab them before they go", "View all"))));
  testWidgets("ProductEditorialRail1", (t) async =>
      _shoot(t, "ProductEditorialRail1", ProductEditorialRail1(content: _mockContent("ProductEditorialRail1", "The Season Edit", "Handpicked for you", "See more"))));
  testWidgets("ProductQuickAddGrid1", (t) async =>
      _shoot(t, "ProductQuickAddGrid1", ProductQuickAddGrid1(content: _mockContent("ProductQuickAddGrid1", "Quick Add", "Tap to add", "View all"))));
}
