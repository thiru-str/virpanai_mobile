// Golden harness for mobile batch 3 (product+cart / category / custom / banners).
// Generate: flutter test test/cms_preview/batch3_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_horizontal_card_list1.dart';
import 'package:waioz/ui/widgets/home/product_grid_four1.dart';
import 'package:waioz/ui/widgets/home/product_compare_row1.dart';
import 'package:waioz/ui/widgets/home/category_banner_list1.dart';
import 'package:waioz/ui/widgets/home/category_color_block1.dart';
import 'package:waioz/ui/widgets/home/category_horizontal_cards1.dart';
import 'package:waioz/ui/widgets/home/custom_faq_accordion1.dart';
import 'package:waioz/ui/widgets/home/custom_stat_band1.dart';
import 'package:waioz/ui/widgets/home/custom_video_card_slider1.dart';
import 'package:waioz/ui/widgets/home/coupon_banner1.dart';
import 'package:waioz/ui/widgets/home/seasonal_hero_banner1.dart';
import 'package:waioz/ui/widgets/home/bogo_banner1.dart';

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
  {'t': 'Georgette Gown', 'f': 'Flowy evening silhouette', 'b': 'New', 's': '2,899', 'o': '3,999', 'r': '4.7'},
  {'t': 'Block Print Shirt', 'f': 'Breathable summer cotton', 'b': 'Trending', 's': '799', 'o': '1,199', 'r': '4.5'},
];
List<LayoutDatum> _pItems() => List.generate(_products.length, (i) {
      final p = _products[i];
      return LayoutDatum(id: 'p-$i', image: '', title: p['t'], subTitle: p['f'], featureText: p['f'],
          salesText: p['b'], rating: num.parse(p['r']!), prices: Prices(sellingPrice: p['s'], originalPrice: p['o']));
    });

const _cats = ['Sarees', 'Kurtas', 'Dupattas', 'Lehengas', 'Tunics', 'Palazzos', 'Dresses', 'Accessories'];
List<LayoutDatum> _cItems() => List.generate(_cats.length, (i) => LayoutDatum(id: 'c-$i', image: '', title: _cats[i]));

final _stats = [
  {'t': '50k+', 'f': 'Happy customers'},
  {'t': '4.9', 'f': 'Average rating'},
  {'t': '24h', 'f': 'Fast dispatch'},
  {'t': '100%', 'f': 'Secure checkout'},
];
List<LayoutDatum> _statItems() => List.generate(_stats.length, (i) =>
    LayoutDatum(id: 's-$i', image: '', title: _stats[i]['t'], featureText: _stats[i]['f'], subTitle: _stats[i]['f']));

final _faq = [
  {'t': 'How long does delivery take?', 'f': 'Orders ship within 24 hours and arrive in 3–5 business days across India.'},
  {'t': 'What is your return policy?', 'f': 'Easy 7-day returns on unworn items with tags intact. Refunds in 5–7 days.'},
  {'t': 'Do you offer cash on delivery?', 'f': 'Yes, COD is available on all serviceable pincodes up to Rs 10,000.'},
  {'t': 'How do I track my order?', 'f': 'You will get an SMS and email with a live tracking link once your order ships.'},
];
List<LayoutDatum> _faqItems() => List.generate(_faq.length, (i) =>
    LayoutDatum(id: 'q-$i', image: '', title: _faq[i]['t'], featureText: _faq[i]['f'], subTitle: _faq[i]['f']));

final _video = [
  {'t': 'The Making of Chikankari', 'f': 'A 2-minute look inside the atelier'},
  {'t': 'Style It Three Ways', 'f': 'One saree, three festive looks'},
  {'t': 'Fabric Care Basics', 'f': 'Keep your handloom pristine'},
  {'t': 'Meet the Artisans', 'f': 'The hands behind every weave'},
];
List<LayoutDatum> _videoItems() => List.generate(_video.length, (i) =>
    LayoutDatum(id: 'v-$i', image: '', title: _video[i]['t'], featureText: _video[i]['f'], subTitle: _video[i]['f']));

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
  testWidgets("ProductHorizontalCardList1", (t) async => _shoot(t, "ProductHorizontalCardList1", ProductHorizontalCardList1(content: _mc("ProductHorizontalCardList1", "Buy It Again", "Your regulars", "View all", _pItems()))));
  testWidgets("ProductGridFour1", (t) async => _shoot(t, "ProductGridFour1", ProductGridFour1(content: _mc("ProductGridFour1", "Quick Picks", "Tap + to add", "View all", _pItems()))));
  testWidgets("ProductCompareRow1", (t) async => _shoot(t, "ProductCompareRow1", ProductCompareRow1(content: _mc("ProductCompareRow1", "Compare & Choose", "Side by side", "View all", _pItems()))));
  testWidgets("CategoryBannerList1", (t) async => _shoot(t, "CategoryBannerList1", CategoryBannerList1(content: _mc("CategoryBannerList1", "Shop by Category", "Curated aisles", "View all", _cItems()))));
  testWidgets("CategoryColorBlock1", (t) async => _shoot(t, "CategoryColorBlock1", CategoryColorBlock1(content: _mc("CategoryColorBlock1", "Browse Departments", "Everything in one place", "View all", _cItems()))));
  testWidgets("CategoryHorizontalCards1", (t) async => _shoot(t, "CategoryHorizontalCards1", CategoryHorizontalCards1(content: _mc("CategoryHorizontalCards1", "Explore Collections", "Swipe to browse", "View all", _cItems()))));
  testWidgets("CustomFaqAccordion1", (t) async => _shoot(t, "CustomFaqAccordion1", CustomFaqAccordion1(content: _mc("CustomFaqAccordion1", "Frequently Asked", "Everything you need to know", "", _faqItems()))));
  testWidgets("CustomStatBand1", (t) async => _shoot(t, "CustomStatBand1", CustomStatBand1(content: _mc("CustomStatBand1", "Why Shop With Us", "", "", _statItems()))));
  testWidgets("CustomVideoCardSlider1", (t) async => _shoot(t, "CustomVideoCardSlider1", CustomVideoCardSlider1(content: _mc("CustomVideoCardSlider1", "Watch & Shop", "Stories in motion", "View all", _videoItems()))));
  testWidgets("CouponBanner1", (t) async => _shoot(t, "CouponBanner1", CouponBanner1(content: _mc("CouponBanner1", "Flat 20% Off Your First Order", "Min. spend Rs 999 · New users only", "SAVE20", _pItems()))));
  testWidgets("SeasonalHeroBanner1", (t) async => _shoot(t, "SeasonalHeroBanner1", SeasonalHeroBanner1(content: _mc("SeasonalHeroBanner1", "The Monsoon Collection", "Rain-ready styles, freshly dropped", "Shop the edit", _pItems()))));
  testWidgets("BogoBanner1", (t) async => _shoot(t, "BogoBanner1", BogoBanner1(content: _mc("BogoBanner1", "Buy 1 Get 1 Free", "Add any two to unlock", "Shop now", _pItems()))));
}
