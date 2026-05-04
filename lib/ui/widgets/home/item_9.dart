import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../model/view_cart_model.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Item9 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const Item9({
    Key? key,
    required this.content,
    this.onCartQtyChanged,
  }) : super(key: key);

  @override
  State<Item9> createState() => _Item9State();
}

class _Item9State extends State<Item9> {
  late Map<String, int> variantQtyMap;
  late StreamSubscription<ViewCartModel> _cartSubscription;

  @override
  void initState() {
    super.initState();
    variantQtyMap = {};

    _cartSubscription = eventBus.on<ViewCartModel>().listen((event) {
      setState(() {
        variantQtyMap = event.variantQtyMap;
      });
    });
  }

  @override
  void dispose() {
    _cartSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
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
            // 🔹 Title + See All
            Row(
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
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 4),
                Visibility(
                  visible: (content.layoutRedirectTitle ?? '').isNotEmpty,
                  child: GestureDetector(
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

            const SizedBox(height: 16),

            // 🔹 Scrollable horizontal list (adaptive height)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0;
                      i < (content.layoutData?.length ?? 0);
                      i++) ...[
                    _Item9Card(
                      layoutData: content.layoutData![i],
                      cartQty: variantQtyMap[content
                              .layoutData![i].variantDetails?.variantId] ??
                          content.layoutData![i].cartDetails?.quantity ??
                          0,
                      onCartQtyChanged: widget.onCartQtyChanged,
                      onTap: () {
                        // Navigate to product detail when the card body is
                        // tapped — matches the pattern used by Item11/Item12.
                        RedirectUtils.handleContentRedirect(
                          context: context,
                          layoutOption: content.layoutOption ?? '',
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
          ],
        ),
      ),
    );
  }
}

class _Item9Card extends StatelessWidget {
  final dynamic layoutData;
  final int cartQty;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  final VoidCallback? onTap;

  const _Item9Card({
    Key? key,
    required this.layoutData,
    required this.cartQty,
    required this.onCartQtyChanged,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prices = layoutData.prices ?? {};
    final variantId = layoutData.variantDetails?.variantId ?? '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Image & Discount
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: layoutData.image ?? '',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => ImageFallbackWidget(
                    h: 150,
                    w: double.infinity,
                  ),
                ),
              ),
              if (prices.discountPercentage != null &&
                  prices.discountPercentage!.isNotEmpty)
                Positioned(
                  top: 6,
                  left: 6,
                  child: _DiscountBurstBadge(
                    discountText: prices.discountPercentage!,
                  ),
                ),
              Positioned(
                top: 6,
                right: 6,
                child:
                    Icon(Icons.favorite_border, size: 20, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 🔹 Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              layoutData.title ?? "Untitled",
              style: FontUtils.primaryFontStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 🔹 Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              CurrencyUtil.appendCurrency(prices.sellingPrice ?? "0"),
              style: FontUtils.primaryFontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
          ),

          // 🔹 Rating
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < (layoutData.rating ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
          ),

          // 🔹 Add to Cart / Quantity
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: cartQty > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _qtyButton(Icons.remove, () {
                        if (cartQty > 0) {
                          onCartQtyChanged?.call(-1, variantId);
                        }
                      }),
                      Text(
                        '$cartQty',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _qtyButton(Icons.add, () {
                        onCartQtyChanged?.call(1, variantId);
                      }),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        onCartQtyChanged?.call(1, variantId);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(AppStrings.add_to_cart),
                    ),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        color: Colors.white,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}

class _DiscountBurstBadge extends StatelessWidget {
  final String discountText;

  const _DiscountBurstBadge({
    required this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = discountText.contains('%')
        ? discountText.trim()
        : '${discountText.trim()}%';

    return ClipPath(
      clipper: _BurstClipper(),
      child: Container(
        width: 34,
        height: 34,
        color: Colors.blueGrey.shade800,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(2),
        child: Text(
          '$normalized',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            height: 1.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BurstClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * 0.88;
    const points = 18;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final radius = isOuter ? outerRadius : innerRadius;
      final angle = (math.pi / points) * i - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
