import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/ui_typography.dart';

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFE5E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      width: 60,
                      height: 80,
                      color: AppColors.secondary,
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
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              errorWidget: (context, _, __) =>
                                  const ImageFallbackWidget(w: 60, h: 80),
                            )
                          : const ImageFallbackWidget(w: 60, h: 80),
                    ),
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
                          style: UiTypography.cardTitle(color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          size,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: UiTypography.cardSubtitle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price and Quantity Adjustment
                  Flexible(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 96, maxWidth: 132),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price,
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: UiTypography.cardPrice(color: AppColors.primary)
                                .copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EC)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: onDecrease,
                                    child: Icon(
                                      Icons.remove_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '$quantity',
                                    style: UiTypography.cardAction(
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: onIncrease,
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Visibility(
                            visible: quantity > 1,
                            child: GestureDetector(
                              onTap: onRemoveAll,
                              child: Text(
                                "Remove All",
                                textAlign: TextAlign.right,
                                style: UiTypography.cardMeta(
                                        color: const Color(0xFFE5484D))
                                    .copyWith(
                                  fontWeight: FontWeight.w600,
                                  decorationColor: const Color(0xFFE5484D),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    style: UiTypography.cardMeta(color: const Color(0xFFE5484D)),
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
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(16.0),
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
