// Golden harness for the NEW native banner widgets (Area 3 mobile batch 1).
// Generate: flutter test test/cms_preview/banner_previews_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/hero_image_banner1.dart';
import 'package:waioz/ui/widgets/home/split_banner1.dart';
import 'package:waioz/ui/widgets/home/gradient_cta_bar1.dart';
import 'package:waioz/ui/widgets/home/dual_offer_banner1.dart';
import 'package:waioz/ui/widgets/home/carousel_banner1.dart';
import 'package:waioz/ui/widgets/home/triple_promo_banner1.dart';
import 'package:waioz/ui/widgets/home/countdown_banner1.dart';
import 'package:waioz/ui/widgets/home/video_hero_banner1.dart';

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

const _tiles = [
  {'t': 'Festive Sale', 'f': 'Up to 60% off'},
  {'t': 'New Arrivals', 'f': 'Fresh this week'},
  {'t': 'Best of Ethnic', 'f': 'Handpicked edit'},
];

List<LayoutDatum> _mockItems() => List.generate(_tiles.length, (i) => LayoutDatum(
      id: 'b-$i', image: '', title: _tiles[i]['t'], featureText: _tiles[i]['f'], subTitle: _tiles[i]['f']));

Content _mockContent(String layout, String title, String subtitle, String cta) =>
    Content(
      layoutName: layout,
      layoutTitle: title,
      layoutSubTitle: subtitle,
      layoutRedirectTitle: cta,
      layoutRedirect: '#',
      layoutBannerImage: '',
      layoutOption: 'Custom',
      layoutData: _mockItems(),
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

  testWidgets("HeroImageBanner1", (t) async =>
      _shoot(t, "HeroImageBanner1", HeroImageBanner1(content: _mockContent("HeroImageBanner1", "The Festive Edit is Here", "New Collection", "Shop the edit"))));
  testWidgets("SplitBanner1", (t) async =>
      _shoot(t, "SplitBanner1", SplitBanner1(content: _mockContent("SplitBanner1", "Made for the Season", "Just Dropped", "Explore now"))));
  testWidgets("GradientCtaBar1", (t) async =>
      _shoot(t, "GradientCtaBar1", GradientCtaBar1(content: _mockContent("GradientCtaBar1", "Free shipping over Rs 999", "Today only", "Shop now"))));
  testWidgets("DualOfferBanner1", (t) async =>
      _shoot(t, "DualOfferBanner1", DualOfferBanner1(content: _mockContent("DualOfferBanner1", "Two Big Offers", "Double the savings", "Shop now"))));
  testWidgets("CarouselBanner1", (t) async =>
      _shoot(t, "CarouselBanner1", CarouselBanner1(content: _mockContent("CarouselBanner1", "Season of Celebration", "Up to 40% off", "Shop now"))));
  testWidgets("TriplePromoBanner1", (t) async =>
      _shoot(t, "TriplePromoBanner1", TriplePromoBanner1(content: _mockContent("TriplePromoBanner1", "Three Ways to Save", "This week only", "Shop"))));
  testWidgets("CountdownBanner1", (t) async =>
      _shoot(t, "CountdownBanner1", CountdownBanner1(content: _mockContent("CountdownBanner1", "Mega Sale Ends Soon", "Hurry, limited time", "Grab the deals"))));
  testWidgets("VideoHeroBanner1", (t) async =>
      _shoot(t, "VideoHeroBanner1", VideoHeroBanner1(content: _mockContent("VideoHeroBanner1", "Watch the Story", "New Campaign", "Play & shop"))));
}
