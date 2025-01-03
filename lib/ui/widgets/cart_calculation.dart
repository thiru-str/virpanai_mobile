import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            keyText,
            style: keyStyle ?? FontUtils.circularStdStyle(fontSize: 16,color: AppColors.textColor50),
          ),
          Text(
            valueText,
            style: valueStyle ??  FontUtils.circularStdStyle(fontSize: 16,color: AppColors.textColor),
          ),
        ],
      ),
    );
  }
}
