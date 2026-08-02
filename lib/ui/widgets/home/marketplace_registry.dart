import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import 'grocery_grid1.dart';
import 'grocery_rail_base.dart';
import 'category_chips1.dart';
import 'combo1.dart';
import 'free_delivery1.dart';
import 'vertical_switcher1.dart';
import 'restaurant_rail1.dart';
import 'cuisine_chips1.dart';
import 'pharmacy_banner1.dart';
import 'home_collection1.dart';
import 'vertical_products.dart';
import 'hero_promo1.dart';
import 'trust_email1.dart';
import 'reviews_coupons1.dart';
import 'brand_faq1.dart';
import 'composites1.dart';
import 'composites2.dart';
import 'conversion1.dart';
import 'content_media1.dart';
import 'vertical_deep1.dart';
import 'vertical_deep2.dart';
import 'media_deep1.dart';
import 'conversion_deep1.dart';
import 'hero_spotlight1.dart';
import 'hero_spotlight2.dart';
import 'extras1.dart';
import 'extras2.dart';
import 'finish_a.dart';
import 'finish_b.dart';
import 'finish_c.dart';
import 'finish_d.dart';
import 'food1.dart';
import 'supermarket1.dart';
import 'supermarket2.dart';

// Marketplace home-component registry. Maps a CMS `layout_name` to its widget
// so the production home page renders the new components (grocery, multi-
// vertical, general premium, composite, conversion/content/media batches).
//
// The 8 original home layouts (Slider10-12, Banner5-7, item15-16) stay in the
// main switch in home_page.dart; everything new is registered here.

const List<String> kMarketplaceLayouts = [
  // grocery / supermarket
  'CategoryChips1', 'GroceryGrid1', 'FreshMeats1', 'FreshProduce1',
  'GroceryDeal1', 'BuyAgain1', 'Combo1', 'FreeDelivery1',
  // multi-vertical
  'VerticalSwitcher1', 'ElectronicsGrid1', 'RestaurantRail1', 'CuisineChips1',
  'PharmacyBanner1', 'BeautyRail1', 'HomeCollection1', 'MixedDeals1',
  // general premium
  'HeroBanner1', 'SaleCountdown1', 'TrustStrip1', 'EmailCapture1',
  'Reviews1', 'CouponRow1', 'BrandWall1', 'FaqList1',
  // composite
  'SpotlightList1', 'CategoryCollection1', 'ListCard1', 'StoryRail1',
  'CollectionCover1', 'MegaSpotlight1', 'TabbedList1', 'PickForYou1',
  // conversion / content / media
  'Loyalty1', 'Referral1', 'Wishlist1', 'StockUrgency1',
  'Blog1', 'Story1', 'HowTo1', 'Reels1',
  // per-vertical depth
  'SearchHeroVertical1', 'ServiceBooking1', 'WalletCashback1', 'StorePickup1',
  'RestaurantOffers1', 'ElectronicsDeals1', 'PharmacyCategories1', 'BeautyShades1',
  // media + conversion depth
  'Instagram1', 'Ugc1', 'Gallery1', 'BeforeAfter1',
  'SizeGuide1', 'PincodeCheck1', 'AppPromo1', 'Membership1',
  // hero / spotlight / collection variants
  'SplitHero1', 'ProductSpotlight1', 'TripleCollection1', 'DualBanner1',
  'RankedGrid1', 'CategorySpotlight1', 'LookbookRail1', 'LaunchCountdown1',
  // extras
  'FeatureIcons1', 'TestimonialBig1', 'StatBand1', 'CategoryCardRail1',
  'TwoColProducts1', 'OfferDuo1', 'NewInTabs1', 'TrustBadges1',
  // finishing A
  'MinimalHero1', 'IconActionNav1', 'WideProductCard1', 'CircleCategoryRail1',
  'SpotlightDuo1', 'RecentlyViewed1', 'LimitedStock1', 'GiftBanner1',
  'LoyaltyProgress1', 'RatingSummary1',
  // finishing B
  'VideoBanner1', 'TextCta1', 'CountBadgeRail1', 'SubscribeBox1', 'FaqCompact1',
  'ContactSupport1', 'FooterCta1', 'AnnouncementBar1', 'StickyOffer1', 'PromoMarquee1',
  // food / organic (SATVA genre)
  'Certifications1', 'NutritionFacts1', 'Recipe1', 'SubscriptionBox1', 'FarmStory1',
  // supermarket / quick-commerce (FRESHKART genre) — compact cards
  'CategoryMini1', 'ProductMini1', 'DealStrip1',
  'ProductStepper1', 'CategoryCircle1', 'CategoryPills1', 'ReorderRail1',
];

