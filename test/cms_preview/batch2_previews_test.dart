// Golden harness for mobile batch 2 (product+cart / category / custom / banners).
// Generate: flutter test test/cms_preview/batch2_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/product_size_pill_grid1.dart';
import 'package:waioz/ui/widgets/home/product_bundle_card1.dart';
import 'package:waioz/ui/widgets/home/product_tabbed_rail1.dart';
import 'package:waioz/ui/widgets/home/category_tabbed_grid1.dart';
import 'package:waioz/ui/widgets/home/category_nested_list1.dart';
import 'package:waioz/ui/widgets/home/category_cover_rail1.dart';
import 'package:waioz/ui/widgets/home/custom_testimonial_rail1.dart';
import 'package:waioz/ui/widgets/home/custom_blog_grid1.dart';
import 'package:waioz/ui/widgets/home/custom_timeline_list1.dart';
import 'package:waioz/ui/widgets/home/countdown_strip_banner1.dart';
import 'package:waioz/ui/widgets/home/app_download_banner1.dart';
import 'package:waioz/ui/widgets/home/trust_strip_banner1.dart';

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
  {'t': 'Priya Menon', 'f': 'The fabric quality is stunning and delivery was quick. Easily my favourite store now.'},
  {'t': 'Arjun Rao', 'f': 'Beautiful hand embroidery, exactly as pictured. Will order again for the festive season.'},
  {'t': 'Festive Lookbook', 'f': 'Celebration-ready looks, curated for you this season'},
  {'t': 'Fabric Guide', 'f': 'How to choose the right weave for your climate'},
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
  testWidgets("ProductSizePillGrid1", (t) async => _shoot(t, "ProductSizePillGrid1", ProductSizePillGrid1(content: _mc("ProductSizePillGrid1", "Pick Your Size", "In stock now", "View all", _pItems()))));
  testWidgets("ProductBundleCard1", (t) async => _shoot(t, "ProductBundleCard1", ProductBundleCard1(content: _mc("ProductBundleCard1", "Festive Combo", "3 pieces, one price", "Add bundle", _pItems()))));
  testWidgets("ProductTabbedRail1", (t) async => _shoot(t, "ProductTabbedRail1", ProductTabbedRail1(content: _mc("ProductTabbedRail1", "Trending Now", "Filter your feed", "View all", _pItems()))));
  testWidgets("CategoryTabbedGrid1", (t) async => _shoot(t, "CategoryTabbedGrid1", CategoryTabbedGrid1(content: _mc("CategoryTabbedGrid1", "Departments", "Tap to browse", "View all", _cItems()))));
  testWidgets("CategoryNestedList1", (t) async => _shoot(t, "CategoryNestedList1", CategoryNestedList1(content: _mc("CategoryNestedList1", "Shop by Aisle", "Categories & more", "View all", _cItems()))));
  testWidgets("CategoryCoverRail1", (t) async => _shoot(t, "CategoryCoverRail1", CategoryCoverRail1(content: _mc("CategoryCoverRail1", "Collections", "Curated edits", "View all", _cItems()))));
  testWidgets("CustomTestimonialRail1", (t) async => _shoot(t, "CustomTestimonialRail1", CustomTestimonialRail1(content: _mc("CustomTestimonialRail1", "What Shoppers Say", "Real reviews", "", _customItems()))));
  testWidgets("CustomBlogGrid1", (t) async => _shoot(t, "CustomBlogGrid1", CustomBlogGrid1(content: _mc("CustomBlogGrid1", "The Journal", "Reads & guides", "View all", _customItems()))));
  testWidgets("CustomTimelineList1", (t) async => _shoot(t, "CustomTimelineList1", CustomTimelineList1(content: _mc("CustomTimelineList1", "How It Works", "Three simple steps", "", _customItems()))));
  testWidgets("CountdownStripBanner1", (t) async => _shoot(t, "CountdownStripBanner1", CountdownStripBanner1(content: _mc("CountdownStripBanner1", "Sale Ends Soon", "Hurry", "Shop now", _pItems()))));
  testWidgets("AppDownloadBanner1", (t) async => _shoot(t, "AppDownloadBanner1", AppDownloadBanner1(content: _mc("AppDownloadBanner1", "Get the App", "Shop faster, track orders, get app-only deals", "Download", _pItems()))));
  testWidgets("TrustStripBanner1", (t) async => _shoot(t, "TrustStripBanner1", TrustStripBanner1(content: _mc("TrustStripBanner1", "Shop With Confidence", "", "", _pItems()))));
}
