import 'dart:async';

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

class Item12 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const Item12({
    Key? key,
    required this.content,
    this.onCartQtyChanged,
  }) : super(key: key);

  @override
  State<Item12> createState() => _Item12State();
}

class _Item12State extends State<Item12> {
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

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
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
                  for (int i = 0; i < (content.layoutData?.length ?? 0); i++) ...[
                    _Item11Card(
                      layoutData: content.layoutData![i],
                      cartQty: variantQtyMap[
                      content.layoutData![i].variantDetails?.variantId] ??
                          content.layoutData![i].cartDetails?.quantity ??
                          0,
                      onCartQtyChanged: widget.onCartQtyChanged,
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

class _Item11Card extends StatelessWidget {
  final dynamic layoutData;
  final int cartQty;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _Item11Card({
    Key? key,
    required this.layoutData,
    required this.cartQty,
    required this.onCartQtyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prices = layoutData.prices ?? {};
    final variantId = layoutData.variantDetails?.variantId ?? '';

    return Container(
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
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${prices.discountPercentage} OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.favorite_border,
                    size: 20, color: Colors.grey),
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
                  i < (layoutData.rating ?? 0)
                      ? Icons.star
                      : Icons.star_border,
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
                child: const Text("Add To Cart"),
              ),
            ),
          ),
        ],
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
