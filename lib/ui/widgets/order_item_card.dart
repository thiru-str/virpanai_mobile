import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../utility/app_assets.dart';

class OrderItemCard extends StatelessWidget {
  final String imageUrl;
  final String storeName;
  final String storeAddress;
  final String productCount;
  final String totalPrice;
  final String? statusText; // Nullable status
  final Color? statusColor; // Optional custom color
  final String? paymentMode; // Optional custom color

  const OrderItemCard({
    Key? key,
    required this.imageUrl,
    required this.storeName,
    required this.storeAddress,
    required this.productCount,
    required this.totalPrice,
    this.statusText,
    this.statusColor,
    this.paymentMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey.shade200),
                  errorWidget: (_, __, ___) => _fallbackWidget(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      storeAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),

          const SizedBox(height: 12),

          // Product + Price + Status Row
          // Product + Price + Status Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(
                          'No of Product',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 4),
                        Text(
                          productCount??'', // replace dynamically
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Vertical Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),

                  const SizedBox(width: 12),

                  // Right: Price + (optional) Status
                  Expanded(
                    child: Row(
                      mainAxisAlignment: statusText != null && statusText!.isNotEmpty
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: statusText != null && statusText!.isNotEmpty
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Price',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalPrice,
                              style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (statusText != null && statusText!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (statusColor ?? Colors.green).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor ?? Colors.green),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  statusText!,
                                  style: TextStyle(
                                    color: statusColor ?? Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                ],
              ),
              Visibility(
                visible: paymentMode!=null,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Text('Payment Mode: $paymentMode')
                  ],
                ),
              ),

            ],
          ),

        ],
      ),
    );

  }

  Widget _fallbackWidget() {
    return Container(
      height: 48,
      width: 48,
      color: AppColors.secondary,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.ic_no_image,
        width: 24,
        height: 24,
      ),
    );
  }
}
