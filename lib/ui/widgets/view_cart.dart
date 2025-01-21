import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';


class ViewCartWidget extends StatelessWidget {
  final int totalItems;
  final List<String> itemImages;

  const ViewCartWidget({
    Key? key,
    required this.totalItems,
    required this.itemImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasExtraItems = itemImages.length > 2;
    final int extraItemsCount = itemImages.length - 2;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Adjust width to content
        children: [
          // Images Row with Overlapping Effect
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: hasExtraItems
                  ? 100
                  : (itemImages.length == 1 ? 40 : 70), // Dynamically adjust width
              child: Stack(
                clipBehavior: Clip.none, // Allow overflowing content
                children: [
                  for (int i = 0; i < itemImages.length && i < 2; i++)
                    Positioned(
                      left: i * 30.0, // Position the images with spacing
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(itemImages[i]),
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
                            style: const TextStyle(
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
              const Text(
                'View Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$totalItems ${totalItems == 1 ? "Item" : "Items"}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10), // Space between text and button
          // Action button
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }




}




