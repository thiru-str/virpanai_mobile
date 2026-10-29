// Golden harness for mobile batch 8 (final: product+cart / category / custom / banners).
// Generate: flutter test test/cms_preview/batch8_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_tall_card_rail1.dart';
import 'package:waioz/ui/widgets/home/product_combo_offer_grid1.dart';
import 'package:waioz/ui/widgets/home/product_recently_viewed_rail1.dart';
import 'package:waioz/ui/widgets/home/product_spotlight_duo1.dart';
import 'package:waioz/ui/widgets/home/category_full_bleed_list1.dart';
import 'package:waioz/ui/widgets/home/category_quad_feature1.dart';
import 'package:waioz/ui/widgets/home/category_flat_icon_cards1.dart';
import 'package:waioz/ui/widgets/home/custom_hero_stat1.dart';
import 'package:waioz/ui/widgets/home/custom_zigzag_rows1.dart';
import 'package:waioz/ui/widgets/home/custom_checklist_card1.dart';
import 'package:waioz/ui/widgets/home/gift_card_banner1.dart';
import 'package:waioz/ui/widgets/home/loyalty_points_banner1.dart';
import 'package:waioz/ui/widgets/home/social_follow_banner1.dart';

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

final _zig = [
  {'t': 'Rooted in Craft', 'f': 'Every piece begins with a handloom weaver and a story worth wearing.'},
  {'t': 'Kind to Skin', 'f': 'Natural fibres and low-impact dyes, gentle on you and the planet.'},
  {'t': 'Made to Last', 'f': 'Reinforced seams and honest fabrics built for years of wear.'},
];
List<LayoutDatum> _zigItems() => List.generate(_zig.length, (i) =>
    LayoutDatum(id: 'z-$i', image: '', title: _zig[i]['t'], featureText: _zig[i]['f'], subTitle: _zig[i]['f']));

final _check = ['Free shipping over Rs 999', '7-day easy returns', 'Handloom-certified fabric', 'Secure payments & COD'];
List<LayoutDatum> _checkItems() => List.generate(_check.length, (i) => LayoutDatum(id: 'k-$i', image: '', title: _check[i]));

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
  testWidgets("ProductTallCardRail1", (t) async => _shoot(t, "ProductTallCardRail1", ProductTallCardRail1(content: _mc("ProductTallCardRail1", "New This Week", "Fresh portrait picks", "View all", _pItems()))));
  testWidgets("ProductComboOfferGrid1", (t) async => _shoot(t, "ProductComboOfferGrid1", ProductComboOfferGrid1(content: _mc("ProductComboOfferGrid1", "Combo Offers", "Buy more, save more", "View all", _pItems()))));
  testWidgets("ProductRecentlyViewedRail1", (t) async => _shoot(t, "ProductRecentlyViewedRail1", ProductRecentlyViewedRail1(content: _mc("ProductRecentlyViewedRail1", "Recently Viewed", "Pick up where you left off", "Clear", _pItems()))));
  testWidgets("ProductSpotlightDuo1", (t) async => _shoot(t, "ProductSpotlightDuo1", ProductSpotlightDuo1(content: _mc("ProductSpotlightDuo1", "Two to Love", "Editor's duo", "View all", _pItems()))));
  testWidgets("CategoryFullBleedList1", (t) async => _shoot(t, "CategoryFullBleedList1", CategoryFullBleedList1(content: _mc("CategoryFullBleedList1", "Shop by Category", "Full-bleed edits", "View all", _cItems()))));
  testWidgets("CategoryQuadFeature1", (t) async => _shoot(t, "CategoryQuadFeature1", CategoryQuadFeature1(content: _mc("CategoryQuadFeature1", "Four to Explore", "Featured collections", "View all", _cItems()))));
  testWidgets("CategoryFlatIconCards1", (t) async => _shoot(t, "CategoryFlatIconCards1", CategoryFlatIconCards1(content: _mc("CategoryFlatIconCards1", "Quick Browse", "Tap a category", "", _cItems()))));
  testWidgets("CustomHeroStat1", (t) async => _shoot(t, "CustomHeroStat1", CustomHeroStat1(content: _mc("CustomHeroStat1", "1,00,000+", "Happy customers across India and counting", "", _pItems()))));
  testWidgets("CustomZigzagRows1", (t) async => _shoot(t, "CustomZigzagRows1", CustomZigzagRows1(content: _mc("CustomZigzagRows1", "Why Waioz", "What sets us apart", "", _zigItems()))));
  testWidgets("CustomChecklistCard1", (t) async => _shoot(t, "CustomChecklistCard1", CustomChecklistCard1(content: _mc("CustomChecklistCard1", "What's Included", "Every order comes with", "", _checkItems()))));
  testWidgets("GiftCardBanner1", (t) async => _shoot(t, "GiftCardBanner1", GiftCardBanner1(content: _mc("GiftCardBanner1", "Give the Gift of Choice", "Delivered instantly by email", "Buy a gift card", _pItems()))));
  testWidgets("LoyaltyPointsBanner1", (t) async => _shoot(t, "LoyaltyPointsBanner1", LoyaltyPointsBanner1(content: _mc("LoyaltyPointsBanner1", "You have 1,200 points", "Worth Rs 120 off your next order", "Redeem", _pItems()))));
  testWidgets("SocialFollowBanner1", (t) async => _shoot(t, "SocialFollowBanner1", SocialFollowBanner1(content: _mc("SocialFollowBanner1", "Follow the Journey", "Behind the scenes & first looks", "Follow", _pItems()))));
}
