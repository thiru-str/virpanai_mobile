import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../utility/currency_util.dart';
import '../../utility/font_utils.dart';

class AddOnProductCard extends StatelessWidget {
  final Product? product;
  final VoidCallback onToggle;

  const AddOnProductCard(
      {super.key, required this.product, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (product?.isSelected ?? false)
              ? AppColors.primary // Selected border color
              : Colors.grey.shade300, // Default border color
          width: 1.5,
        ),
      ),
      elevation: 0, // Remove shadow for a cleaner outline look
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: product?.images?.firstOrNull?.url ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => ImageFallbackWidget(
              w: 50,
              h: 50,
            ),
          ),
        ),
        title: Text(
          product?.title ?? '',
          style: FontUtils.primaryFontStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          getDisplayedPrice(),
          style: FontUtils.secondaryFontStyle(
            fontSize: 14,
          ),
        ),
        trailing: Checkbox(
          value: product?.isSelected ?? false,
          onChanged: (_) => onToggle(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  String getDisplayedPrice() {
    // fallback: show lowest variant price if product is loaded
    if (product?.variants?.isNotEmpty ?? false) {
      final prices = product?.variants
              ?.map((v) => v.calculatedPrice?.rawCalculatedAmount?.value)
              .where((value) => value != null)
              .map((value) => double.tryParse(value ?? ""))
              .whereType<double>()
              .toList() ??
          [];

      if (prices.isNotEmpty) {
        final lowest = prices.reduce((a, b) => a < b ? a : b);
        return "From ${CurrencyUtil.appendCurrency(lowest.toStringAsFixed(0))}";
      }
    }

    return '';
  }
}
