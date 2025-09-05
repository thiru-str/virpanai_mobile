import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/currency_util.dart';

class OrderWidget extends StatelessWidget {
  final String orderId;
  final String itemCount;
  final DateTime createdAt;
  final num itemPrice;
  final VoidCallback onTap;

  const OrderWidget({
    Key? key,
    required this.orderId,
    required this.itemCount,
    required this.createdAt,
    required this.itemPrice,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight( // Ensures the Row matches the content height for vertical alignment
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vertically centered icon
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.receipt,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),

              // Right side content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1st row: Order ID
                    Text(
                      '${AppStrings.order} #$orderId',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 2nd row: Item count and price+arrow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$itemCount items',
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            color: Colors.grey[600]!,
                          ),
                        ),
                        Row(
                          children: [
                            Visibility(
                              visible: itemPrice>0,
                              child: Text(
                                CurrencyUtil.appendCurrency(itemPrice.toStringAsFixed(2)),
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 3rd row: Placed at
                    Text(
                      'Placed at ${DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)}',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        color: Colors.grey[600]!,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )

    );
  }

}
