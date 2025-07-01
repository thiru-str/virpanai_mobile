import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart'; // <-- ADD THIS PACKAGE
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

class Grid1 extends StatelessWidget {
  final Content content;

  const Grid1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppUtils.rgbStringToColor(content.layoutBgColor??''),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  content.layoutTitle ?? '',
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppUtils.getAutoTextColor(AppUtils.rgbStringToColor(content.layoutBgColor??'')),
                  ),
                ),
                Visibility(
                  visible: content.layoutRedirectTitle?.isNotEmpty ?? false,
                  child: GestureDetector(
                    onTap: () {
                      // Handle redirect
                    },
                    child: Text(
                      content.layoutRedirectTitle!,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16.0),),
                child: CachedNetworkImage(
                  imageUrl: content.layoutBannerImage??'',
                  height: 150, // Adjusted image height
                  width: double.infinity, // Take full width
                  fit: BoxFit.cover, // Fill the card space
                )
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: content.layoutData!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final layoutData = content.layoutData![index];

                  return GestureDetector(
                    onTap: () {
                      RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content.layoutOption!,
                        layoutData: layoutData,
                      );
                    },
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Image + Badges
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                child: CachedNetworkImage(
                                  imageUrl: layoutData.image ?? '',
                                  height: 130,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // 🔸 Top Tag
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Text("New Launch", style: TextStyle(fontSize: 10, color: Colors.white)),
                                ),
                              ),
                              // 🔸 Yellow Playback & Rating
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade600,
                                    borderRadius: BorderRadius.circular(10), // Equal radius for all corners
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'comfort guaranteed!',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.star, size: 10, color: Colors.green),
                                            SizedBox(width: 2),
                                            Text("4.4", style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // 🔹 Product Title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              layoutData.title ?? '',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // 🔹 Dotted Line
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: DottedLine(
                              dashLength: 4,
                              dashGapLength: 3,
                              lineThickness: 1,
                              dashColor: Colors.grey,
                            ),
                          ),

                          // 🔹 Price & Variants Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  CurrencyUtil.appendCurrency(layoutData.prices?.sellingPrice ?? ''),
                                  style: FontUtils.primaryFontStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // 🔹 Original Price + % Off
                          Visibility(
                            visible: layoutData.prices?.discountPercentage?.isNotEmpty ?? false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Text(
                                    CurrencyUtil.appendCurrency(layoutData.prices?.originalPrice ?? ''),
                                    style: FontUtils.primaryFontStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${layoutData.prices?.discountPercentage ?? ''} off",
                                    style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16,),
        ],
      ),
    );
  }
}

