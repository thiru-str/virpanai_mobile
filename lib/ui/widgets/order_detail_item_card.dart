import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';


import 'package:flutter_rating_bar/flutter_rating_bar.dart';



class OrderDetailItemCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String variant;
  final String price;
  final String status;
  final double initialRating;
  final bool showReturnButton;
  final bool showRating;
  final Function(double)? onRatingChanged;
  final VoidCallback? onReturnTap;

  const OrderDetailItemCard({
    Key? key,
    required this.imageUrl,
    required this.productName,
    required this.variant,
    required this.price,
    required this.status,
    this.initialRating = 0.0,
    this.showReturnButton = true,
    this.showRating = true,
    this.onRatingChanged,
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
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade300, width: 1.2),
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
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorWidget: (context, _, __) => _fallbackWidget(),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              price,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          variant,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Divider
              if (showRating) ...[
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300, thickness: 1),
              ],

              // 🔹 Rating & Return Button Section
              if (showRating) ...[
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            RatingBar.builder(
                              initialRating: initialRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemSize: 24,
                              unratedColor: Colors.grey.shade300,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) =>  Icon(
                                  Icons.star,
                                  color: AppColors.primary),
                              onRatingUpdate: (rating) {
                                if (onRatingChanged != null) {
                                  onRatingChanged!(rating);
                                }
                              },
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            const Text(
                              "Please rate the product",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (showReturnButton)
                          ElevatedButton(
                            onPressed: onReturnTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Return Order",
                              style: TextStyle(color: Colors.white),
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
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:  [
                Icon(Icons.circle, size: 8, color: getStatusColor(status)),
                SizedBox(width: 6),
                Text(
                  status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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

      case 'packed':
        return Colors.blue;

      case 'shipped':
        return Colors.purple;

      case 'delivered':
        return Colors.green;

      case 'returned':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}
