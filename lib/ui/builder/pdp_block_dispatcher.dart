import 'package:flutter/material.dart';
import '../../model/block_config.dart';
import 'block_dispatcher.dart';
import 'blocks/pdp/image_gallery_1.dart';
import 'blocks/pdp/product_info_1.dart';
import 'blocks/pdp/variant_selector_1.dart';
import 'blocks/pdp/buy_actions_1.dart';
import 'blocks/pdp/description_1.dart';
import 'blocks/pdp/reviews_1.dart';
import 'blocks/pdp/related_products_1.dart';

/// Dispatches PDP blocks to their component widgets based on block.component slug.
/// When VirpanAI builds new variants (e.g., ImageGallery2), add a new case here.
class PdpBlockDispatcher extends BlockDispatcher {
  // Product data — set by the PDP page after fetching
  List<String> images = [];
  String title = '';
  String? subtitle;
  String? currentPrice;
  String? originalPrice;
  double? rating;
  int? reviewCount;
  String? brand;
  List<Map<String, dynamic>> options = [];
  Map<String, String?> selectedOptions = {};
  bool isVariantSelected = false;
  bool stockNotAvailable = false;
  bool isLoading = false;
  int selectedQuantity = 1;
  int maxQuantity = 10;
  bool isFavorite = false;
  String? description;
  String? additionalDescription;
  List<Map<String, dynamic>> reviews = [];
  double? averageRating;
  int? totalReviews;
  List<dynamic> relatedProducts = [];

  // Callbacks
  Function(int)? onImageTap;
  Function(String, String)? onOptionSelected;
  VoidCallback? onAddToCart;
  VoidCallback? onBuyNow;
  VoidCallback? onWishlistToggle;
  VoidCallback? onShare;
  Function(int)? onQuantityChanged;
  Function(String)? onRelatedProductTap;

  @override
  Widget buildBlock(BlockConfig block) {
    switch (block.component) {
      case 'ImageGallery1':
        return ImageGallery1Widget(
          images: images,
          config: block,
          onImageTap: onImageTap,
        );

      case 'ProductInfo1':
        return ProductInfo1Widget(
          title: title,
          subtitle: subtitle,
          currentPrice: currentPrice,
          originalPrice: originalPrice,
          rating: rating,
          reviewCount: reviewCount,
          brand: brand,
          config: block,
        );

      case 'VariantSelector1':
        return VariantSelector1Widget(
          options: options,
          selectedOptions: selectedOptions,
          onOptionSelected: onOptionSelected ?? (_, __) {},
          config: block,
        );

      case 'BuyActions1':
        return BuyActions1Widget(
          isVariantSelected: isVariantSelected,
          stockNotAvailable: stockNotAvailable,
          isLoading: isLoading,
          selectedQuantity: selectedQuantity,
          maxQuantity: maxQuantity,
          isFavorite: isFavorite,
          onAddToCart: onAddToCart ?? () {},
          onBuyNow: onBuyNow,
          onWishlistToggle: onWishlistToggle,
          onShare: onShare,
          onQuantityChanged: onQuantityChanged ?? (_) {},
          config: block,
        );

      case 'Description1':
        return Description1Widget(
          description: description,
          additionalDescription: additionalDescription,
          config: block,
        );

      case 'Reviews1':
        return Reviews1Widget(
          reviews: reviews,
          averageRating: averageRating,
          totalReviews: totalReviews,
          config: block,
        );

      case 'RelatedProducts1':
        return RelatedProducts1Widget(
          products: relatedProducts,
          onProductTap: onRelatedProductTap,
          config: block,
        );

      // Future variants added here:
      // case 'ImageGallery2':
      //   return ImageGallery2Widget(...);
      // case 'VariantSelector2':
      //   return VariantSelector2Widget(...);

      default:
        // Unknown component — skip gracefully
        return const SizedBox.shrink();
    }
  }
}
