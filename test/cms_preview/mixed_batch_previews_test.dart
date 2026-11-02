// Golden harness for the mobile mixed batch (product+cart / category / custom / banners).
// Generate: flutter test test/cms_preview/mixed_batch_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_add_grid1.dart';
import 'package:waioz/ui/widgets/home/product_add_rail1.dart';
import 'package:waioz/ui/widgets/home/product_stepper_list1.dart';
import 'package:waioz/ui/widgets/home/category_scroll_strip1.dart';
import 'package:waioz/ui/widgets/home/category_mega_grid1.dart';
import 'package:waioz/ui/widgets/home/category_two_col_image1.dart';
import 'package:waioz/ui/widgets/home/custom_card_slider1.dart';
import 'package:waioz/ui/widgets/home/custom_story_rail1.dart';
import 'package:waioz/ui/widgets/home/custom_feature_list1.dart';
import 'package:waioz/ui/widgets/home/promo_strip_banner1.dart';
import 'package:waioz/ui/widgets/home/offer_grid_banner1.dart';
import 'package:waioz/ui/widgets/home/full_width_banner1.dart';

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
    if (File(c).existsSync()) { final l = FontLoader('MaterialIcons')..addFont(_bytes(c)); await l.load(); return; }
  }
}

final _products = [
  {'t': 'Silk Blend Kurta', 'f': 'Handwoven everyday wear', 'b': 'Best Seller', 's': '1,299', 'o': '1,999', 'r': '4.8'},
  {'t': 'Cotton Anarkali Set', 'f': 'Floor-length with dupatta', 'b': 'New', 's': '2,499', 'o': '3,299', 'r': '4.7'},
  {'t': 'Banarasi Dupatta', 'f': 'Zari border, festive ready', 'b': 'Trending', 's': '899', 'o': '1,499', 'r': '4.6'},
  {'t': 'Chikankari Tunic', 'f': 'Lucknowi hand embroidery', 'b': 'Best Seller', 's': '1,749', 'o': '2,599', 'r': '4.9'},
  {'t': 'Linen Palazzo', 'f': 'Relaxed all-day comfort', 'b': 'New', 's': '1,099', 'o': '1,599', 'r': '4.5'},
  {'t': 'Embroidered Saree', 'f': 'Sequin work, party perfect', 'b': 'Trending', 's': '3,299', 'o': '4,999', 'r': '4.8'},
];
List<LayoutDatum> _pItems() => List.generate(_products.length, (i) {
      final p = _products[i];
      return LayoutDatum(id: 'p-$i', image: '', title: p['t'], subTitle: p['f'], featureText: p['f'],
          salesText: p['b'], rating: num.parse(p['r']!), prices: Prices(sellingPrice: p['s'], originalPrice: p['o']));
    });

const _cats = ['Sarees', 'Kurtas', 'Dupattas', 'Lehengas', 'Tunics', 'Palazzos', 'Dresses', 'Accessories'];
List<LayoutDatum> _cItems() => List.generate(_cats.length, (i) => LayoutDatum(id: 'c-$i', image: '', title: _cats[i]));

final _custom = [
  {'t': 'The Style Journal', 'f': '5 ways to drape a silk dupatta this season'},
  {'t': 'Behind the Craft', 'f': 'Meet the artisans keeping Chikankari alive'},
  {'t': 'Festive Lookbook', 'f': 'Celebration-ready looks, curated for you'},
  {'t': 'Fabric Guide', 'f': 'How to choose the right weave for you'},
  {'t': 'Care Tips', 'f': 'Keep your handloom looking new for years'},
];
List<LayoutDatum> _customItems() => List.generate(_custom.length, (i) =>
    LayoutDatum(id: 'x-$i', image: '', title: _custom[i]['t'], featureText: _custom[i]['f'], subTitle: _custom[i]['f']));

Content _mc(String layout, String title, String subtitle, String cta, List<LayoutDatum> data) => Content(
    layoutName: layout, layoutTitle: title, layoutSubTitle: subtitle, layoutRedirectTitle: cta,
    layoutRedirect: '#', layoutBannerImage: '', layoutOption: 'Custom', layoutData: data);

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
  testWidgets("ProductAddGrid1", (t) async => _shoot(t, "ProductAddGrid1", ProductAddGrid1(content: _mc("ProductAddGrid1", "Add to Cart", "Tap add", "View all", _pItems()))));
  testWidgets("ProductAddRail1", (t) async => _shoot(t, "ProductAddRail1", ProductAddRail1(content: _mc("ProductAddRail1", "Grab & Go", "Quick add", "View all", _pItems()))));
  testWidgets("ProductStepperList1", (t) async => _shoot(t, "ProductStepperList1", ProductStepperList1(content: _mc("ProductStepperList1", "Stock Up", "Add to basket", "View all", _pItems()))));
  testWidgets("CategoryScrollStrip1", (t) async => _shoot(t, "CategoryScrollStrip1", CategoryScrollStrip1(content: _mc("CategoryScrollStrip1", "Browse", "Quick nav", "", _cItems()))));
  testWidgets("CategoryMegaGrid1", (t) async => _shoot(t, "CategoryMegaGrid1", CategoryMegaGrid1(content: _mc("CategoryMegaGrid1", "All Departments", "Everything", "View all", _cItems()))));
  testWidgets("CategoryTwoColImage1", (t) async => _shoot(t, "CategoryTwoColImage1", CategoryTwoColImage1(content: _mc("CategoryTwoColImage1", "Shop by Category", "Curated", "View all", _cItems()))));
  testWidgets("CustomCardSlider1", (t) async => _shoot(t, "CustomCardSlider1", CustomCardSlider1(content: _mc("CustomCardSlider1", "From the Journal", "Stories & style", "Read more", _customItems()))));
  testWidgets("CustomStoryRail1", (t) async => _shoot(t, "CustomStoryRail1", CustomStoryRail1(content: _mc("CustomStoryRail1", "Highlights", "Tap to explore", "", _customItems()))));
  testWidgets("CustomFeatureList1", (t) async => _shoot(t, "CustomFeatureList1", CustomFeatureList1(content: _mc("CustomFeatureList1", "Good to Know", "Guides & tips", "", _customItems()))));
  testWidgets("PromoStripBanner1", (t) async => _shoot(t, "PromoStripBanner1", PromoStripBanner1(content: _mc("PromoStripBanner1", "Free shipping over Rs 999", "Today only", "Shop now", _pItems()))));
  testWidgets("OfferGridBanner1", (t) async => _shoot(t, "OfferGridBanner1", OfferGridBanner1(content: _mc("OfferGridBanner1", "Top Offers", "Save more", "All offers", _pItems()))));
  testWidgets("FullWidthBanner1", (t) async => _shoot(t, "FullWidthBanner1", FullWidthBanner1(content: _mc("FullWidthBanner1", "The Festive Edit", "New Collection", "Shop the edit", _pItems()))));
}
