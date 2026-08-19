// COMPREHENSIVE overflow audit — renders EVERY marketplace_registry component
// with realistic mock data and NO overflow-draining, so any RenderFlex overflow
// FAILS. Not for committing goldens (writes to audit/); purpose is to surface
// layout bugs across the whole component library.
//
//   flutter test test/cms_preview/overflow_audit_test.dart --update-goldens
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/ui/widgets/home/marketplace_registry.dart';

Future<ByteData> _bytes(String path) async =>
    ByteData.view((await File(path).readAsBytes()).buffer);
Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)..addFont(_bytes(path));
  await loader.load();
}
Future<void> _loadMaterialIcons() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  final candidates = <String>[
    if (root != null) '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
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

final List<Map<String, String>> _p = [
  {'t': 'Silk Blend Kurta', 'f': 'Handwoven everyday wear', 'b': 'Best Seller', 's': '299', 'o': '499', 'r': '4.8'},
  {'t': 'Cotton Anarkali Set', 'f': 'Floor-length with dupatta', 'b': 'New', 's': '449', 'o': '599', 'r': '4.7'},
  {'t': 'Banarasi Zari Dupatta', 'f': 'Festive-ready zari border', 'b': 'Trending', 's': '199', 'o': '349', 'r': '4.6'},
  {'t': 'Chikankari Tunic Top', 'f': 'Lucknowi hand embroidery', 'b': 'Best Seller', 's': '349', 'o': '599', 'r': '4.9'},
  {'t': 'Linen Palazzo Pants', 'f': 'Relaxed all-day comfort', 'b': 'New', 's': '249', 'o': '399', 'r': '4.5'},
  {'t': 'Party Sequin Saree', 'f': 'Sequin work, party perfect', 'b': 'Trending', 's': '499', 'o': '799', 'r': '4.8'},
];
List<LayoutDatum> _productItems() => List.generate(_p.length, (i) {
      final p = _p[i];
      return LayoutDatum(id: 'm$i', image: '', title: p['t'], subTitle: p['f'],
          featureText: p['f'], salesText: p['b'], rating: num.parse(p['r']!),
          prices: Prices(sellingPrice: p['s'], originalPrice: p['o']));
    });
final List<LayoutDatum> _categoryItems =
    ['Sarees', 'Kurtas & Suits', 'Dupattas', 'Lehengas', 'Palazzos', 'Accessories', 'New In', 'Sale']
        .map((c) => LayoutDatum(image: '', title: c)).toList();

Content _content(String layout, List<LayoutDatum> items) => Content(
      layoutName: layout,
      layoutTitle: 'Featured Collection',
      layoutSubTitle: 'Premium picks, curated for you this season',
      layoutRedirectTitle: 'View all',
      layoutRedirect: '#',
      layoutOption: 'Product',
      layoutData: items,
    );

// Pure overflow guard: pump the component at phone width. Any RenderFlex
// overflow is recorded by the framework and (not being drained) fails the test.
// No golden file — this is a layout-correctness check, not a visual snapshot.
Future<void> _pump(WidgetTester tester, Widget child, double width, double scale) async {
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = Size(width * 3, 2600 * 3);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: Colors.white),
    // Override the text scale so we catch layouts that break when a user bumps
    // their system font size (accessibility).
    builder: (ctx, w) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)),
      child: w!,
    ),
    home: Scaffold(backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Material(color: Colors.white, child: child))),
  ));
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
}

// Real device widths (SE / common Android / iPhone / Pro-Max) × text scales
// (default and accessibility-large). A robust card must survive all of them.
// The feed clamps text scale to 1.1 (clampCmsTextScale), so components never
// see more than that — test the realistic post-clamp range across real widths.
const _widths = <double>[320, 360, 390, 430];
const _scales = <double>[1.0, 1.1];

