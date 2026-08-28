import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/ui_typography.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class OrderDetailItemCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String variant;
  final String preference;
  final String price;
  final String status;
  final double initialRating;
  final bool showReturnButton;
  final bool showRating;
  final bool ratingReadOnly;
  final String ratingLabel;
  final Function(double)? onRatingChanged;
  final VoidCallback? onRatingTap;
  final VoidCallback? onReturnTap;

  const OrderDetailItemCard({
    Key? key,
    required this.imageUrl,
    required this.productName,
    required this.variant,
    this.preference = '',
    required this.price,
    required this.status,
    this.initialRating = 0.0,
    this.showReturnButton = true,
    this.showRating = true,
    this.ratingReadOnly = false,
    this.ratingLabel = "Please rate the product",
    this.onRatingChanged,
    this.onRatingTap,
    this.onReturnTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🔹 Main card container
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
              // 🔹 Top section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: AppColors.secondary,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorWidget: (context, _, __) => _fallbackWidget(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name + Price in same row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: UiTypography.cardTitle(
                                        color: Colors.black87)
                                    .copyWith(height: 1.2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                price,
                                maxLines: 2,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: UiTypography.cardPrice(
                                        color: AppColors.primary)
                                    .copyWith(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          variant,
                          style:
                              UiTypography.cardSubtitle(color: Colors.black54),
                        ),
                        if (preference.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Preference: $preference',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: UiTypography.cardMeta(
                              color: AppColors.textColor50,
                            ).copyWith(fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Divider
              if (showRating || showReturnButton) ...[
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFE5E7EC), thickness: 1),
              ],

              // 🔹 Rating & Return Button Section
              if (showRating || showReturnButton) ...[
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (showRating)
                          Column(
                            children: [
                              IgnorePointer(
                                ignoring: ratingReadOnly,
                                child: RatingBar.builder(
                                  initialRating: initialRating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  itemSize: 24,
                                  unratedColor: Colors.grey.shade300,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  itemBuilder: (context, _) => Icon(Icons.star,
                                      color: AppColors.primary),
                                  onRatingUpdate: (rating) {
                                    if (!ratingReadOnly &&
                                        onRatingChanged != null) {
                                      onRatingChanged!(rating);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: ratingReadOnly ? null : onRatingTap,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    ratingLabel,
                                    style: UiTypography.cardMeta(
                                            color: Colors.black87)
                                        .copyWith(fontSize: 12.5),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox(),
                        if (showReturnButton)
                          ElevatedButton(
                            onPressed: onReturnTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              AppStrings.return_order,
                              style:
                                  UiTypography.cardAction(color: Colors.white)
                                      .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // 🔹 Floating status chip (outside main border)
        Positioned(
          top: -8,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EC)),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: getStatusColor(status)),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UiTypography.cardMeta(color: Colors.black87)
                        .copyWith(fontSize: 13),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackWidget() {
    return Container(
      height: 70,
      width: 70,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return Colors.orange;

      case 'confirmed':
        return AppColors.primary;

      case 'waiting':
      case 'processing':
        return Colors.blueGrey;

      case 'packed':
        return Colors.blue;

      case 'shipped':
        return Colors.purple;

      case 'delivered':
        return Colors.green;

      case 'returned':
      case 'canceled':
      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}
