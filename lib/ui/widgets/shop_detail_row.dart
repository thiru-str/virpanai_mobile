import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/utility/app_utils.dart';

import '../../utility/app_assets.dart';
import '../../utility/app_colors.dart';

class ShopDetailRow extends StatelessWidget {
  final String title;
  final String? value;
  final String? imageUrl;

  const ShopDetailRow({
    Key? key,
    required this.title,
    this.value,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isImage = imageUrl != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: isImage
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 60,
                  width: 60,
                  color: AppColors.secondary,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppAssets.ic_no_image,
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            )
                : Text(
              value ?? '',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