// Layouts that render from copy alone (no layoutData required).
const Set<String> kMarketplaceNoDataLayouts = {
  'FreeDelivery1', 'PharmacyBanner1', 'HeroBanner1', 'SaleCountdown1',
  'EmailCapture1', 'Loyalty1', 'Referral1', 'StockUrgency1', 'Story1',
  'WalletCashback1', 'StorePickup1', 'SearchHeroVertical1',
  'BeforeAfter1', 'SizeGuide1', 'PincodeCheck1', 'AppPromo1', 'Membership1',
  'SplitHero1', 'CategorySpotlight1', 'LaunchCountdown1',
  'TestimonialBig1', 'StatBand1', 'TrustBadges1',
  'MinimalHero1', 'GiftBanner1', 'LoyaltyProgress1', 'RatingSummary1',
  'VideoBanner1', 'TextCta1', 'SubscribeBox1', 'ContactSupport1', 'FooterCta1',
  'AnnouncementBar1', 'StickyOffer1', 'PromoMarquee1',
};

Widget? marketplaceHomeWidget(Content content,
    {void Function(int delta, String variantId)? onCartQtyChanged}) {
  switch (content.layoutName) {
    case 'CategoryChips1':
      return CategoryChips1(content: content);
    case 'GroceryGrid1':
      return GroceryGrid1(content: content);
    case 'FreshMeats1':
      return FreshMeats1(content: content);
    case 'FreshProduce1':
      return FreshProduce1(content: content);
    case 'GroceryDeal1':
      return GroceryDeal1(content: content);
    case 'BuyAgain1':
      return BuyAgain1(content: content);
    case 'Combo1':
      return Combo1(content: content);
    case 'FreeDelivery1':
      return FreeDelivery1(content: content);
    case 'VerticalSwitcher1':
      return VerticalSwitcher1(content: content);
    case 'ElectronicsGrid1':
      return ElectronicsGrid1(content: content);
    case 'RestaurantRail1':
      return RestaurantRail1(content: content);
    case 'CuisineChips1':
      return CuisineChips1(content: content);
    case 'PharmacyBanner1':
      return PharmacyBanner1(content: content);
    case 'BeautyRail1':
      return BeautyRail1(content: content);
    case 'HomeCollection1':
      return HomeCollection1(content: content);
    case 'MixedDeals1':
      return MixedDeals1(content: content);
    case 'HeroBanner1':
      return HeroBanner1(content: content);
    case 'SaleCountdown1':
      return SaleCountdown1(content: content);
    case 'TrustStrip1':
      return TrustStrip1(content: content);
    case 'EmailCapture1':
      return EmailCapture1(content: content);
    case 'Reviews1':
      return Reviews1(content: content);
    case 'CouponRow1':
      return CouponRow1(content: content);
    case 'BrandWall1':
      return BrandWall1(content: content);
    case 'FaqList1':
      return FaqList1(content: content);
    case 'SpotlightList1':
      return SpotlightList1(content: content);
    case 'CategoryCollection1':
      return CategoryCollection1(content: content);
    case 'ListCard1':
      return ListCard1(content: content);
    case 'StoryRail1':
      return StoryRail1(content: content);
    case 'CollectionCover1':
      return CollectionCover1(content: content);
    case 'MegaSpotlight1':
      return MegaSpotlight1(content: content);
    case 'TabbedList1':
      return TabbedList1(content: content);
    case 'PickForYou1':
      return PickForYou1(content: content);
    case 'Loyalty1':
      return Loyalty1(content: content);
    case 'Referral1':
      return Referral1(content: content);
    case 'Wishlist1':
      return Wishlist1(content: content);
    case 'StockUrgency1':
      return StockUrgency1(content: content);
    case 'Blog1':
      return Blog1(content: content);
    case 'Story1':
      return Story1(content: content);
    case 'HowTo1':
      return HowTo1(content: content);
    case 'Reels1':
      return Reels1(content: content);
    case 'SearchHeroVertical1':
      return SearchHeroVertical1(content: content);
    case 'ServiceBooking1':
      return ServiceBooking1(content: content);
    case 'WalletCashback1':
      return WalletCashback1(content: content);
    case 'StorePickup1':
      return StorePickup1(content: content);
    case 'RestaurantOffers1':
      return RestaurantOffers1(content: content);
    case 'ElectronicsDeals1':
      return ElectronicsDeals1(content: content);
    case 'PharmacyCategories1':
      return PharmacyCategories1(content: content);
    case 'BeautyShades1':
      return BeautyShades1(content: content);
    case 'Instagram1':
      return Instagram1(content: content);
    case 'Ugc1':
      return Ugc1(content: content);
    case 'Gallery1':
      return Gallery1(content: content);
    case 'BeforeAfter1':
      return BeforeAfter1(content: content);
    case 'SizeGuide1':
      return SizeGuide1(content: content);
    case 'PincodeCheck1':
      return PincodeCheck1(content: content);
    case 'AppPromo1':
      return AppPromo1(content: content);
    case 'Membership1':
      return Membership1(content: content);
    case 'SplitHero1':
      return SplitHero1(content: content);
    case 'ProductSpotlight1':
      return ProductSpotlight1(content: content);
    case 'TripleCollection1':
      return TripleCollection1(content: content);
    case 'DualBanner1':
      return DualBanner1(content: content);
    case 'RankedGrid1':
      return RankedGrid1(content: content);
    case 'CategorySpotlight1':
      return CategorySpotlight1(content: content);
    case 'LookbookRail1':
      return LookbookRail1(content: content);
    case 'LaunchCountdown1':
      return LaunchCountdown1(content: content);
    case 'FeatureIcons1':
      return FeatureIcons1(content: content);
    case 'TestimonialBig1':
      return TestimonialBig1(content: content);
    case 'StatBand1':
      return StatBand1(content: content);
    case 'CategoryCardRail1':
      return CategoryCardRail1(content: content);
    case 'TwoColProducts1':
      return TwoColProducts1(content: content);
    case 'OfferDuo1':
      return OfferDuo1(content: content);
    case 'NewInTabs1':
      return NewInTabs1(content: content);
    case 'TrustBadges1':
      return TrustBadges1(content: content);
    case 'MinimalHero1':
      return MinimalHero1(content: content);
    case 'IconActionNav1':
      return IconActionNav1(content: content);
    case 'WideProductCard1':
      return WideProductCard1(content: content);
    case 'CircleCategoryRail1':
      return CircleCategoryRail1(content: content);
    case 'SpotlightDuo1':
      return SpotlightDuo1(content: content);
    case 'RecentlyViewed1':
      return RecentlyViewed1(content: content);
    case 'LimitedStock1':
      return LimitedStock1(content: content);
    case 'GiftBanner1':
      return GiftBanner1(content: content);
    case 'LoyaltyProgress1':
      return LoyaltyProgress1(content: content);
    case 'RatingSummary1':
      return RatingSummary1(content: content);
    case 'VideoBanner1':
      return VideoBanner1(content: content);
    case 'TextCta1':
      return TextCta1(content: content);
    case 'CountBadgeRail1':
      return CountBadgeRail1(content: content);
    case 'SubscribeBox1':
      return SubscribeBox1(content: content);
    case 'FaqCompact1':
      return FaqCompact1(content: content);
    case 'ContactSupport1':
      return ContactSupport1(content: content);
    case 'FooterCta1':
      return FooterCta1(content: content);
    case 'AnnouncementBar1':
      return AnnouncementBar1(content: content);
    case 'StickyOffer1':
      return StickyOffer1(content: content);
    case 'PromoMarquee1':
      return PromoMarquee1(content: content);
    case 'Certifications1':
      return Certifications1(content: content);
    case 'NutritionFacts1':
      return NutritionFacts1(content: content);
    case 'Recipe1':
      return Recipe1(content: content);
    case 'SubscriptionBox1':
      return SubscriptionBox1(content: content);
    case 'FarmStory1':
      return FarmStory1(content: content);
    case 'CategoryMini1':
      return CategoryMini1(content: content);
    case 'ProductMini1':
      return ProductMini1(content: content);
    case 'DealStrip1':
      return DealStrip1(content: content);
    case 'ProductStepper1':
      return ProductStepper1(content: content, onCartQtyChanged: onCartQtyChanged);
    case 'CategoryCircle1':
      return CategoryCircle1(content: content);
    case 'CategoryPills1':
      return CategoryPills1(content: content);
    case 'ReorderRail1':
      return ReorderRail1(content: content, onCartQtyChanged: onCartQtyChanged);
    default:
      return null;
  }
}
