import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';


class ViewCartWidget extends StatelessWidget {
  final int totalItems;
  final List<String>? itemImages; // allow null list

  const ViewCartWidget({
    Key? key,
    required this.totalItems,
    this.itemImages, // now nullable
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = itemImages ?? []; // safely handle null
    final bool hasExtraItems = images.length > 2;
    final int extraItemsCount = images.length - 2;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: hasExtraItems
                  ? 100
                  : (images.length == 1 ? 40 : (images.isEmpty ? 40 : 70)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (int i = 0; i < images.length && i < 2; i++)
                    Positioned(
                      left: i * 30.0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.secondary,
                          backgroundImage: (images[i].isNotEmpty)
                              ? NetworkImage(images[i])
                              : null,
                          child: images[i].isEmpty
                              ? Icon(Icons.image_not_supported,
                              color: Colors.white, size: 18)
                              : null,
                        ),
                      ),
                    ),
                  if (images.isEmpty)
                  // show one fallback avatar if no images at all
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.shopping_bag,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  if (hasExtraItems)
                    Positioned(
                      left: 60.0,
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
          const SizedBox(width: 10),
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
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
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
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}





