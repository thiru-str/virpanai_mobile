// Golden harness for mobile batch 6 (product+cart / category / custom / banners).
// Generate: flutter test test/cms_preview/batch6_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_fbt_bundle1.dart';
import 'package:waioz/ui/widgets/home/product_discount_zone_grid1.dart';
import 'package:waioz/ui/widgets/home/product_gift_guide_rail1.dart';
import 'package:waioz/ui/widgets/home/category_gradient_tiles1.dart';
import 'package:waioz/ui/widgets/home/category_wide_pill_rail1.dart';
import 'package:waioz/ui/widgets/home/category_duo_feature1.dart';
import 'package:waioz/ui/widgets/home/custom_promo_ticker1.dart';
import 'package:waioz/ui/widgets/home/custom_comparison_table1.dart';
import 'package:waioz/ui/widgets/home/custom_logo_strip1.dart';
import 'package:waioz/ui/widgets/home/slim_offer_bar1.dart';
import 'package:waioz/ui/widgets/home/payment_offers_banner1.dart';
import 'package:waioz/ui/widgets/home/shipping_promise_banner1.dart';

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

final _compare = [
  {'t': 'Handloom-certified fabric'},
  {'t': 'Fair wages to artisans'},
  {'t': '7-day easy returns'},
  {'t': 'Free shipping over Rs 999'},
];
List<LayoutDatum> _compareItems() => List.generate(_compare.length, (i) =>
    LayoutDatum(id: 'cmp-$i', image: '', title: _compare[i]['t']));

const _brands = ['Vogue', 'Elle', 'Cosmopolitan', 'Femina', 'Grazia', 'Harper’s Bazaar'];
List<LayoutDatum> _brandItems() => List.generate(_brands.length, (i) => LayoutDatum(id: 'br-$i', image: '', title: _brands[i]));

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
  testWidgets("ProductFbtBundle1", (t) async => _shoot(t, "ProductFbtBundle1", ProductFbtBundle1(content: _mc("ProductFbtBundle1", "Frequently Bought Together", "Complete the look", "", _pItems()))));
  testWidgets("ProductDiscountZoneGrid1", (t) async => _shoot(t, "ProductDiscountZoneGrid1", ProductDiscountZoneGrid1(content: _mc("ProductDiscountZoneGrid1", "The Discount Zone", "Biggest markdowns", "View all", _pItems()))));
  testWidgets("ProductGiftGuideRail1", (t) async => _shoot(t, "ProductGiftGuideRail1", ProductGiftGuideRail1(content: _mc("ProductGiftGuideRail1", "Gift Guide", "Perfect for everyone", "View all", _pItems()))));
  testWidgets("CategoryGradientTiles1", (t) async => _shoot(t, "CategoryGradientTiles1", CategoryGradientTiles1(content: _mc("CategoryGradientTiles1", "Shop by Category", "Explore the range", "View all", _cItems()))));
  testWidgets("CategoryWidePillRail1", (t) async => _shoot(t, "CategoryWidePillRail1", CategoryWidePillRail1(content: _mc("CategoryWidePillRail1", "Quick Browse", "Tap a category", "", _cItems()))));
  testWidgets("CategoryDuoFeature1", (t) async => _shoot(t, "CategoryDuoFeature1", CategoryDuoFeature1(content: _mc("CategoryDuoFeature1", "Two to Explore", "Featured collections", "View all", _cItems()))));
  testWidgets("CustomPromoTicker1", (t) async => _shoot(t, "CustomPromoTicker1", CustomPromoTicker1(content: _mc("CustomPromoTicker1", "Extra 10% off everything this weekend — no code needed", "", "Shop now", _pItems()))));
  testWidgets("CustomComparisonTable1", (t) async => _shoot(t, "CustomComparisonTable1", CustomComparisonTable1(content: _mc("CustomComparisonTable1", "The Waioz Difference", "How we compare", "Us", _compareItems()))));
  testWidgets("CustomLogoStrip1", (t) async => _shoot(t, "CustomLogoStrip1", CustomLogoStrip1(content: _mc("CustomLogoStrip1", "As Seen In", "Loved by the press", "", _brandItems()))));
  testWidgets("SlimOfferBar1", (t) async => _shoot(t, "SlimOfferBar1", SlimOfferBar1(content: _mc("SlimOfferBar1", "Free shipping on all orders above Rs 999", "", "Shop", _pItems()))));
  testWidgets("PaymentOffersBanner1", (t) async => _shoot(t, "PaymentOffersBanner1", PaymentOffersBanner1(content: _mc("PaymentOffersBanner1", "Bank & Payment Offers", "Save more at checkout", "View all", _pItems()))));
  testWidgets("ShippingPromiseBanner1", (t) async => _shoot(t, "ShippingPromiseBanner1", ShippingPromiseBanner1(content: _mc("ShippingPromiseBanner1", "Free delivery by tomorrow", "Order within 4 hrs 20 mins", "Enter pincode", _pItems()))));
}
