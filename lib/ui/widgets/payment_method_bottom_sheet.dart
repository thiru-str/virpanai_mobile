import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/app_colors.dart';

class PaymentMethodsBottomSheet extends StatelessWidget {
  final List<PaymentProvider> paymentProviders;
  final String? providerId;
  final Function(PaymentProvider paymentProvider) onPaymentSelected;

  const PaymentMethodsBottomSheet({
    Key? key,
    required this.paymentProviders,
    required this.providerId,
    required this.onPaymentSelected,
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
            AppStrings.payemnt_method,
            style: FontUtils.secondaryFontStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...paymentProviders.map((provider) {
            final isSelected = providerId == provider.id;
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
                    onPaymentSelected(provider);
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  title: Text(
                    provider.name!,
                    style: FontUtils.primaryFontStyle(fontSize: 16),
                  ),
                  trailing: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
