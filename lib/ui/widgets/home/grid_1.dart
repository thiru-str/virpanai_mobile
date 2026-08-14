import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

import '../../../utility/app_assets.dart';

class Grid1 extends StatelessWidget {
  final Content content;

  const Grid1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      content.layoutTitle ?? '',
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Allow up to 2 lines for the title
                    ),
                  ),
                  const SizedBox(
                      width: 4), // Add some spacing between title and redirect
                  Visibility(
                    visible: (content.layoutRedirectTitle ?? '').isNotEmpty,
                    child: GestureDetector(
                      onTap: () {
                        // Handle section-level redirection if needed
                        RedirectUtils.handleContentRedirectViewAll(
                          context: context,
                          redirectData: content.redirectData!,
                        );
                      },
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // Prevent redirect from expanding
                        children: [
                          Text(
                            content.layoutRedirectTitle!,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Banner Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                child: CachedNetworkImage(
                  imageUrl: content.layoutBannerImage ?? '',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => _fallbackWidget(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Horizontal Scroller (no fixed height)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var layoutData in content.layoutData!) ...[
                      _Grid1Card(
                        layoutData: layoutData,
                        onTap: () {
                          RedirectUtils.handleContentRedirect(
                            context: context,
                            layoutOption: content.layoutOption!,
                            layoutData: layoutData,
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                    ]
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Widget _fallbackWidget() {
  return Container(
    height: 150,
    color: AppColors.secondary,
    alignment: Alignment.center,
    child: SvgPicture.asset(
      AppAssets.ic_no_image,
      width: 48,
      height: 48,
    ),
  );
}

class _Grid1Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Grid1Card({required this.layoutData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Image + badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: layoutData.image ?? '',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) => _fallbackWidget(),
                  ),
                ),
                Visibility(
                  visible: (layoutData.salesText ?? '').isNotEmpty,
                  child: Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        layoutData.salesText ?? '',
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Visibility(
                    visible: layoutData.featureText?.isNotEmpty == true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              layoutData.featureText ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.secondaryFontStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: false,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 10, color: Colors.green),
                                  const SizedBox(width: 2),
                                  Text(
                                    _generateRandomRating(),
                                    style: FontUtils.secondaryFontStyle(
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // 🔹 Title
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

            // 🔹 Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(
                    CurrencyUtil.appendCurrency(
                      layoutData.prices?.sellingPrice ?? '',
                    ),
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
            if (layoutData.prices?.discountPercentage?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      CurrencyUtil.appendCurrency(
                        layoutData.prices?.originalPrice ?? '',
                      ),
                      style: FontUtils.primaryFontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      layoutData.prices?.discountPercentage ?? '',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static String _generateRandomRating({int decimalPlaces = 1}) {
    final random = Random();
    final rating = 3.0 + random.nextDouble() * 2.0;
    return rating.toStringAsFixed(decimalPlaces);
  }
}
