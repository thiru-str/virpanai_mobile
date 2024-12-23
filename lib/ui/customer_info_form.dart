import 'package:flutter/material.dart';
import 'package:waioz/utility/AppColors.dart';

class CustomerInfoForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor,width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Info",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Name Field
            buildLabel("Name"),
            buildTextField("Enter your name"),

            // Phone Number Field
            buildLabel("Phone Number"),
            Row(
              children: [
                SizedBox(
                  height: 56, // Set height to match the TextField height
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      border: Border( top: BorderSide(color: AppColors.borderColor),
                        bottom: BorderSide(color: AppColors.borderColor),
                        left: BorderSide(color: AppColors.borderColor),
                        right: BorderSide.none, ),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5)),
                    ),
                    child: const SizedBox(
                      child: Row(
                        children: [
                          Text('+91'),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter your phone',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                          borderSide: BorderSide(color: AppColors.inputFieldBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                          borderSide: BorderSide(color: AppColors.inputFieldBorderColor),
                        ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5)),
                        borderSide: BorderSide(color: AppColors.inputFieldBorderColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Email Field
            buildLabel("Email"),
            buildTextField("Enter your email"),

            // Reward Points Field
            buildLabel("Reward Point"),
            buildTextField("200 points"),

          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildTextField(String hintText, {bool enabled = true}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.inputFieldBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.inputFieldBorderColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.inputFieldBorderColor),
        ),
      ),
    );
  }
}
