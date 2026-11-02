// Golden harness for mobile batch 7 (product+cart / category / custom / banners).
// Generate: flutter test test/cms_preview/batch7_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_hero_spotlight1.dart';
import 'package:waioz/ui/widgets/home/product_bestseller_rank_rail1.dart';
import 'package:waioz/ui/widgets/home/product_color_swatch_grid1.dart';
import 'package:waioz/ui/widgets/home/category_text_arrow_list1.dart';
import 'package:waioz/ui/widgets/home/category_hero_plus_rail1.dart';
import 'package:waioz/ui/widgets/home/category_numbered_list1.dart';
import 'package:waioz/ui/widgets/home/custom_value_props_row1.dart';
import 'package:waioz/ui/widgets/home/custom_editorial_cta1.dart';
import 'package:waioz/ui/widgets/home/custom_image_quote_card1.dart';
import 'package:waioz/ui/widgets/home/spin_wheel_banner1.dart';
import 'package:waioz/ui/widgets/home/whatsapp_order_banner1.dart';
import 'package:waioz/ui/widgets/home/store_visit_banner1.dart';

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

final _props = [
  {'t': 'Free Shipping'}, {'t': 'Secure Payment'}, {'t': 'Easy Returns'}, {'t': '24/7 Support'},
];
List<LayoutDatum> _propItems() => List.generate(_props.length, (i) => LayoutDatum(id: 'v-$i', image: '', title: _props[i]['t']));

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
  testWidgets("ProductHeroSpotlight1", (t) async => _shoot(t, "ProductHeroSpotlight1", ProductHeroSpotlight1(content: _mc("ProductHeroSpotlight1", "Spotlight", "Our pick of the week", "Shop now", _pItems()))));
  testWidgets("ProductBestsellerRankRail1", (t) async => _shoot(t, "ProductBestsellerRankRail1", ProductBestsellerRankRail1(content: _mc("ProductBestsellerRankRail1", "Bestsellers", "Ranked by you", "View all", _pItems()))));
  testWidgets("ProductColorSwatchGrid1", (t) async => _shoot(t, "ProductColorSwatchGrid1", ProductColorSwatchGrid1(content: _mc("ProductColorSwatchGrid1", "More Colours", "Pick your shade", "View all", _pItems()))));
  testWidgets("CategoryTextArrowList1", (t) async => _shoot(t, "CategoryTextArrowList1", CategoryTextArrowList1(content: _mc("CategoryTextArrowList1", "All Categories", "Jump to a section", "", _cItems()))));
  testWidgets("CategoryHeroPlusRail1", (t) async => _shoot(t, "CategoryHeroPlusRail1", CategoryHeroPlusRail1(content: _mc("CategoryHeroPlusRail1", "Featured Category", "And more to explore", "View all", _cItems()))));
  testWidgets("CategoryNumberedList1", (t) async => _shoot(t, "CategoryNumberedList1", CategoryNumberedList1(content: _mc("CategoryNumberedList1", "Top Categories", "Most shopped", "View all", _cItems()))));
  testWidgets("CustomValuePropsRow1", (t) async => _shoot(t, "CustomValuePropsRow1", CustomValuePropsRow1(content: _mc("CustomValuePropsRow1", "", "", "", _propItems()))));
  testWidgets("CustomEditorialCta1", (t) async => _shoot(t, "CustomEditorialCta1", CustomEditorialCta1(content: _mc("CustomEditorialCta1", "Made for the Modern Wardrobe", "Discover pieces that move from day to night with ease", "Explore now", _pItems()))));
  testWidgets("CustomImageQuoteCard1", (t) async => _shoot(t, "CustomImageQuoteCard1", CustomImageQuoteCard1(content: _mc("CustomImageQuoteCard1", "Crafted to Last", "Timeless pieces, made by hand", "Discover", _pItems()))));
  testWidgets("SpinWheelBanner1", (t) async => _shoot(t, "SpinWheelBanner1", SpinWheelBanner1(content: _mc("SpinWheelBanner1", "Spin to Win up to 40% Off", "One spin per order", "Spin now", _pItems()))));
  testWidgets("WhatsappOrderBanner1", (t) async => _shoot(t, "WhatsappOrderBanner1", WhatsappOrderBanner1(content: _mc("WhatsappOrderBanner1", "Order on WhatsApp", "+91 98765 43210", "Message us", _pItems()))));
  testWidgets("StoreVisitBanner1", (t) async => _shoot(t, "StoreVisitBanner1", StoreVisitBanner1(content: _mc("StoreVisitBanner1", "Waioz Flagship Store", "42 MG Road, Bengaluru 560001", "Get directions", _pItems()))));
}
