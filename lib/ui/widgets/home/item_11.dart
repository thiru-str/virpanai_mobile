import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/redirect_utils.dart';


class Item11 extends StatelessWidget {
  final Content content;

  const Item11({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasViewAll = (content.layoutRedirectTitle ?? '').trim().isNotEmpty;

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header: Title + View All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    content.layoutTitle ?? '',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 4),
                if (hasViewAll)
                  GestureDetector(
                    onTap: () {
                      RedirectUtils.handleContentRedirectViewAll(
                        context: context,
                        redirectData: content.redirectData!,
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          content.layoutRedirectTitle!,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 🔹 Horizontal list (adaptive height)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < (content.layoutData?.length ?? 0); i++) ...[
                    _Item11Card(
                      layoutData: content.layoutData![i],
                      onTap: () {
                        RedirectUtils.handleContentRedirect(
                          context: context,
                          layoutOption: content.layoutOption!,
                          layoutData: content.layoutData![i],
                        );
                      },
                    ),
                    if (i != content.layoutData!.length - 1)
                      const SizedBox(width: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item11Card extends StatefulWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Item11Card({
    Key? key,
    required this.layoutData,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_Item11Card> createState() => _Item11CardState();
}

class _Item11CardState extends State<_Item11Card> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.layoutData;
    final prices = data.prices;
    final selling = double.tryParse(prices?.sellingPrice ?? "0") ?? 0;
    final original = double.tryParse(prices?.originalPrice ?? "0") ?? 0;
    final hasDiscount = original > selling && selling > 0;
    final percentOff =
    hasDiscount ? (((original - selling) / original) * 100).round() : null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Image Carousel + Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 150,
                    child: CachedNetworkImage(
                      imageUrl: data.image??'',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (c, u, e) =>
                      const ImageFallbackWidget(h: 150, w: double.infinity),
                    )
                  ),
                ),

                // 🔹 Discount badge
                if (percentOff != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: const ShapeDecoration(
                        color: Colors.indigo,
                        shape: StarBorder.polygon(
                          sides: 10,
                          pointRounding: 0.1,
                        ),
                      ),
                      child: Text(
                        "$percentOff%\nOFF",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // 🔹 Favorite icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {}, // handle fav later
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.favorite_border,
                          size: 18, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // 🔹 Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                data.title ?? "Untitled",
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 🔹 Description
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Text(
                data.subTitle ?? '',
                style: FontUtils.secondaryFontStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 🔹 Price Row
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                children: [
                  Text(
                    CurrencyUtil.appendCurrency(selling.toStringAsFixed(0)),
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (hasDiscount)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        CurrencyUtil.appendCurrency(original.toStringAsFixed(0)),
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 🔹 Add to Cart button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onTap,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: Text(
                    "Add To Cart",
                    style: FontUtils.primaryFontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



