import 'package:flutter/material.dart';

class OrderInputFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Order ID Field
            Expanded(
              child: buildInputField("Order ID", "Enter your order ID"),
            ),
            SizedBox(width: 16), // Add spacing between fields
            // Payment Method Field
            Expanded(
              child: buildInputField("Payment Method", "Enter your method"),
            ),
            SizedBox(width: 16),
            // Date Field with Calendar Icon
            Expanded(
              child: buildInputField("Date", "Enter your date", icon: Icons.calendar_today),
            ),
            SizedBox(width: 16),
            // Phone Number Field
            Expanded(
              child: buildInputField("Phone Number", "Enter your number"),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build each input field with a label
  Widget buildInputField(String label, String hintText, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
          ),
        ),
      ],
    );
  }
}
