// Golden harness for mobile product-list batch 2.
// Generate: flutter test test/cms_preview/product_list2_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_grid_three1.dart';
import 'package:waioz/ui/widgets/home/product_wide_rail1.dart';
import 'package:waioz/ui/widgets/home/product_mini_list1.dart';
import 'package:waioz/ui/widgets/home/product_ranked_list1.dart';
import 'package:waioz/ui/widgets/home/product_wishlist_grid1.dart';
import 'package:waioz/ui/widgets/home/product_circle_thumb_rail1.dart';
import 'package:waioz/ui/widgets/home/product_poster_rail1.dart';
import 'package:waioz/ui/widgets/home/product_two_row_scroll1.dart';
import 'package:waioz/ui/widgets/home/product_big_image_grid1.dart';

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
        id: 'mock-$i', image: '', title: p['title'], subTitle: p['feature'],
        featureText: p['feature'], salesText: p['badge'], rating: num.parse(p['rating']!),
        prices: Prices(sellingPrice: p['sell'], originalPrice: p['orig']),
      );
    });

Content _mc(String layout, String title, String subtitle, String cta) => Content(
      layoutName: layout, layoutTitle: title, layoutSubTitle: subtitle,
      layoutRedirectTitle: cta, layoutRedirect: '#', layoutOption: 'Product', layoutData: _mockItems());

Future<void> _shoot(WidgetTester tester, String name, Widget child) async {
  final key = GlobalKey();
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: Colors.white),
    home: Scaffold(backgroundColor: Colors.white, body: SingleChildScrollView(
      child: RepaintBoundary(key: key, child: Material(color: Colors.white, child: child)))),
  ));
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
  testWidgets("ProductGridThree1", (t) async => _shoot(t, "ProductGridThree1", ProductGridThree1(content: _mc("ProductGridThree1", "More to Explore", "Browse the range", "View all"))));
  testWidgets("ProductWideRail1", (t) async => _shoot(t, "ProductWideRail1", ProductWideRail1(content: _mc("ProductWideRail1", "Editor's Features", "Read, then shop", "See more"))));
  testWidgets("ProductMiniList1", (t) async => _shoot(t, "ProductMiniList1", ProductMiniList1(content: _mc("ProductMiniList1", "Buy It Again", "Your regulars", "View all"))));
  testWidgets("ProductRankedList1", (t) async => _shoot(t, "ProductRankedList1", ProductRankedList1(content: _mc("ProductRankedList1", "Top 6 This Week", "Ranked bestsellers", "View all"))));
  testWidgets("ProductWishlistGrid1", (t) async => _shoot(t, "ProductWishlistGrid1", ProductWishlistGrid1(content: _mc("ProductWishlistGrid1", "Save Your Favourites", "Tap the heart", "View all"))));
  testWidgets("ProductCircleThumbRail1", (t) async => _shoot(t, "ProductCircleThumbRail1", ProductCircleThumbRail1(content: _mc("ProductCircleThumbRail1", "Boutique Picks", "Curated circles", "View all"))));
  testWidgets("ProductPosterRail1", (t) async => _shoot(t, "ProductPosterRail1", ProductPosterRail1(content: _mc("ProductPosterRail1", "The Poster Edit", "Image-forward", "View all"))));
  testWidgets("ProductTwoRowScroll1", (t) async => _shoot(t, "ProductTwoRowScroll1", ProductTwoRowScroll1(content: _mc("ProductTwoRowScroll1", "Keep Shopping For", "Picked up for you", "View all"))));
  testWidgets("ProductBigImageGrid1", (t) async => _shoot(t, "ProductBigImageGrid1", ProductBigImageGrid1(content: _mc("ProductBigImageGrid1", "The Season Edit", "Handpicked", "See more"))));
}
