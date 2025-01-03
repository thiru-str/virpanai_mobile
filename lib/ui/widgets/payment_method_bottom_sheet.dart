import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/font_utils.dart';

class PaymentMethodsBottomSheet extends StatelessWidget {
  final List<PaymentProvider> paymentProviders;
  final Function(PaymentProvider paymentProvider) onPaymentSelected;

  const PaymentMethodsBottomSheet({
    Key? key,
    required this.paymentProviders,
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
            'Payment Methods',
            style: FontUtils.gabaritoStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...paymentProviders.map((provider) {
            return Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(40.0),
                ),
              child: ListTile(
                onTap: () {
                  onPaymentSelected(provider);
                  Navigator.pop(context); // Close the bottom sheet
                },
                title: Text(
                  provider.name!,
                  style: FontUtils.circularStdStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.radio_button_unchecked),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
