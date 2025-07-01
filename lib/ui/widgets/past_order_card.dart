import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PastOrderCard extends StatelessWidget {
  final String dateLabel;
  final int productCount;
  final String totalPrice;
  final List<String> imageUrls;
  final int extraCount;
  final VoidCallback? onTap;

  const PastOrderCard({
    Key? key,
    required this.dateLabel,
    required this.productCount,
    required this.totalPrice,
    required this.imageUrls,
    this.extraCount = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatars = imageUrls.take(3).toList();

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
                            'No of Product',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$productCount Product',
                            style: const TextStyle(
                              color: Colors.teal,
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
                              fontSize: 13, fontWeight: FontWeight.w500),
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
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
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
                                  backgroundImage: CachedNetworkImageProvider(avatars[i]),
                                ),
                              ),
                            ),
                          if (extraCount > 0)
                            Positioned(
                              left: avatars.length * 28.0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.green.withOpacity(0.15),
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
