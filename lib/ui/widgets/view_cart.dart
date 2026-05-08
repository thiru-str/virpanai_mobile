import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

class ViewCartWidget extends StatelessWidget {
  final int totalItems;
  final List<String>? itemImages;

  const ViewCartWidget({
    Key? key,
    required this.totalItems,
    required this.itemImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasExtraItems = (itemImages?.length ?? 0) > 2;
    final int extraItemsCount = (itemImages?.length ?? 0) - 2;

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Adjust width to content
        children: [
          // Images Row with Overlapping Effect
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: SizedBox(
              width: hasExtraItems
                  ? 100
                  : (itemImages?.length == 1
                      ? 40
                      : 70), // Dynamically adjust width
              child: Stack(
                clipBehavior: Clip.none, // Allow overflowing content
                children: [
                  for (int i = 0; i < (itemImages?.length ?? 0) && i < 2; i++)
                    Positioned(
                      left: i * 30.0, // Position the images with spacing

                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: itemImages![i],
                          width: 36, // 2 * radius of inner CircleAvatar
                          height: 36,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const ImageFallbackWidget(
                            w: 36,
                            h: 36,
                          ),
                        ),
                      ),
                    ),
                  if (hasExtraItems)
                    Positioned(
                      left: 60.0, // Position for the "+X" CircleAvatar
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '+$extraItemsCount',
                            style: FontUtils.primaryFontStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10), // Space between images and text
          // View cart text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.view_cart,
                style: FontUtils.primaryFontStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$totalItems ${totalItems == 1 ? "Item" : "Items"}',
                style: FontUtils.primaryFontStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Action button
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
