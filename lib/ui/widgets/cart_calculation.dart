import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/ui_typography.dart';

class CartCalculation extends StatelessWidget {
  final String keyText;
  final String valueText;
  final TextStyle? keyStyle;
  final TextStyle? valueStyle;

  const CartCalculation({
    Key? key,
    required this.keyText,
    required this.valueText,
    this.keyStyle,
    this.valueStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flex both sides + ellipsis so a long label ("Loyalty Points (…)")
          // and a long amount can't overflow the summary row on small screens.
          Expanded(
            child: Text(
              keyText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: keyStyle ??
                  UiTypography.cardMeta(color: AppColors.textColor50)
                      .copyWith(fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              valueText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: valueStyle ??
                  UiTypography.cardAction(color: AppColors.textColor)
                      .copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class CartPaymentMethodWidget extends StatelessWidget {
  final String paymentMethod;
  final VoidCallback? onTap;

  const CartPaymentMethodWidget({
    Key? key,
    required this.paymentMethod,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isActionable = paymentMethod == "NEFT"; // Only NEFT is actionable
    Color backgroundColor = isActionable
        ? AppColors.primary.withOpacity(0.15) // Highlighted for NEFT
        : AppColors.textColor.withOpacity(0.1); // Default for other methods

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.payemnt_method,
          style: UiTypography.cardMeta(color: AppColors.textColor50)
              .copyWith(fontSize: 15),
        ),
        const SizedBox(width: 8),
        // Flex the method chip + ellipsis so long provider names
        // ("Credit / Debit Card") don't overflow the row.
        Flexible(
          child: GestureDetector(
            onTap: isActionable ? onTap : null, // Actionable if NEFT
            child: Container(
              padding: isActionable
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                  : null,
              decoration: BoxDecoration(
                color: isActionable ? backgroundColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                paymentMethod,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: UiTypography.cardAction(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
