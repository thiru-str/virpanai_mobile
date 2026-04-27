import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../utility/app_colors.dart';

class CartItemCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String size;
  final String color;
  final String price;
  final String error;
  final int quantity;
  final bool isUpdating;
  final Function(int newQty) onUpdateQuantity;
  final VoidCallback onRemoveAll;

  const CartItemCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.size,
    required this.color,
    required this.price,
    this.error = '',
    required this.quantity,
    this.isUpdating = false,
    required this.onUpdateQuantity,
    required this.onRemoveAll,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: AppColors.primary.withAlpha(20), width: 1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                              fadeInDuration:
                                  const Duration(milliseconds: 250),
                              placeholder: (context, url) => const AppShimmer(
                                child: ShimmerBox(
                                  width: 60,
                                  height: 80,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              errorWidget: (context, _, __) =>
                                  const ImageFallbackWidget(w: 60, h: 80),
                            )
                          : const ImageFallbackWidget(w: 60, h: 80),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          size,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final result =
                                  await _showQuantityDialog(context, quantity);
                              if (result == null || result == quantity) return;
                              if (result == 0) {
                                onRemoveAll();
                              } else {
                                onUpdateQuantity(result);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '$quantity',
                                    style: FontUtils.primaryFontStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (quantity > 0)
                            GestureDetector(
                              onTap: onRemoveAll,
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Visibility(
                visible: error.isNotEmpty,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: Text(
                    error,
                    style: FontUtils.secondaryFontStyle(color: Colors.red),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isUpdating)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Center(
              child: AppShimmer(
                child: ShimmerBox(
                  width: 120,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<int?> _showQuantityDialog(BuildContext context, int currentQty) async {
    final controller = TextEditingController(text: currentQty.toString());

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            AppStrings.enter_quantity,
            style: FontUtils.primaryFontStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(3),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: AppStrings.quantity_hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                final value =
                    int.tryParse(controller.text.trim()) ?? currentQty;
                Navigator.pop(context, value);
              },
              child: const Text(AppStrings.ok,
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
