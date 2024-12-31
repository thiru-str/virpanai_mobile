import 'package:flutter/material.dart';

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
            style: keyStyle ?? const TextStyle(fontSize: 14),
          ),
          Text(
            valueText,
            style: valueStyle ?? const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
