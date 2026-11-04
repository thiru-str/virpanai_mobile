// Golden harness for mobile batch 5 (product+cart / category / custom / banners).
// Generate: flutter test test/cms_preview/batch5_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_subscription_card1.dart';
import 'package:waioz/ui/widgets/home/product_filter_grid1.dart';
import 'package:waioz/ui/widgets/home/product_lookbook_rail1.dart';
import 'package:waioz/ui/widgets/home/category_accordion1.dart';
import 'package:waioz/ui/widgets/home/category_count_grid1.dart';
import 'package:waioz/ui/widgets/home/category_story_bubbles1.dart';
import 'package:waioz/ui/widgets/home/custom_icon_feature_grid1.dart';
import 'package:waioz/ui/widgets/home/custom_quote_banner1.dart';
import 'package:waioz/ui/widgets/home/custom_step_cards1.dart';
import 'package:waioz/ui/widgets/home/category_sale_banner1.dart';
import 'package:waioz/ui/widgets/home/free_gift_banner1.dart';
import 'package:waioz/ui/widgets/home/welcome_offer_banner1.dart';

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

final _features = [
  {'t': 'Free Shipping', 'f': 'On all orders above Rs 999, delivered pan-India'},
  {'t': 'Easy Returns', 'f': '7-day no-questions returns on unworn items'},
  {'t': 'Secure Payments', 'f': 'Bank-grade encryption on every transaction'},
  {'t': 'Handmade Quality', 'f': 'Crafted by master artisans across India'},
];
List<LayoutDatum> _featureItems() => List.generate(_features.length, (i) =>
    LayoutDatum(id: 'f-$i', image: '', title: _features[i]['t'], featureText: _features[i]['f'], subTitle: _features[i]['f']));

final _quote = [
  {'t': 'The Waioz Promise', 'f': 'We believe everyday clothing should be made with the same care as festive wear — honestly priced, and kind to the hands that make it.'},
];
List<LayoutDatum> _quoteItems() => List.generate(_quote.length, (i) =>
    LayoutDatum(id: 'q-$i', image: '', title: _quote[i]['t'], featureText: _quote[i]['f'], subTitle: _quote[i]['f']));

final _steps = [
  {'t': 'Browse & Pick', 'f': 'Explore curated collections and add your favourites'},
  {'t': 'Secure Checkout', 'f': 'Pay safely with UPI, cards or cash on delivery'},
  {'t': 'Fast Delivery', 'f': 'Get it at your door in 3–5 business days'},
];
List<LayoutDatum> _stepItems() => List.generate(_steps.length, (i) =>
    LayoutDatum(id: 't-$i', image: '', title: _steps[i]['t'], featureText: _steps[i]['f'], subTitle: _steps[i]['f']));

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
  testWidgets("ProductSubscriptionCard1", (t) async => _shoot(t, "ProductSubscriptionCard1", ProductSubscriptionCard1(content: _mc("ProductSubscriptionCard1", "Subscribe & Save", "Never run out", "Subscribe", _pItems()))));
  testWidgets("ProductFilterGrid1", (t) async => _shoot(t, "ProductFilterGrid1", ProductFilterGrid1(content: _mc("ProductFilterGrid1", "Shop the Range", "Filter to taste", "View all", _pItems()))));
  testWidgets("ProductLookbookRail1", (t) async => _shoot(t, "ProductLookbookRail1", ProductLookbookRail1(content: _mc("ProductLookbookRail1", "The Lookbook", "Shop the look", "View all", _pItems()))));
  testWidgets("CategoryAccordion1", (t) async => _shoot(t, "CategoryAccordion1", CategoryAccordion1(content: _mc("CategoryAccordion1", "Browse Categories", "Tap to expand", "View all", _cItems()))));
  testWidgets("CategoryCountGrid1", (t) async => _shoot(t, "CategoryCountGrid1", CategoryCountGrid1(content: _mc("CategoryCountGrid1", "Shop by Category", "Curated aisles", "View all", _cItems()))));
  testWidgets("CategoryStoryBubbles1", (t) async => _shoot(t, "CategoryStoryBubbles1", CategoryStoryBubbles1(content: _mc("CategoryStoryBubbles1", "Highlights", "Tap to explore", "", _cItems()))));
  testWidgets("CustomIconFeatureGrid1", (t) async => _shoot(t, "CustomIconFeatureGrid1", CustomIconFeatureGrid1(content: _mc("CustomIconFeatureGrid1", "Why Shop With Us", "Our promises", "", _featureItems()))));
  testWidgets("CustomQuoteBanner1", (t) async => _shoot(t, "CustomQuoteBanner1", CustomQuoteBanner1(content: _mc("CustomQuoteBanner1", "Our Mission", "", "", _quoteItems()))));
  testWidgets("CustomStepCards1", (t) async => _shoot(t, "CustomStepCards1", CustomStepCards1(content: _mc("CustomStepCards1", "How It Works", "Three simple steps", "", _stepItems()))));
  testWidgets("CategorySaleBanner1", (t) async => _shoot(t, "CategorySaleBanner1", CategorySaleBanner1(content: _mc("CategorySaleBanner1", "Up to 50% Off Sarees", "Festive edit is live", "Shop now", _pItems()))));
  testWidgets("FreeGiftBanner1", (t) async => _shoot(t, "FreeGiftBanner1", FreeGiftBanner1(content: _mc("FreeGiftBanner1", "Free Gift With Every Order", "On orders above Rs 1999", "Shop now", _pItems()))));
  testWidgets("WelcomeOfferBanner1", (t) async => _shoot(t, "WelcomeOfferBanner1", WelcomeOfferBanner1(content: _mc("WelcomeOfferBanner1", "Get Rs 300 Off Your First Order", "Use code WELCOME300 at checkout", "Claim now", _pItems()))));
}
