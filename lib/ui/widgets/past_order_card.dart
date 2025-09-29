import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utility/app_assets.dart';
import '../../utility/app_colors.dart';

class PastOrderCard extends StatelessWidget {
  final String dateLabel;
  final int productCount;
  final String totalPrice;
  final List<String> imageUrls;
  final VoidCallback? onTap;

  const PastOrderCard({
    Key? key,
    required this.dateLabel,
    required this.productCount,
    required this.totalPrice,
    required this.imageUrls,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatars = imageUrls.take(2).toList();
    final int extraCount = imageUrls.length > 2 ? imageUrls.length - 2 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
                // Product + Price row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No of Orders',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                           productCount>1?'$productCount Orders':'$productCount Order',
                            style:  TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalPrice,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 12),

                // Bottom row: See Details + Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'See Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      width: (avatars.length + (extraCount > 0 ? 1 : 0)) * 28.0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (int i = 0; i < avatars.length; i++)
                            Positioned(
                              left: i * 28.0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.green.shade800,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: avatars[i],
                                      fit: BoxFit.cover,
                                      width: 32,
                                      height: 32,
                                      errorWidget: (context, url, error) => Container(
                                        color: AppColors.secondary,
                                        alignment: Alignment.center,
                                        child: SvgPicture.asset(
                                          AppAssets.ic_no_image,
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                ,
                              ),
                            ),
                          if (extraCount > 0)
                            Positioned(
                              left: avatars.length * 28.0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                Colors.green.withOpacity(0.15),
                                child: Text(
                                  '+$extraCount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

