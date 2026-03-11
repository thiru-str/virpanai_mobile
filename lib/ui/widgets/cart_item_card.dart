import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../utility/app_colors.dart';

class CartItemCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String size;
  final String color;
  final String price;
  final String error;
  final int quantity;
  final bool isUpdating; // New field
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemoveAll;

  const CartItemCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.size,
    required this.color,
    required this.price,
    this.error = '',
    required this.quantity,
    this.isUpdating = false,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemoveAll,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Card Content
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 60,
                            height: 80,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 250),
                            placeholder: (context, url) => const AppShimmer(
                              child: ShimmerBox(
                                width: 60,
                                height: 80,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            errorWidget: (context, _, __) =>
                                const ImageFallbackWidget(w: 60, h: 80),
                          )
                        : const ImageFallbackWidget(w: 60, h: 80),
                  ),
                  const SizedBox(width: 12.0),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          size,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price and Quantity Adjustment
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onDecrease,
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$quantity',
                            style: FontUtils.primaryFontStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onIncrease,
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Visibility(
                        visible: quantity > 1,
                        child: GestureDetector(
                          onTap: onRemoveAll,
                          child: const Text(
                            "Remove All",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              decorationColor: Colors.red,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Visibility(
                visible: error.isNotEmpty,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: Text(
                    error,
                    style: FontUtils.secondaryFontStyle(color: Colors.red),
                    maxLines: 2,
                  ),
                ),
              )
            ],
          ),
        ),
        // Loading Indicator
        if (isUpdating)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Center(
              child: AppShimmer(
                child: ShimmerBox(
                  width: 120,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
