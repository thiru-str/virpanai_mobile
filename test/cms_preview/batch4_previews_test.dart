// Golden harness for mobile batch 4 (product+cart / category / custom / banners).
// Generate: flutter test test/cms_preview/batch4_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_featured_carousel1.dart';
import 'package:waioz/ui/widgets/home/product_split_feature1.dart';
import 'package:waioz/ui/widgets/home/product_flash_deal_list1.dart';
import 'package:waioz/ui/widgets/home/category_masonry1.dart';
import 'package:waioz/ui/widgets/home/category_circle_grid1.dart';
import 'package:waioz/ui/widgets/home/category_detailed_list1.dart';
import 'package:waioz/ui/widgets/home/custom_newsletter_signup1.dart';
import 'package:waioz/ui/widgets/home/custom_social_grid1.dart';
import 'package:waioz/ui/widgets/home/custom_brand_story1.dart';
import 'package:waioz/ui/widgets/home/lightning_deal_banner1.dart';
import 'package:waioz/ui/widgets/home/new_arrival_strip_banner1.dart';
import 'package:waioz/ui/widgets/home/referral_banner1.dart';

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

final _social = List.generate(6, (i) => LayoutDatum(id: 'g-$i', image: '', title: '@waioz'));

final _story = [
  {'t': 'Rooted in Handloom', 'f': 'We work directly with weaving clusters across India, paying fair wages and preserving centuries-old craft for a new generation of wearers.'},
];
List<LayoutDatum> _storyItems() => List.generate(_story.length, (i) =>
    LayoutDatum(id: 'b-$i', image: '', title: _story[i]['t'], featureText: _story[i]['f'], subTitle: _story[i]['f']));

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
  testWidgets("ProductFeaturedCarousel1", (t) async => _shoot(t, "ProductFeaturedCarousel1", ProductFeaturedCarousel1(content: _mc("ProductFeaturedCarousel1", "Featured", "Swipe to explore", "View all", _pItems()))));
  testWidgets("ProductSplitFeature1", (t) async => _shoot(t, "ProductSplitFeature1", ProductSplitFeature1(content: _mc("ProductSplitFeature1", "Hero Edit", "One star, more picks", "View all", _pItems()))));
  testWidgets("ProductFlashDealList1", (t) async => _shoot(t, "ProductFlashDealList1", ProductFlashDealList1(content: _mc("ProductFlashDealList1", "Flash Deals", "Going fast", "View all", _pItems()))));
  testWidgets("CategoryMasonry1", (t) async => _shoot(t, "CategoryMasonry1", CategoryMasonry1(content: _mc("CategoryMasonry1", "Shop by Category", "Explore the range", "View all", _cItems()))));
  testWidgets("CategoryCircleGrid1", (t) async => _shoot(t, "CategoryCircleGrid1", CategoryCircleGrid1(content: _mc("CategoryCircleGrid1", "Top Categories", "Tap to browse", "View all", _cItems()))));
  testWidgets("CategoryDetailedList1", (t) async => _shoot(t, "CategoryDetailedList1", CategoryDetailedList1(content: _mc("CategoryDetailedList1", "Browse Aisles", "Find your fit", "View all", _cItems()))));
  testWidgets("CustomNewsletterSignup1", (t) async => _shoot(t, "CustomNewsletterSignup1", CustomNewsletterSignup1(content: _mc("CustomNewsletterSignup1", "Get 10% Off Your First Order", "Join our list for early drops and offers", "Subscribe", _pItems()))));
  testWidgets("CustomSocialGrid1", (t) async => _shoot(t, "CustomSocialGrid1", CustomSocialGrid1(content: _mc("CustomSocialGrid1", "Shop Our Instagram", "@waioz", "Follow", _social))));
  testWidgets("CustomBrandStory1", (t) async => _shoot(t, "CustomBrandStory1", CustomBrandStory1(content: _mc("CustomBrandStory1", "Our Story", "Rooted in handloom, made for today", "Read our story", _storyItems()))));
  testWidgets("LightningDealBanner1", (t) async => _shoot(t, "LightningDealBanner1", LightningDealBanner1(content: _mc("LightningDealBanner1", "Deal of the Day", "Ends at midnight", "Grab it", _pItems()))));
  testWidgets("NewArrivalStripBanner1", (t) async => _shoot(t, "NewArrivalStripBanner1", NewArrivalStripBanner1(content: _mc("NewArrivalStripBanner1", "Just Dropped", "Fresh in today", "View all", _pItems()))));
  testWidgets("ReferralBanner1", (t) async => _shoot(t, "ReferralBanner1", ReferralBanner1(content: _mc("ReferralBanner1", "Refer a Friend, Get Rs 200", "They save, you earn — everybody wins", "Invite now", _pItems()))));
}
