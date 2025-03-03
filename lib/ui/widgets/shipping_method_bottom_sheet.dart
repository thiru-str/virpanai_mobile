import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/shipping_response.dart';
import 'package:waioz/utility/font_utils.dart';

class ShippingMethodBottomSheet extends StatelessWidget {
  final List<ShippingOption> shippingOptions;
  final Function(ShippingOption shippingOption) onShippingSelected;

  const ShippingMethodBottomSheet({
    Key? key,
    required this.shippingOptions,
    required this.onShippingSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Shipping Methods',
            style: FontUtils.secondaryFontStyle1(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...shippingOptions.map((option) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                child: ListTile(
                  onTap: () {
                    onShippingSelected(option);
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  title: Text(
                    option.name!,
                    style: FontUtils.primaryFontStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.radio_button_unchecked),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
