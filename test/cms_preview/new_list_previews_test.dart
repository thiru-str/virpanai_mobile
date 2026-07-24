// AUTO-GENERATED self-contained golden harness for the NEW marketplace list
// components (Slider50-59 / Banner8-17 / Collection3-12). Mirrors the render
// config of test/cms_preview/cms_preview_golden_test.dart (390-wide phone
// surface, bundled fonts, image-less mock data -> neutral skeleton previews).
//
// Generate:  flutter test test/cms_preview/new_list_previews_test.dart --update-goldens
// Output:    test/cms_preview/goldens/<LayoutName>.png
// Publish:   cp test/cms_preview/goldens/{Slider5*,Banner*,Collection*}.png ../mobile-component-previews/

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/slider50.dart';
import 'package:waioz/ui/widgets/home/slider51.dart';
import 'package:waioz/ui/widgets/home/slider52.dart';
import 'package:waioz/ui/widgets/home/slider53.dart';
import 'package:waioz/ui/widgets/home/slider54.dart';
import 'package:waioz/ui/widgets/home/slider55.dart';
import 'package:waioz/ui/widgets/home/slider56.dart';
import 'package:waioz/ui/widgets/home/slider57.dart';
import 'package:waioz/ui/widgets/home/slider58.dart';
import 'package:waioz/ui/widgets/home/slider59.dart';
import 'package:waioz/ui/widgets/home/banner8.dart';
import 'package:waioz/ui/widgets/home/banner9.dart';
import 'package:waioz/ui/widgets/home/banner10.dart';
import 'package:waioz/ui/widgets/home/banner11.dart';
import 'package:waioz/ui/widgets/home/banner12.dart';
import 'package:waioz/ui/widgets/home/banner13.dart';
import 'package:waioz/ui/widgets/home/banner14.dart';
import 'package:waioz/ui/widgets/home/banner15.dart';
import 'package:waioz/ui/widgets/home/banner16.dart';
import 'package:waioz/ui/widgets/home/banner17.dart';
import 'package:waioz/ui/widgets/home/collection3.dart';
import 'package:waioz/ui/widgets/home/collection4.dart';
import 'package:waioz/ui/widgets/home/collection5.dart';
import 'package:waioz/ui/widgets/home/collection6.dart';
import 'package:waioz/ui/widgets/home/collection7.dart';
import 'package:waioz/ui/widgets/home/collection8.dart';
import 'package:waioz/ui/widgets/home/collection9.dart';
import 'package:waioz/ui/widgets/home/collection10.dart';
import 'package:waioz/ui/widgets/home/collection11.dart';
import 'package:waioz/ui/widgets/home/collection12.dart';

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

  testWidgets("Slider50", (t) async =>
      _shoot(t, "Slider50", Slider50(content: _mockContent("Slider50", "Editors Spotlight", "Featured + more", "View all"))));
  testWidgets("Slider51", (t) async =>
      _shoot(t, "Slider51", Slider51(content: _mockContent("Slider51", "Hot Deals", "Quick add & save", "Grab now"))));
  testWidgets("Slider52", (t) async =>
      _shoot(t, "Slider52", Slider52(content: _mockContent("Slider52", "Save Your Favourites", "Add to wishlist", "View all"))));
  testWidgets("Slider53", (t) async =>
      _shoot(t, "Slider53", Slider53(content: _mockContent("Slider53", "The Full Range", "Two rows, one swipe", "View all"))));
  testWidgets("Slider54", (t) async =>
      _shoot(t, "Slider54", Slider54(content: _mockContent("Slider54", "Quick Picks", "Swipe to explore", "View all"))));
  testWidgets("Slider55", (t) async =>
      _shoot(t, "Slider55", Slider55(content: _mockContent("Slider55", "Shop by Category", "Filter your feed", "View all"))));
  testWidgets("Slider56", (t) async =>
      _shoot(t, "Slider56", Slider56(content: _mockContent("Slider56", "Top 10 This Week", "Ranked bestsellers", "View all"))));
  testWidgets("Slider57", (t) async =>
      _shoot(t, "Slider57", Slider57(content: _mockContent("Slider57", "The Poster Edit", "Image-forward", "View all"))));
  testWidgets("Slider58", (t) async =>
      _shoot(t, "Slider58", Slider58(content: _mockContent("Slider58", "Boutique Picks", "Curated circles", "View all"))));
  testWidgets("Slider59", (t) async =>
      _shoot(t, "Slider59", Slider59(content: _mockContent("Slider59", "New Arrivals", "Just landed", "Shop new"))));
  testWidgets("Banner8", (t) async =>
      _shoot(t, "Banner8", Banner8(content: _mockContent("Banner8", "Featured Edit", "Shop the strip", "Shop now"))));
  testWidgets("Banner9", (t) async =>
      _shoot(t, "Banner9", Banner9(content: _mockContent("Banner9", "Campaign Spotlight", "Hero + picks", "Shop now"))));
  testWidgets("Banner10", (t) async =>
      _shoot(t, "Banner10", Banner10(content: _mockContent("Banner10", "Two Ways to Shop", "Promo + products", "Shop now"))));
  testWidgets("Banner11", (t) async =>
      _shoot(t, "Banner11", Banner11(content: _mockContent("Banner11", "Deal of the Week", "Limited time", "Shop all"))));
  testWidgets("Banner12", (t) async =>
      _shoot(t, "Banner12", Banner12(content: _mockContent("Banner12", "Shop the Grid", "Headline + grid", "Shop"))));
  testWidgets("Banner13", (t) async =>
      _shoot(t, "Banner13", Banner13(content: _mockContent("Banner13", "Deal of the Day", "Todays feature", "Grab the deal"))));
  testWidgets("Banner14", (t) async =>
      _shoot(t, "Banner14", Banner14(content: _mockContent("Banner14", "Dual Campaigns", "Two edits", "Shop"))));
  testWidgets("Banner15", (t) async =>
      _shoot(t, "Banner15", Banner15(content: _mockContent("Banner15", "The Drop", "Poster + grid", "Shop the drop"))));
  testWidgets("Banner16", (t) async =>
      _shoot(t, "Banner16", Banner16(content: _mockContent("Banner16", "Flash Sale", "Ends tonight", "Shop all"))));
  testWidgets("Banner17", (t) async =>
      _shoot(t, "Banner17", Banner17(content: _mockContent("Banner17", "Curated for You", "Minimal edit", "View all"))));
  testWidgets("Collection3", (t) async =>
      _shoot(t, "Collection3", Collection3(content: _mockContent("Collection3", "Shop Collections", "Three to explore", "View all"))));
  testWidgets("Collection4", (t) async =>
      _shoot(t, "Collection4", Collection4(content: _mockContent("Collection4", "Browse Collections", "All edits", "Explore"))));
  testWidgets("Collection5", (t) async =>
      _shoot(t, "Collection5", Collection5(content: _mockContent("Collection5", "Featured Collections", "The mosaic", "Explore"))));
  testWidgets("Collection6", (t) async =>
      _shoot(t, "Collection6", Collection6(content: _mockContent("Collection6", "Collection Rail", "Swipe collections", "View all"))));
  testWidgets("Collection7", (t) async =>
      _shoot(t, "Collection7", Collection7(content: _mockContent("Collection7", "The Main Collection", "Featured + more", "Explore"))));
  testWidgets("Collection8", (t) async =>
      _shoot(t, "Collection8", Collection8(content: _mockContent("Collection8", "Editorial Collections", "Story-led", "Explore"))));
  testWidgets("Collection9", (t) async =>
      _shoot(t, "Collection9", Collection9(content: _mockContent("Collection9", "Shop by Collection", "Curated circles", "Explore"))));
  testWidgets("Collection10", (t) async =>
      _shoot(t, "Collection10", Collection10(content: _mockContent("Collection10", "Curated Edits", "With item counts", "View all"))));
  testWidgets("Collection11", (t) async =>
      _shoot(t, "Collection11", Collection11(content: _mockContent("Collection11", "Cinematic Collections", "Full-width", "Explore"))));
  testWidgets("Collection12", (t) async =>
      _shoot(t, "Collection12", Collection12(content: _mockContent("Collection12", "Quick Collections", "Tap to shop", "Explore"))));
}
