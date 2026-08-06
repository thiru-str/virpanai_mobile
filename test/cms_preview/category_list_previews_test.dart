// Golden harness for the NEW native category-list widgets (Area 2 mobile batch 1).
// Generate: flutter test test/cms_preview/category_list_previews_test.dart --update-goldens
// Output: test/cms_preview/goldens/<LayoutName>.png

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/category_circle_rail1.dart';
import 'package:waioz/ui/widgets/home/category_grid_square1.dart';
import 'package:waioz/ui/widgets/home/category_pill_wrap1.dart';
import 'package:waioz/ui/widgets/home/category_row_list1.dart';
import 'package:waioz/ui/widgets/home/category_image_tile1.dart';
import 'package:waioz/ui/widgets/home/category_icon_circle1.dart';
import 'package:waioz/ui/widgets/home/category_big_card1.dart';
import 'package:waioz/ui/widgets/home/category_tile_label1.dart';
import 'package:waioz/ui/widgets/home/category_feature_split1.dart';

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

const _cats = ['Sarees', 'Kurtas', 'Dupattas', 'Lehengas', 'Tunics', 'Palazzos', 'Dresses', 'Accessories'];

List<LayoutDatum> _mockCats() => List.generate(_cats.length, (i) => LayoutDatum(id: 'c-$i', image: '', title: _cats[i]));

Content _mockContent(String layout, String title, String subtitle, String cta) =>
    Content(
      layoutName: layout,
      layoutTitle: title,
      layoutSubTitle: subtitle,
      layoutRedirectTitle: cta,
      layoutRedirect: '#',
      layoutOption: 'Category',
      layoutData: _mockCats(),
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
          child: RepaintBoundary(key: key, child: Material(color: Colors.white, child: child)),
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

  testWidgets("CategoryCircleRail1", (t) async =>
      _shoot(t, "CategoryCircleRail1", CategoryCircleRail1(content: _mockContent("CategoryCircleRail1", "Shop by Category", "Swipe to browse", "All categories"))));
  testWidgets("CategoryGridSquare1", (t) async =>
      _shoot(t, "CategoryGridSquare1", CategoryGridSquare1(content: _mockContent("CategoryGridSquare1", "Shop by Department", "Find your aisle", "All departments"))));
  testWidgets("CategoryPillWrap1", (t) async =>
      _shoot(t, "CategoryPillWrap1", CategoryPillWrap1(content: _mockContent("CategoryPillWrap1", "Quick Browse", "Jump to a category", ""))));
  testWidgets("CategoryRowList1", (t) async =>
      _shoot(t, "CategoryRowList1", CategoryRowList1(content: _mockContent("CategoryRowList1", "All Categories", "Browse the full range", ""))));
  testWidgets("CategoryImageTile1", (t) async =>
      _shoot(t, "CategoryImageTile1", CategoryImageTile1(content: _mockContent("CategoryImageTile1", "Shop by Category", "Curated edits", "View all"))));
  testWidgets("CategoryIconCircle1", (t) async =>
      _shoot(t, "CategoryIconCircle1", CategoryIconCircle1(content: _mockContent("CategoryIconCircle1", "Shop by Category", "Tap to explore", "All categories"))));
  testWidgets("CategoryBigCard1", (t) async =>
      _shoot(t, "CategoryBigCard1", CategoryBigCard1(content: _mockContent("CategoryBigCard1", "Shop by Concern", "Find what you need", "View all"))));
  testWidgets("CategoryTileLabel1", (t) async =>
      _shoot(t, "CategoryTileLabel1", CategoryTileLabel1(content: _mockContent("CategoryTileLabel1", "Shop by Category", "Find your fit", "All categories"))));
  testWidgets("CategoryFeatureSplit1", (t) async =>
      _shoot(t, "CategoryFeatureSplit1", CategoryFeatureSplit1(content: _mockContent("CategoryFeatureSplit1", "Featured Categories", "Start here", "View all"))));
}
