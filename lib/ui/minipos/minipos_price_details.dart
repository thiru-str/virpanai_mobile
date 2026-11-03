import 'package:flutter/material.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

/// MiniPOS-only copy of the main cart's Price Details layout.
/// Backend-calculated fees are added to the product subtotal.
class MiniPosPriceDetails extends StatelessWidget {
  final int platformFeePaise;
  final String subtotal;
  final String total;
  const MiniPosPriceDetails(
      {super.key,
      required this.platformFeePaise,
      required this.subtotal,
      required this.total});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Price Details',
                style: FontUtils.primaryFontStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                    fontSize: 15)),
          ),
          _priceRow('SubTotal', subtotal),
          _priceRow('Platform Fee', miniPosMoney(platformFeePaise)),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Divider(color: Colors.grey.shade300, height: 1)),
          _priceRow('Total Amount', total, isBold: true, fontSize: 13),
          const SizedBox(height: 6),
        ]),
      );

  Widget _priceRow(String label, String value,
          {bool isBold = false, double fontSize = 14}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.secondaryFontStyle(
                          fontSize: fontSize,
                          color: AppColors.textColor.withValues(alpha: 0.65),
                          fontWeight:
                              isBold ? FontWeight.w700 : FontWeight.w400)
                      .copyWith(height: 1.5))),
          const SizedBox(width: 12),
          Flexible(
              child: Text(value,
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                      fontSize: fontSize,
                      color: AppColors.textColor,
                      fontWeight: isBold ? FontWeight.w700 : FontWeight.w600))),
        ]),
      );
}
