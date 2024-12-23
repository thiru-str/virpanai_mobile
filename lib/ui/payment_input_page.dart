import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:waioz/utility/AppColors.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor,width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Total Payment",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Text(
                  "₹1500",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: buildLabeledContainer(
                label: "Given Amount",
                prefixText: "₹ ",
                text: "2000",
              ),
            ),
            Expanded(
              child: buildLabeledContainer(
                label: "Remaining Amount",
                prefixText: "₹ ",
                text: "500",
              ),
            ),
          ],),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                ),
                itemCount: 12, // Total 12 items (for 3x4 grid)
                itemBuilder: (context, index) {
                  String buttonText;
                  if (index < 9) {
                    // Numbers 1 to 9
                    buttonText = "${index + 1}";
                  } else if (index == 10) {
                    // Position for 0
                    buttonText = "0";
                  } else {
                    // Empty spaces (index 9 and 11)
                    buttonText = "";
                  }

                  // Define the border based on the position of the item
                  BorderSide borderSide = BorderSide(color: AppColors.keyPadBorder, width: 1);
                  Border cellBorder = Border(
                    top: index >= 3 ? borderSide : BorderSide.none,
                    left: (index % 3 != 0) ? borderSide : BorderSide.none,
                    right: ((index + 1) % 3 != 0) ? borderSide : BorderSide.none,
                    bottom: (index < 9) ? borderSide : BorderSide.none,
                  );

                  return Container(
                    decoration: BoxDecoration(
                      border: cellBorder,
                    ),
                    child: Center(
                      child: Text(
                        buttonText,
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLabeledContainer({
    required String label,
    required String prefixText,
    required String text,
    bool enabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: TextField(
              enabled: enabled,
              controller: TextEditingController(text: text),
              decoration: InputDecoration(
                prefixText: prefixText,
                prefixStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: AppColors.borderColor), // Customize as needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}




