// Self-contained golden harness for the 16 marketplace components that were
// missing catalogue previews (they exist as widgets + in marketplace_registry
// but never had a golden generated). Mirrors cms_preview_golden_test.dart:
// image-less mock data, bundled fonts, 390-wide @dpr3, neutral skeletons.
//
// Generate:  flutter test test/cms_preview/missing16_previews_test.dart --update-goldens
// Output:    test/cms_preview/goldens/<LayoutName>.png
// Publish:   copy the 16 PNGs -> ../mobile-component-previews/  then seed
//            (CMS_PUSH_FILTER=mobile).

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/ui/widgets/home/marketplace_registry.dart';

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
    if (root != null) '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
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

// ---- Mock data ----
final List<Map<String, String>> _products = [
  {'title': 'Silk Kurta', 'feature': 'Everyday wear', 'badge': 'Best Seller', 'sell': '299', 'orig': '499', 'rating': '4.8'},
  {'title': 'Anarkali Set', 'feature': 'With dupatta', 'badge': 'New', 'sell': '449', 'orig': '599', 'rating': '4.7'},
  {'title': 'Banarasi Dupatta', 'feature': 'Zari border', 'badge': 'Trending', 'sell': '199', 'orig': '349', 'rating': '4.6'},
  {'title': 'Chikankari Tunic', 'feature': 'Hand embroidery', 'badge': 'Best Seller', 'sell': '349', 'orig': '599', 'rating': '4.9'},
  {'title': 'Linen Palazzo', 'feature': 'All-day comfort', 'badge': 'New', 'sell': '249', 'orig': '399', 'rating': '4.5'},
  {'title': 'Party Saree', 'feature': 'Sequin work', 'badge': 'Trending', 'sell': '499', 'orig': '799', 'rating': '4.8'},
];

List<LayoutDatum> _productItems() => List.generate(_products.length, (i) {
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

final List<LayoutDatum> _categoryItems =
    ['Earrings', 'Necklaces', 'Pendants', 'Bridal Sets', 'Bangles', 'Hair', 'Rings', 'Anklets']
        .map((c) => LayoutDatum(image: '', title: c))
        .toList();

Content _content(String layout, String title, String subtitle, String cta, List<LayoutDatum> items) =>
    Content(
      layoutName: layout,
      layoutTitle: title,
      layoutSubTitle: subtitle,
      layoutRedirectTitle: cta,
      layoutRedirect: '#',
      layoutOption: 'Product',
      layoutData: items,
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
  // NOTE: we intentionally do NOT drain exceptions here. A RenderFlex overflow
  // is a real layout bug — let it FAIL the test so it can't ship a broken card.
  await expectLater(find.byKey(key), matchesGoldenFile('goldens/$name.png'));
}

// layout_name -> (title, subtitle, cta, is category?)
const _cases = <List<String>>[
  ['ProductStepper1', 'Our Bestsellers', 'The staples customers reorder', 'Shop all', 'p'],
  ['ProductCarouselXL1', 'Featured Picks', 'Curated for you', 'View all', 'p'],
  ['ProductHeroGrid1', 'Editors Spotlight', 'One hero, many finds', 'Shop the edit', 'p'],
  ['ProductRatingGrid1', 'Top Rated', 'Loved by customers', 'View all', 'p'],
  ['ProductListRow1', 'All Products', 'Sorted for you', 'View all', 'p'],
  ['ProductMini1', 'Quick Picks', 'Tap to add', 'View all', 'p'],
  ['ReorderRail1', 'Buy It Again', 'Your regular picks', 'View all', 'p'],
  ['CategoryCircle1', 'Shop by Category', 'Browse the edit', 'All categories', 'c'],
  ['CategoryMini1', 'Categories', 'Jump to a section', 'View all', 'c'],
  ['CategoryPills1', 'Quick Browse', 'Pick a category', '', 'c'],
  ['Certifications1', 'Certified & Trusted', 'Quality you can rely on', '', 'p'],
  ['DealStrip1', 'Deal of the Day', 'Limited time offers', 'Grab now', 'p'],
  ['FarmStory1', 'From Our Farms', 'Rooted in craft', 'Our story', 'p'],
  ['NutritionFacts1', 'Nutrition & Ingredients', 'What is inside', '', 'p'],
  ['Recipe1', 'Simple Recipes', 'Make it at home', 'View all', 'p'],
  ['SubscriptionBox1', 'Subscribe & Save', 'Never run out', 'Subscribe', 'p'],
];

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await CurrencyUtil.initializeCurrencySymbol('Rs ');
    await _loadFont('CircularStd', 'fonts/circular_std_book_regular.ttf');
    await _loadFont('Gabarito', 'fonts/gabarito_regular.ttf');
    await _loadMaterialIcons();
  });

  for (final c in _cases) {
    final layout = c[0];
    testWidgets(layout, (t) async {
      final items = c[4] == 'c' ? _categoryItems : _productItems();
      final widget = marketplaceHomeWidget(_content(layout, c[1], c[2], c[3], items));
      expect(widget, isNotNull, reason: 'registry returned null for $layout');
      await _shoot(t, layout, widget!);
    });
  }
}