const _names = <String>[
  'AnnouncementBar1'  ,
'AppPromo1'  ,
'BeautyRail1'  ,
'BeautyShades1'  ,
'BeforeAfter1'  ,
'Blog1'  ,
'BrandWall1'  ,
'BuyAgain1'  ,
'CategoryCardRail1'  ,
'CategoryChips1'  ,
'CategoryCircle1'  ,
'CategoryCollection1'  ,
'CategoryMini1'  ,
'CategoryPills1'  ,
'CategorySpotlight1'  ,
'Certifications1'  ,
'CircleCategoryRail1'  ,
'CollectionCover1'  ,
'Combo1'  ,
'ContactSupport1'  ,
'CountBadgeRail1'  ,
'CouponRow1'  ,
'CuisineChips1'  ,
'DealStrip1'  ,
'DualBanner1'  ,
'ElectronicsDeals1'  ,
'ElectronicsGrid1'  ,
'EmailCapture1'  ,
'FaqCompact1'  ,
'FaqList1'  ,
'FarmStory1'  ,
'FeatureIcons1'  ,
'FooterCta1'  ,
'FreeDelivery1'  ,
'FreshMeats1'  ,
'FreshProduce1'  ,
'Gallery1'  ,
'GiftBanner1'  ,
'GroceryDeal1'  ,
'GroceryGrid1'  ,
'HeroBanner1'  ,
'HomeCollection1'  ,
'HowTo1'  ,
'IconActionNav1'  ,
'Instagram1'  ,
'LaunchCountdown1'  ,
'LimitedStock1'  ,
'ListCard1'  ,
'LookbookRail1'  ,
'Loyalty1'  ,
'LoyaltyProgress1'  ,
'MegaSpotlight1'  ,
'Membership1'  ,
'MinimalHero1'  ,
'MixedDeals1'  ,
'NewInTabs1'  ,
'NutritionFacts1'  ,
'OfferDuo1'  ,
'PharmacyBanner1'  ,
'PharmacyCategories1'  ,
'PickForYou1'  ,
'PincodeCheck1'  ,
'ProductCarouselXL1'  ,
'ProductHeroGrid1'  ,
'ProductListRow1'  ,
'ProductMini1'  ,
'ProductRatingGrid1'  ,
'ProductSpotlight1'  ,
'ProductStepper1'  ,
'PromoMarquee1'  ,
'RankedGrid1'  ,
'RatingSummary1'  ,
'RecentlyViewed1'  ,
'Recipe1'  ,
'Reels1'  ,
'Referral1'  ,
'ReorderRail1'  ,
'RestaurantOffers1'  ,
'RestaurantRail1'  ,
'Reviews1'  ,
'SaleCountdown1'  ,
'SearchHeroVertical1'  ,
'ServiceBooking1'  ,
'SizeGuide1'  ,
'SplitHero1'  ,
'SpotlightDuo1'  ,
'SpotlightList1'  ,
'StatBand1'  ,
'StickyOffer1'  ,
'StockUrgency1'  ,
'StorePickup1'  ,
'Story1'  ,
'StoryRail1'  ,
'SubscribeBox1'  ,
'SubscriptionBox1'  ,
'TabbedList1'  ,
'TestimonialBig1'  ,
'TextCta1'  ,
'TripleCollection1'  ,
'TrustBadges1'  ,
'TrustStrip1'  ,
'TwoColProducts1'  ,
'Ugc1'  ,
'VerticalSwitcher1'  ,
'VideoBanner1'  ,
'WalletCashback1'  ,
'WideProductCard1'  ,
'Wishlist1'
];

bool _isCategory(String n) =>
    n.contains('Categor') || n.contains('Cuisine') || n.startsWith('Circle');

// KNOWN RESPONSIVE GAPS — these overflow at 320px width and/or under text
// scaling (fixed-height cards / aspect-ratio grids that don't adapt). Tracked
// for a dedicated responsive-layout pass; skipped here so the guard stays green
// and catches NEW regressions in the 88 already-robust components. Removing a
// name from this set (after fixing it) re-enables full-matrix enforcement.
const _knownGaps = <String>{};

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await CurrencyUtil.initializeCurrencySymbol('Rs ');
    await _loadFont('CircularStd', 'fonts/circular_std_book_regular.ttf');
    await _loadFont('Gabarito', 'fonts/gabarito_regular.ttf');
    await _loadMaterialIcons();
  });
  for (final layout in _names) {
    if (_knownGaps.contains(layout)) continue; // tracked separately
    for (final width in _widths) {
      for (final scale in _scales) {
        testWidgets('$layout @${width.toInt()}w x$scale', (t) async {
          final w = marketplaceHomeWidget(
              _content(layout, _isCategory(layout) ? _categoryItems : _productItems()));
          if (w == null) return;
          await _pump(t, w, width, scale);
        });
      }
    }
  }
}
