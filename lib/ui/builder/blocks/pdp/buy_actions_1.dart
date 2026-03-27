import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';
import '../../../../utility/app_theme.dart';

/// BuyActions1 - Add to cart, wishlist, share, buy now buttons.
/// Extracted from product_detail_page.dart buildQuantitySelector()
class BuyActions1Widget extends StatelessWidget {
  final bool isVariantSelected;
  final bool stockNotAvailable;
  final bool isLoading;
  final int selectedQuantity;
  final int maxQuantity;
  final bool isFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback? onBuyNow;
  final VoidCallback? onWishlistToggle;
  final VoidCallback? onShare;
  final Function(int) onQuantityChanged;
  final BlockConfig config;

  const BuyActions1Widget({
    super.key,
    required this.isVariantSelected,
    required this.stockNotAvailable,
    required this.isLoading,
    required this.selectedQuantity,
    required this.maxQuantity,
    required this.isFavorite,
    required this.onAddToCart,
    required this.onQuantityChanged,
    required this.config,
    this.onBuyNow,
    this.onWishlistToggle,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final ctaText = config.getString('cta_text', defaultValue: 'Add to Cart');
    final showWishlist = config.getBool('show_wishlist', defaultValue: true);
    final showShare = config.getBool('show_share', defaultValue: true);
    final showBuyNow = config.getBool('show_buy_now', defaultValue: false);
    final showStock = config.getBool('show_stock_indicator', defaultValue: true);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock indicator
          if (showStock)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stockNotAvailable ? AppColors.error : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    stockNotAvailable ? 'Out of stock' : 'In stock',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: stockNotAvailable ? AppColors.error : Colors.green,
                    ),
                  ),
                ],
              ),
            ),

          // Quantity + Add to Cart row
          Row(
            children: [
              // Quantity dropdown
              Container(
                width: 80,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: AppTheme.mediumRadius,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedQuantity,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    items: List.generate(
                      maxQuantity.clamp(1, 10),
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                    onChanged: (v) {
                      if (v != null) onQuantityChanged(v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Add to Cart button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (!isVariantSelected || stockNotAvailable || isLoading)
                        ? null
                        : onAddToCart,
                    style: AppTheme.primaryButtonStyle.copyWith(
                      minimumSize: WidgetStatePropertyAll(const Size(0, 48)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            ctaText,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          // Buy Now button
          if (showBuyNow && onBuyNow != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: (!isVariantSelected || stockNotAvailable) ? null : onBuyNow,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonBorderRadius),
                ),
                child: Text(
                  'Buy Now',
                  style: FontUtils.primaryFontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],

          // Wishlist + Share row
          if (showWishlist || showShare) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (showWishlist && onWishlistToggle != null) ...[
                  IconButton(
                    onPressed: onWishlistToggle,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : AppColors.textColor50,
                    ),
                  ),
                ],
                if (showShare && onShare != null) ...[
                  IconButton(
                    onPressed: onShare,
                    icon: Icon(Icons.share_outlined, color: AppColors.textColor50),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
