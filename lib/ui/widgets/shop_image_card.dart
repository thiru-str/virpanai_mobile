import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utility/app_assets.dart';

class ShopImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String size;

  const ShopImageCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼 Image section
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 120,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 90,
                color: Colors.grey.shade200,
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.ic_no_image,
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 📝 Title + Size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
