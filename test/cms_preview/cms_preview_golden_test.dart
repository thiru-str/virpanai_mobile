// Golden harness that renders the NEW mobile merchandising components with
// standardized, image-less mock data (clean skeleton-style previews) at phone
// width and writes crisp reference PNGs.
//
// Generate:   flutter test test/cms_preview/cms_preview_golden_test.dart --update-goldens
// Output:     test/cms_preview/goldens/<LayoutName>.png
// Publish:    scripts/copy_cms_previews.sh  (copies goldens -> docs/component-reference)
//
// Previews render the REAL widgets + REAL bundled fonts, so they never drift
// from the shipped code. Images are intentionally empty so each widget shows
// its own neutral placeholder.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/ui/widgets/home/banner_5.dart';
import 'package:waioz/ui/widgets/home/banner_6.dart';
import 'package:waioz/ui/widgets/home/banner_7.dart';
import 'package:waioz/ui/widgets/home/item_15.dart';
import 'package:waioz/ui/widgets/home/item_16.dart';
import 'package:waioz/ui/widgets/home/slider_10.dart';
import 'package:waioz/ui/widgets/home/slider_11.dart';
import 'package:waioz/ui/widgets/home/slider_12.dart';
import 'package:waioz/ui/widgets/home/grocery_grid1.dart';
import 'package:waioz/ui/widgets/home/grocery_rail_base.dart';
import 'package:waioz/ui/widgets/home/category_chips1.dart';
import 'package:waioz/ui/widgets/home/combo1.dart';
import 'package:waioz/ui/widgets/home/free_delivery1.dart';
import 'package:waioz/ui/widgets/home/vertical_switcher1.dart';
import 'package:waioz/ui/widgets/home/restaurant_rail1.dart';
import 'package:waioz/ui/widgets/home/cuisine_chips1.dart';
import 'package:waioz/ui/widgets/home/pharmacy_banner1.dart';
import 'package:waioz/ui/widgets/home/home_collection1.dart';
import 'package:waioz/ui/widgets/home/vertical_products.dart';
import 'package:waioz/ui/widgets/home/hero_promo1.dart';
import 'package:waioz/ui/widgets/home/trust_email1.dart';
import 'package:waioz/ui/widgets/home/reviews_coupons1.dart';
import 'package:waioz/ui/widgets/home/brand_faq1.dart';
import 'package:waioz/ui/widgets/home/composites1.dart';
import 'package:waioz/ui/widgets/home/composites2.dart';
import 'package:waioz/ui/widgets/home/conversion1.dart';
import 'package:waioz/ui/widgets/home/content_media1.dart';
import 'package:waioz/ui/widgets/home/vertical_deep1.dart';
import 'package:waioz/ui/widgets/home/vertical_deep2.dart';
import 'package:waioz/ui/widgets/home/media_deep1.dart';
import 'package:waioz/ui/widgets/home/conversion_deep1.dart';
import 'package:waioz/ui/widgets/home/hero_spotlight1.dart';
import 'package:waioz/ui/widgets/home/hero_spotlight2.dart';
import 'package:waioz/ui/widgets/home/extras1.dart';
import 'package:waioz/ui/widgets/home/extras2.dart';
import 'package:waioz/ui/widgets/home/finish_a.dart';
import 'package:waioz/ui/widgets/home/finish_b.dart';
import 'package:waioz/ui/widgets/home/finish_c.dart';
import 'package:waioz/ui/widgets/home/finish_d.dart';
import 'package:waioz/ui/widgets/home/premium_app_headers.dart';

Future<ByteData> _bytes(String path) async =>
    ByteData.view((await File(path).readAsBytes()).buffer);

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family);
  loader.addFont(_bytes(path));
  await loader.load();
}

