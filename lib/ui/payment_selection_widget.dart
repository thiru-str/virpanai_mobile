import 'package:flutter/material.dart';
import 'package:waioz/utility/AppColors.dart';

class PaymentMethodSelection extends StatefulWidget {
  @override
  _PaymentMethodSelectionState createState() => _PaymentMethodSelectionState();
}

class _PaymentMethodSelectionState extends State<PaymentMethodSelection> {
  String selectedMethod = 'Cash'; // Default selected method

  // Method to handle selection
  void selectMethod(String method) {
    setState(() {
      selectedMethod = method;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor,width: 2),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Method",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildPaymentOption('Card', Icons.credit_card, selectedMethod == 'Card'),
              buildPaymentOption('Cash', Icons.money, selectedMethod == 'Cash'),
              buildPaymentOption('UPI', Icons.account_balance_wallet, selectedMethod == 'UPI'),
            ],

          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  // Widget for each payment option
  Widget buildPaymentOption(String method, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => selectMethod(method),
      child: Container(
        width: 100,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: isSelected ? 2 : 2,
          ),
          borderRadius: BorderRadius.circular(5),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.black,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              method,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
