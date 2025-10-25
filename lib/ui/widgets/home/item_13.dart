import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/redirect_utils.dart';

class Item13 extends StatelessWidget {
  final Content content;

  const Item13({
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
          // 🔹 Header (Title + View All)
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

          const SizedBox(height: 16),

          // 🔹 Horizontal scroll list (auto height)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < (content.layoutData?.length ?? 0); i++) ...[
                    _Item13Card(
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

class _Item13Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Item13Card({
    Key? key,
    required this.layoutData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prices = layoutData.prices;
    final selling = double.tryParse(prices?.sellingPrice ?? "0") ?? 0;
    final original = double.tryParse(prices?.originalPrice ?? "0") ?? 0;
    final hasDiscount = original > selling && selling > 0;
    final percentOff =
    hasDiscount ? (((original - selling) / original) * 100).round() : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Image + “NEW” cut tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Container(
                    height: 140,
                    color: Colors.grey[100],
                    child: CachedNetworkImage(
                      imageUrl: layoutData.image ?? '',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorWidget: (c, u, e) =>
                      const ImageFallbackWidget(w: 80, h: 80),
                    ),
                  ),
                ),
                // “NEW” diagonal tag
                Positioned(
                  top: 0,
                  left: 0,
                  child: ClipPath(
                    clipper: _DiagonalClipper(),
                    child: Container(
                      width: 50,
                      height: 24,
                      color: Colors.green,
                      alignment: Alignment.center,
                      child: const Text(
                        "NEW",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // 🔹 Rating badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.brown[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star, size: 14, color: Colors.brown),
                    SizedBox(width: 4),
                    Text(
                      "5 (2)",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // 🔹 Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                layoutData.title ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // 🔹 Price row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    CurrencyUtil.appendCurrency(selling.toStringAsFixed(0)),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (hasDiscount)
                    Text(
                      CurrencyUtil.appendCurrency(original.toStringAsFixed(0)),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),

            if (percentOff != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: Text(
                  "$percentOff% OFF",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),

            // 🔹 Add to cart button
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.shopping_cart_outlined,
                    size: 16, color: Colors.brown),
                label: const Text(
                  "ADD TO CART",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.brown,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[50],
                  foregroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔸 Custom diagonal “NEW” tag clipper
class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 10, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}