// Load the MaterialIcons glyph font from the SDK so Icon() widgets render real
// icons in goldens instead of empty boxes.
Future<void> _loadMaterialIcons() async {
  final env = Platform.environment;
  final root = env['FLUTTER_ROOT'];
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

// Realistic, image-less product items shared across all components.
final List<Map<String, String>> _products = [
  {'title': 'Silk Blend Kurta', 'feature': 'Handwoven everyday wear', 'badge': 'Best Seller', 'sell': '1,299', 'orig': '1,999', 'rating': '4.8'},
  {'title': 'Cotton Anarkali Set', 'feature': 'Floor-length with dupatta', 'badge': 'New', 'sell': '2,499', 'orig': '3,299', 'rating': '4.7'},
  {'title': 'Banarasi Dupatta', 'feature': 'Zari border, festive ready', 'badge': 'Trending', 'sell': '899', 'orig': '1,499', 'rating': '4.6'},
  {'title': 'Chikankari Tunic', 'feature': 'Lucknowi hand embroidery', 'badge': 'Best Seller', 'sell': '1,749', 'orig': '2,599', 'rating': '4.9'},
  {'title': 'Linen Palazzo', 'feature': 'Relaxed all-day comfort', 'badge': 'New', 'sell': '1,099', 'orig': '1,599', 'rating': '4.5'},
  {'title': 'Embroidered Saree', 'feature': 'Sequin work, party perfect', 'badge': 'Trending', 'sell': '3,299', 'orig': '4,999', 'rating': '4.8'},
];

List<LayoutDatum> _mockItems({bool sub = true}) => List.generate(_products.length, (i) {
      final p = _products[i];
      return LayoutDatum(
        id: 'mock-$i',
        image: '', // empty -> neutral placeholder, no network
        title: p['title'],
        subTitle: sub ? p['feature'] : null,
        featureText: sub ? p['feature'] : null,
        salesText: p['badge'],
        rating: num.parse(p['rating']!),
        prices: Prices(sellingPrice: p['sell'], originalPrice: p['orig']),
      );
    });

Content _mockContent(String layout, String title, String subtitle, String cta, {bool sub = true}) => Content(
      layoutName: layout,
      layoutTitle: title,
      layoutSubTitle: subtitle,
      layoutRedirectTitle: cta,
      layoutRedirect: '#',
      layoutOption: 'Product',
      // Leave layout background unset so the widget stays transparent and the
      // harness's opaque white Material shows through (the app's bg parser
      // expects rgb()/named colours, not hex).
      layoutData: _mockItems(sub: sub),
    );

// ---- Grocery / supermarket mock data ----
LayoutDatum _g(String title, String unit, String sell, [String orig = '', String badge = '']) =>
    LayoutDatum(
      image: '',
      title: title,
      featureText: unit,
      salesText: badge.isEmpty ? null : badge,
      prices: Prices(sellingPrice: sell, originalPrice: orig.isEmpty ? null : orig),
    );

final List<LayoutDatum> _groceryItems = [
  _g('Fresh Tomatoes', '500 g', '30'),
  _g('Amul Milk', '1 L', '68'),
  _g('Bananas (Robusta)', '6 pcs', '45'),
  _g('Basmati Rice', '1 kg', '120', '149'),
  _g('Farm Eggs', '12 pcs', '84'),
  _g('Malai Paneer', '200 g', '90', '110'),
];
final List<LayoutDatum> _meatItems = [
  _g('Chicken Breast', '500 g', '180', '220', 'Fresh'),
  _g('Mutton Curry Cut', '500 g', '380', '420', 'Fresh'),
  _g('Chicken Curry Cut', '1 kg', '240', '', 'Fresh'),
  _g('Rohu Fish', '500 g', '160', '190', 'Fresh'),
  _g('Prawns (Medium)', '250 g', '210', '', 'Fresh'),
  _g('Chicken Wings', '500 g', '150', '175', 'Fresh'),
];
final List<LayoutDatum> _produceItems = [
  _g('Tomatoes', '500 g', '30'),
  _g('Onions', '1 kg', '40', '52'),
  _g('Bananas', '6 pcs', '45'),
  _g('Baby Spinach', '250 g', '35'),
  _g('Apples (Shimla)', '1 kg', '160', '199'),
  _g('Potatoes', '1 kg', '38'),
];
final List<LayoutDatum> _catItems =
    ['Vegetables', 'Fruits', 'Dairy', 'Meat', 'Bakery', 'Beverages', 'Staples', 'Household']
        .map((c) => LayoutDatum(title: c))
        .toList();

// ---- Multi-vertical mock data ----
final List<LayoutDatum> _verticals = [
  _g('Grocery', '30-min delivery', ''),
  _g('Food', 'Order in', ''),
  _g('Pharmacy', 'Up to 25% off', ''),
  _g('Electronics', 'No Cost EMI', ''),
  _g('Fashion', 'New arrivals', ''),
  _g('Beauty', 'Top brands', ''),
];
final List<LayoutDatum> _electronics = [
  _g('Wireless Earbuds', '40h battery • ANC', '1,499', '1,999'),
  _g('Smart Watch', 'AMOLED • GPS', '2,999', '3,999'),
  _g('Power Bank', '20000 mAh • 22.5W', '999', '1,299'),
  _g('Bluetooth Speaker', 'IPX7 • 12W', '1,799', '2,299'),
];
final List<LayoutDatum> _dishes = [
  _g('Margherita Pizza', '', '249', '', 'veg')..rating = 4.3,
  _g('Chicken Biryani', '', '199', '', 'nonveg')..rating = 4.5,
  _g('Paneer Butter Masala', '', '220', '', 'veg')..rating = 4.2,
  _g('Butter Chicken', '', '280', '', 'nonveg')..rating = 4.6,
  _g('Veg Hakka Noodles', '', '149', '', 'veg')..rating = 4.1,
];
final List<LayoutDatum> _cuisines =
    ['Pizza', 'Biryani', 'Chinese', 'Desserts', 'Burgers', 'Cafe', 'Thali', 'Ice Cream']
        .map((c) => LayoutDatum(title: c))
        .toList();
final List<LayoutDatum> _beauty = [
  _g('Matte Lipstick', '3.5 g', '399', '499'),
  _g('Vitamin C Serum', '30 ml', '649'),
  _g('Kajal', '0.35 g', '199'),
  _g('Sunscreen SPF50', '50 ml', '449', '549'),
  _g('Compact Powder', '9 g', '299'),
];
final List<LayoutDatum> _homeCol = [
  _g('Living Room', 'Sofas, tables & decor', ''),
  _g('Bedroom', 'Beds, storage & linen', ''),
];
final List<LayoutDatum> _mixedDeals = [
  _g('Wireless Earbuds', '', '1,499', '1,999', 'Electronics'),
  _g('Basmati Rice 5kg', '', '480', '599', 'Grocery'),
  _g('Cotton Kurta', '', '799', '1,299', 'Fashion'),
  _g('Vitamin C Serum', '', '649', '849', 'Beauty'),
  _g('Yoga Mat', '', '599', '899', 'Fitness'),
];

// ---- General premium (cross-vertical) mock data ----
final List<LayoutDatum> _trust = [
  _g('Free Shipping', 'Over Rs 499', ''),
  _g('Easy Returns', '7-day policy', ''),
  _g('Secure Pay', '100% protected', ''),
  _g('24x7 Support', 'Always here', ''),
];
final List<LayoutDatum> _reviews = [
  _g('Ananya R.', 'The quality is amazing and delivery was super quick. Highly recommend!', '')..rating = 5,
  _g('Priya M.', 'Exactly as shown in the photos. Loved every bit of it.', '')..rating = 5,
  _g('Kavya S.', 'Great value for money. Will order again for sure.', '')..rating = 4,
];
final List<LayoutDatum> _coupons = [
  _g('WELCOME10', 'On your first order', '', '', 'FLAT 10% OFF'),
  _g('FESTIVE25', 'Min. spend Rs 999', '', '', 'FLAT 25% OFF'),
  _g('FREESHIP', 'No minimum order', '', '', 'FREE DELIVERY'),
];
final List<LayoutDatum> _brands =
    ['Fabindia', 'Biba', 'W', 'Aurelia', 'Libas', 'Global Desi'].map((b) => LayoutDatum(title: b)).toList();
final List<LayoutDatum> _faqs = [
  _g('What is your return policy?', 'We offer easy 7-day returns on all unused items with tags intact.', ''),
  _g('How long does delivery take?', '', ''),
  _g('Do you offer cash on delivery?', '', ''),
  _g('How do I track my order?', '', ''),
];

final List<LayoutDatum> _blog = [
  _g('5 Ways to Style a Dupatta', 'Effortless drapes for any outfit.', '', '', 'Style Guide'),
  _g('The Story of Chikankari', 'A centuries-old craft, reimagined.', '', '', 'Heritage'),
  _g('Festive Dressing 101', 'Our edit of celebration-ready looks.', '', '', 'Edit'),
];
final List<LayoutDatum> _howto = [
  _g('Browse', 'Explore curated edits and find favourites.', ''),
  _g('Add to Cart', 'Pick your size and add what you love.', ''),
  _g('Checkout', 'Secure payment with COD and wallet.', ''),
  _g('Enjoy', 'Fast delivery and easy 7-day returns.', ''),
];

final List<LayoutDatum> _services =
    ['Salon at Home', 'Appliance Repair', 'Home Cleaning', 'Plumbing', 'Electrician', 'Spa & Massage']
        .map((s) => LayoutDatum(title: s)).toList();
final List<LayoutDatum> _restOffers = [
  _g('Spice Garden', 'North Indian', '', '', 'FLAT 50% OFF')..rating = 4.3,
  _g('Wok & Roll', 'Chinese • Asian', '', '', '60% OFF up to Rs 120')..rating = 4.5,
  _g('The Biryani Co.', 'Biryani • Mughlai', '', '', 'Buy 1 Get 1')..rating = 4.4,
];
final List<LayoutDatum> _pharmaCats =
    ['Medicines', 'Wellness', 'Devices', 'Baby Care', 'Fitness', 'Eye Care', 'Vaccines', 'Personal Care']
        .map((s) => LayoutDatum(title: s)).toList();

final List<LayoutDatum> _actions =
    ['My Orders', 'Wishlist', 'Wallet', 'Support'].map((s) => LayoutDatum(title: s)).toList();

Content _grocery(String layout, String title, String subtitle, String cta, List<LayoutDatum> items) =>
    Content(
      layoutName: layout,
      layoutTitle: title,
      layoutSubTitle: subtitle,
      layoutRedirectTitle: cta,
      layoutRedirect: '#',
      layoutOption: 'Product',
      layoutData: items,
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
          child: RepaintBoundary(
            key: key,
            child: Material(color: Colors.white, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
  await expectLater(
    find.byKey(key),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    // Render the rupee as "Rs " in previews: the bundled app fonts lack the
    // ₹ (U+20B9) glyph, so in a golden (no OS font fallback) it would tofu.
    // On-device the OS supplies ₹; here we keep prices legible for the catalog.
    await CurrencyUtil.initializeCurrencySymbol('Rs ');
    await _loadFont('CircularStd', 'fonts/circular_std_book_regular.ttf');
    await _loadFont('Gabarito', 'fonts/gabarito_regular.ttf');
    await _loadMaterialIcons();
  });

  testWidgets('Slider10', (t) async =>
      _shoot(t, 'Slider10', Slider10(content: _mockContent('Slider10', 'Quick Picks', 'Fast-moving favourites', 'View collection'))));
  testWidgets('Slider11', (t) async =>
      _shoot(t, 'Slider11', Slider11(content: _mockContent('Slider11', 'Editorial Rail', 'Story-led selections', 'Explore'))));
  testWidgets('Slider12', (t) async =>
      _shoot(t, 'Slider12', Slider12(content: _mockContent('Slider12', 'Signature Shapes', 'Discovery blocks', 'Discover more'))));
  testWidgets('Banner5', (t) async =>
      _shoot(t, 'Banner5', Banner5(content: _mockContent('Banner5', 'Festive Edit', 'Campaign spotlight', 'Shop campaign'))));
  testWidgets('Banner6', (t) async =>
      _shoot(t, 'Banner6', Banner6(content: _mockContent('Banner6', 'Why Customers Stay', 'Trusted by thousands', 'Learn more'))));
  testWidgets('Banner7', (t) async =>
      _shoot(t, 'Banner7', Banner7(content: _mockContent('Banner7', 'Editorial Banners', 'Curated stories', 'Explore'))));
  testWidgets('item15', (t) async =>
      _shoot(t, 'item15', Item15(content: _mockContent('item15', 'Premium Shelf', 'Handpicked for you', 'View collection'))));
  testWidgets('item16', (t) async =>
      _shoot(t, 'item16', Item16(content: _mockContent('item16', 'Editorial Discovery', 'Lead + companions', 'See more'))));

  // ---- Grocery / supermarket batch ----
  testWidgets('CategoryChips1', (t) async =>
      _shoot(t, 'CategoryChips1', CategoryChips1(content: _grocery('CategoryChips1', 'Shop by Category', '', '', _catItems))));
  testWidgets('GroceryGrid1', (t) async =>
      _shoot(t, 'GroceryGrid1', GroceryGrid1(content: _grocery('GroceryGrid1', 'Daily Essentials', 'Everyday staples', 'See all', _groceryItems))));
  testWidgets('FreshMeats1', (t) async =>
      _shoot(t, 'FreshMeats1', FreshMeats1(content: _grocery('FreshMeats1', 'Fresh Meats', 'Cut & delivered fresh', 'View all', _meatItems))));
  testWidgets('FreshProduce1', (t) async =>
      _shoot(t, 'FreshProduce1', FreshProduce1(content: _grocery('FreshProduce1', 'Fresh Fruits & Veg', 'Farm to doorstep', 'View all', _produceItems))));
  testWidgets('GroceryDeal1', (t) async =>
      _shoot(t, 'GroceryDeal1', GroceryDeal1(content: _grocery('GroceryDeal1', 'Deals of the Day', 'Save big today', 'View all', _groceryItems))));
  testWidgets('BuyAgain1', (t) async =>
      _shoot(t, 'BuyAgain1', BuyAgain1(content: _grocery('BuyAgain1', 'Buy It Again', 'Your regulars', 'View all', _groceryItems))));
  testWidgets('Combo1', (t) async =>
      _shoot(t, 'Combo1', Combo1(content: _grocery('Combo1', 'Breakfast Combo', 'Buy together & save', 'Add combo', _groceryItems))));
  testWidgets('FreeDelivery1', (t) async =>
      _shoot(t, 'FreeDelivery1', FreeDelivery1(content: _grocery('FreeDelivery1', 'Free delivery over Rs 199', 'Delivered in 30 minutes or less', '', _groceryItems))));

  // ---- Multi-vertical batch ----
  testWidgets('VerticalSwitcher1', (t) async =>
      _shoot(t, 'VerticalSwitcher1', VerticalSwitcher1(content: _grocery('VerticalSwitcher1', 'Shop Everything', 'One app, every vertical', '', _verticals))));
  testWidgets('ElectronicsGrid1', (t) async =>
      _shoot(t, 'ElectronicsGrid1', ElectronicsGrid1(content: _grocery('ElectronicsGrid1', 'Top Electronics', 'Latest gadgets', 'View all', _electronics))));
  testWidgets('RestaurantRail1', (t) async =>
      _shoot(t, 'RestaurantRail1', RestaurantRail1(content: _grocery('RestaurantRail1', 'Order Food', 'Bestsellers near you', 'View all', _dishes))));
  testWidgets('CuisineChips1', (t) async =>
      _shoot(t, 'CuisineChips1', CuisineChips1(content: _grocery('CuisineChips1', 'Whats on your mind?', '', '', _cuisines))));
  testWidgets('PharmacyBanner1', (t) async =>
      _shoot(t, 'PharmacyBanner1', PharmacyBanner1(content: _grocery('PharmacyBanner1', 'Order Medicines', 'Upload prescription • Up to 25% off', 'Upload', _groceryItems))));
  testWidgets('BeautyRail1', (t) async =>
      _shoot(t, 'BeautyRail1', BeautyRail1(content: _grocery('BeautyRail1', 'Beauty & Personal Care', 'Top-rated picks', 'View all', _beauty))));
  testWidgets('HomeCollection1', (t) async =>
      _shoot(t, 'HomeCollection1', HomeCollection1(content: _grocery('HomeCollection1', 'Home & Living', 'Shop by room', '', _homeCol))));
  testWidgets('MixedDeals1', (t) async =>
      _shoot(t, 'MixedDeals1', MixedDeals1(content: _grocery('MixedDeals1', 'Deals Across Categories', 'Best of every vertical', 'View all', _mixedDeals))));

  // ---- General premium (cross-vertical) batch ----
  testWidgets('HeroBanner1', (t) async =>
      _shoot(t, 'HeroBanner1', HeroBanner1(content: _grocery('HeroBanner1', 'The Festive Sale', 'New Collection', 'Shop now', _groceryItems))));
  testWidgets('SaleCountdown1', (t) async =>
      _shoot(t, 'SaleCountdown1', SaleCountdown1(content: _grocery('SaleCountdown1', 'Sale Ends Soon', 'Limited Time', '', _groceryItems))));
  testWidgets('TrustStrip1', (t) async =>
      _shoot(t, 'TrustStrip1', TrustStrip1(content: _grocery('TrustStrip1', '', '', '', _trust))));
  testWidgets('EmailCapture1', (t) async =>
      _shoot(t, 'EmailCapture1', EmailCapture1(content: _grocery('EmailCapture1', 'Get 10% Off', 'Join our list for offers & new drops', 'Subscribe', _groceryItems))));
  testWidgets('Reviews1', (t) async =>
      _shoot(t, 'Reviews1', Reviews1(content: _grocery('Reviews1', 'Loved by Customers', 'Real reviews', '', _reviews))));
  testWidgets('CouponRow1', (t) async =>
      _shoot(t, 'CouponRow1', CouponRow1(content: _grocery('CouponRow1', 'Offers For You', 'Apply at checkout', '', _coupons))));
  testWidgets('BrandWall1', (t) async =>
      _shoot(t, 'BrandWall1', BrandWall1(content: _grocery('BrandWall1', 'Shop by Brand', 'Top labels', '', _brands))));
  testWidgets('FaqList1', (t) async =>
      _shoot(t, 'FaqList1', FaqList1(content: _grocery('FaqList1', 'FAQs', 'Good to know', '', _faqs))));

  // ---- Composite (multi-element, less-common) batch ----
  testWidgets('SpotlightList1', (t) async =>
      _shoot(t, 'SpotlightList1', SpotlightList1(content: _grocery('SpotlightList1', 'Featured + More', 'Spotlight with picks', '', _electronics))));
  testWidgets('CategoryCollection1', (t) async =>
      _shoot(t, 'CategoryCollection1', CategoryCollection1(content: _grocery('CategoryCollection1', 'Explore Collections', 'By category', '', _catItems))));
  testWidgets('ListCard1', (t) async =>
      _shoot(t, 'ListCard1', ListCard1(content: _grocery('ListCard1', 'Top Rated Near You', 'Ranked picks', 'View all', _dishes))));
  testWidgets('StoryRail1', (t) async =>
      _shoot(t, 'StoryRail1', StoryRail1(content: _grocery('StoryRail1', 'Collections', 'Tap to explore', '', _catItems))));
  testWidgets('CollectionCover1', (t) async =>
      _shoot(t, 'CollectionCover1', CollectionCover1(content: _grocery('CollectionCover1', 'The Festive Edit', '42 handpicked styles', '', _groceryItems))));
  testWidgets('MegaSpotlight1', (t) async =>
      _shoot(t, 'MegaSpotlight1', MegaSpotlight1(content: _grocery('MegaSpotlight1', 'Deal Zone', 'Everything in one place', '', _groceryItems))));
  testWidgets('TabbedList1', (t) async =>
      _shoot(t, 'TabbedList1', TabbedList1(content: _grocery('TabbedList1', 'Whats Hot', 'Switch the view', '', _electronics))));
  testWidgets('PickForYou1', (t) async =>
      _shoot(t, 'PickForYou1', PickForYou1(content: _grocery('PickForYou1', 'Picked For You', 'Based on your taste', '', _mixedDeals))));

  // ---- Conversion + content + media batch ----
  testWidgets('Loyalty1', (t) async =>
      _shoot(t, 'Loyalty1', Loyalty1(content: _grocery('Loyalty1', 'Earn Points on Every Order', 'Unlock perks & birthday treats', 'Join', _groceryItems))));
  testWidgets('Referral1', (t) async =>
      _shoot(t, 'Referral1', Referral1(content: _grocery('Referral1', 'Refer a Friend, Get Rs 300', 'They get Rs 300 off too', 'Invite', _groceryItems))));
  testWidgets('Wishlist1', (t) async =>
      _shoot(t, 'Wishlist1', Wishlist1(content: _grocery('Wishlist1', 'Your Wishlist', 'Saved for later', 'View all', _mixedDeals))));
  testWidgets('StockUrgency1', (t) async =>
      _shoot(t, 'StockUrgency1', StockUrgency1(content: _grocery('StockUrgency1', 'Selling fast — 200+ sold in the last 24 hours', '', '', _groceryItems))));
  testWidgets('Blog1', (t) async =>
      _shoot(t, 'Blog1', Blog1(content: _grocery('Blog1', 'From the Journal', 'Stories & style', 'View all', _blog))));
  testWidgets('Story1', (t) async =>
      _shoot(t, 'Story1', Story1(content: _grocery('Story1', 'Rooted in Craft', 'Our Story', 'Read our story', <LayoutDatum>[]))));
  testWidgets('HowTo1', (t) async =>
      _shoot(t, 'HowTo1', HowTo1(content: _grocery('HowTo1', 'How It Works', 'Simple & seamless', '', _howto))));
  testWidgets('Reels1', (t) async =>
      _shoot(t, 'Reels1', Reels1(content: _grocery('Reels1', 'Watch & Shop', 'Trending reels', 'View all', _dishes))));

  // ---- Per-vertical depth batch ----
  testWidgets('SearchHeroVertical1', (t) async =>
      _shoot(t, 'SearchHeroVertical1', SearchHeroVertical1(content: _grocery('SearchHeroVertical1', 'What are you looking for?', '', '', _verticals))));
  testWidgets('ServiceBooking1', (t) async =>
      _shoot(t, 'ServiceBooking1', ServiceBooking1(content: _grocery('ServiceBooking1', 'Book a Service', 'At your doorstep', '', _services))));
  testWidgets('WalletCashback1', (t) async =>
      _shoot(t, 'WalletCashback1', WalletCashback1(content: _grocery('WalletCashback1', 'Wallet Balance Rs 250', 'Earn 5% cashback on every order', 'Add money', _groceryItems))));
  testWidgets('StorePickup1', (t) async =>
      _shoot(t, 'StorePickup1', StorePickup1(content: _grocery('StorePickup1', 'Pickup in Store', 'Ready in 2 hours at your nearest store', '', _groceryItems))));
  testWidgets('RestaurantOffers1', (t) async =>
      _shoot(t, 'RestaurantOffers1', RestaurantOffers1(content: _grocery('RestaurantOffers1', 'Offers Near You', 'Save on your favourites', 'View all', _restOffers))));
  testWidgets('ElectronicsDeals1', (t) async =>
      _shoot(t, 'ElectronicsDeals1', ElectronicsDeals1(content: _grocery('ElectronicsDeals1', 'Gadget Deals', 'Lowest prices', 'View all', _electronics))));
  testWidgets('PharmacyCategories1', (t) async =>
      _shoot(t, 'PharmacyCategories1', PharmacyCategories1(content: _grocery('PharmacyCategories1', 'Health & Wellness', 'Shop by need', '', _pharmaCats))));
  testWidgets('BeautyShades1', (t) async =>
      _shoot(t, 'BeautyShades1', BeautyShades1(content: _grocery('BeautyShades1', 'Find Your Shade', 'Matte Lipstick', '', _beauty))));

  // ---- Media + conversion depth batch ----
  testWidgets('Instagram1', (t) async =>
      _shoot(t, 'Instagram1', Instagram1(content: _grocery('Instagram1', 'Follow Our Journey', '#yourbrand', '@yourbrand', _groceryItems))));
  testWidgets('Ugc1', (t) async =>
      _shoot(t, 'Ugc1', Ugc1(content: _grocery('Ugc1', 'Styled by You', 'Tag us to be featured', '', _groceryItems))));
  testWidgets('Gallery1', (t) async =>
      _shoot(t, 'Gallery1', Gallery1(content: _grocery('Gallery1', 'The Mood Board', 'Visual inspiration', '', _groceryItems))));
  testWidgets('BeforeAfter1', (t) async =>
      _shoot(t, 'BeforeAfter1', BeforeAfter1(content: _grocery('BeforeAfter1', 'See the Difference', 'Before & after', '', _groceryItems))));
  testWidgets('SizeGuide1', (t) async =>
      _shoot(t, 'SizeGuide1', SizeGuide1(content: _grocery('SizeGuide1', 'Not sure about your size?', 'Use our fit finder', 'Find', _groceryItems))));
  testWidgets('PincodeCheck1', (t) async =>
      _shoot(t, 'PincodeCheck1', PincodeCheck1(content: _grocery('PincodeCheck1', 'Check Delivery', '', 'Check', _groceryItems))));
  testWidgets('AppPromo1', (t) async =>
      _shoot(t, 'AppPromo1', AppPromo1(content: _grocery('AppPromo1', 'Exclusive App Deals', 'Unlock app-only offers & faster checkout', 'Explore', _groceryItems))));
  testWidgets('Membership1', (t) async =>
      _shoot(t, 'Membership1', Membership1(content: _grocery('Membership1', 'Join Premium', 'Membership', 'Become a member', <LayoutDatum>[]))));

  // ---- Hero / spotlight / collection variants batch ----
  testWidgets('SplitHero1', (t) async =>
      _shoot(t, 'SplitHero1', SplitHero1(content: _grocery('SplitHero1', 'Crafted for Every Occasion', 'Handloom', 'Explore', _groceryItems))));
  testWidgets('ProductSpotlight1', (t) async =>
      _shoot(t, 'ProductSpotlight1', ProductSpotlight1(content: _grocery('ProductSpotlight1', 'Editors Pick', 'Featured', 'Add to bag', _electronics))));
  testWidgets('TripleCollection1', (t) async =>
      _shoot(t, 'TripleCollection1', TripleCollection1(content: _grocery('TripleCollection1', 'Explore Collections', 'Curated edits', '', _catItems))));
  testWidgets('DualBanner1', (t) async =>
      _shoot(t, 'DualBanner1', DualBanner1(content: _grocery('DualBanner1', '', '', '', _mixedDeals))));
  testWidgets('RankedGrid1', (t) async =>
      _shoot(t, 'RankedGrid1', RankedGrid1(content: _grocery('RankedGrid1', 'Top Bestsellers', 'Most-loved this week', 'View all', _mixedDeals))));
  testWidgets('CategorySpotlight1', (t) async =>
      _shoot(t, 'CategorySpotlight1', CategorySpotlight1(content: _grocery('CategorySpotlight1', 'The Wedding Edit', 'New Collection', 'Explore', _groceryItems))));
  testWidgets('LookbookRail1', (t) async =>
      _shoot(t, 'LookbookRail1', LookbookRail1(content: _grocery('LookbookRail1', 'The Lookbook', 'Style inspiration', '', _catItems))));
  testWidgets('LaunchCountdown1', (t) async =>
      _shoot(t, 'LaunchCountdown1', LaunchCountdown1(content: _grocery('LaunchCountdown1', 'Dropping Soon', 'New Launch', 'Notify me', _groceryItems))));

  // ---- Extras batch ----
  testWidgets('FeatureIcons1', (t) async =>
      _shoot(t, 'FeatureIcons1', FeatureIcons1(content: _grocery('FeatureIcons1', 'Why Shop With Us', 'The difference', '', _trust))));
  testWidgets('TestimonialBig1', (t) async =>
      _shoot(t, 'TestimonialBig1', TestimonialBig1(content: _grocery('TestimonialBig1', '', '', '', _reviews))));
  testWidgets('StatBand1', (t) async =>
      _shoot(t, 'StatBand1', StatBand1(content: _grocery('StatBand1', '', '', '', _groceryItems))));
  testWidgets('CategoryCardRail1', (t) async =>
      _shoot(t, 'CategoryCardRail1', CategoryCardRail1(content: _grocery('CategoryCardRail1', 'Shop by Category', 'Find your fit', 'View all', _catItems))));
  testWidgets('TwoColProducts1', (t) async =>
      _shoot(t, 'TwoColProducts1', TwoColProducts1(content: _grocery('TwoColProducts1', 'New Arrivals', 'Just landed', 'View all', _electronics))));
  testWidgets('OfferDuo1', (t) async =>
      _shoot(t, 'OfferDuo1', OfferDuo1(content: _grocery('OfferDuo1', '', '', '', _coupons))));
  testWidgets('NewInTabs1', (t) async =>
      _shoot(t, 'NewInTabs1', NewInTabs1(content: _grocery('NewInTabs1', 'Fresh Finds', 'Switch the view', '', _groceryItems))));
  testWidgets('TrustBadges1', (t) async =>
      _shoot(t, 'TrustBadges1', TrustBadges1(content: _grocery('TrustBadges1', '', '', '', _groceryItems))));

  // ---- Finishing batch A ----
  testWidgets('MinimalHero1', (t) async =>
      _shoot(t, 'MinimalHero1', MinimalHero1(content: _grocery('MinimalHero1', 'Timeless. Effortless.', 'Est. Craft', 'Discover', _groceryItems))));
  testWidgets('IconActionNav1', (t) async =>
      _shoot(t, 'IconActionNav1', IconActionNav1(content: _grocery('IconActionNav1', '', '', '', _actions))));
  testWidgets('WideProductCard1', (t) async =>
      _shoot(t, 'WideProductCard1', WideProductCard1(content: _grocery('WideProductCard1', '', 'Deal of the day', 'Add', _electronics))));
  testWidgets('CircleCategoryRail1', (t) async =>
      _shoot(t, 'CircleCategoryRail1', CircleCategoryRail1(content: _grocery('CircleCategoryRail1', 'Shop by Category', '', '', _catItems))));
  testWidgets('SpotlightDuo1', (t) async =>
      _shoot(t, 'SpotlightDuo1', SpotlightDuo1(content: _grocery('SpotlightDuo1', '', '', '', _mixedDeals))));
  testWidgets('RecentlyViewed1', (t) async =>
      _shoot(t, 'RecentlyViewed1', RecentlyViewed1(content: _grocery('RecentlyViewed1', 'Recently Viewed', 'Pick up where you left off', 'View all', _groceryItems))));
  testWidgets('LimitedStock1', (t) async =>
      _shoot(t, 'LimitedStock1', LimitedStock1(content: _grocery('LimitedStock1', 'Almost Gone', 'Grab before they sell out', '', _electronics))));
  testWidgets('GiftBanner1', (t) async =>
      _shoot(t, 'GiftBanner1', GiftBanner1(content: _grocery('GiftBanner1', 'The Perfect Gift', 'Gift cards delivered instantly', 'Gift now', _groceryItems))));
  testWidgets('LoyaltyProgress1', (t) async =>
      _shoot(t, 'LoyaltyProgress1', LoyaltyProgress1(content: _grocery('LoyaltyProgress1', 'You are 250 points from Gold', '750 / 1000 points', '', _groceryItems))));
  testWidgets('RatingSummary1', (t) async =>
      _shoot(t, 'RatingSummary1', RatingSummary1(content: _grocery('RatingSummary1', '', '', '', _groceryItems))));

  // ---- Finishing batch B (→ 100) ----
  testWidgets('VideoBanner1', (t) async =>
      _shoot(t, 'VideoBanner1', VideoBanner1(content: _grocery('VideoBanner1', 'Watch the Film', '', '', _groceryItems))));
  testWidgets('TextCta1', (t) async =>
      _shoot(t, 'TextCta1', TextCta1(content: _grocery('TextCta1', 'Join thousands who shop smarter', 'Get started today', 'Get started', _groceryItems))));
  testWidgets('CountBadgeRail1', (t) async =>
      _shoot(t, 'CountBadgeRail1', CountBadgeRail1(content: _grocery('CountBadgeRail1', 'Community Favourites', 'Loved by thousands', 'View all', _mixedDeals))));
  testWidgets('SubscribeBox1', (t) async =>
      _shoot(t, 'SubscribeBox1', SubscribeBox1(content: _grocery('SubscribeBox1', 'Subscribe & Save 15%', 'Never run out of essentials', 'Start', _groceryItems))));
  testWidgets('FaqCompact1', (t) async =>
      _shoot(t, 'FaqCompact1', FaqCompact1(content: _grocery('FaqCompact1', 'Quick Answers', 'Good to know', '', _faqs))));
  testWidgets('ContactSupport1', (t) async =>
      _shoot(t, 'ContactSupport1', ContactSupport1(content: _grocery('ContactSupport1', '', '', '', _groceryItems))));
  testWidgets('FooterCta1', (t) async =>
      _shoot(t, 'FooterCta1', FooterCta1(content: _grocery('FooterCta1', 'Shop Anytime, Anywhere', '', 'Start shopping', _groceryItems))));
  testWidgets('AnnouncementBar1', (t) async =>
      _shoot(t, 'AnnouncementBar1', AnnouncementBar1(content: _grocery('AnnouncementBar1', 'Free shipping on orders over Rs 499  •  Shop now', '', '', _groceryItems))));
  testWidgets('StickyOffer1', (t) async =>
      _shoot(t, 'StickyOffer1', StickyOffer1(content: _grocery('StickyOffer1', 'Extra 10% off — code WELCOME10', '', 'Apply', _groceryItems))));
  testWidgets('PromoMarquee1', (t) async =>
      _shoot(t, 'PromoMarquee1', PromoMarquee1(content: _grocery('PromoMarquee1', '', '', '', <LayoutDatum>[]))));

  // ---- Premium APP headers ----
  testWidgets('AppHeaderSplit1', (t) async => _shoot(t, 'AppHeaderSplit1', const AppHeaderSplit1()));
  testWidgets('AppHeaderCentered1', (t) async => _shoot(t, 'AppHeaderCentered1', const AppHeaderCentered1()));
  testWidgets('AppHeaderMinimal1', (t) async => _shoot(t, 'AppHeaderMinimal1', const AppHeaderMinimal1()));
  testWidgets('AppHeaderSearch1', (t) async => _shoot(t, 'AppHeaderSearch1', const AppHeaderSearch1()));
  testWidgets('AppHeaderTwoRow1', (t) async => _shoot(t, 'AppHeaderTwoRow1', const AppHeaderTwoRow1()));
  testWidgets('AppHeaderLocation1', (t) async => _shoot(t, 'AppHeaderLocation1', const AppHeaderLocation1()));
  testWidgets('AppHeaderPill1', (t) async => _shoot(t, 'AppHeaderPill1', const AppHeaderPill1()));
  testWidgets('AppHeaderGradient1', (t) async => _shoot(t, 'AppHeaderGradient1', const AppHeaderGradient1()));
  testWidgets('AppHeaderCategoryTabs1', (t) async => _shoot(t, 'AppHeaderCategoryTabs1', const AppHeaderCategoryTabs1()));
  testWidgets('AppHeaderLuxe1', (t) async => _shoot(t, 'AppHeaderLuxe1', const AppHeaderLuxe1()));
}
