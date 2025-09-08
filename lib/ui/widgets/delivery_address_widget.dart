import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../utility/font_utils.dart';

class DeliveryAddressWidget extends StatelessWidget {
  final String? address; // null means no address
  final String? label;   // e.g. "Home", "Office"
  final VoidCallback onAddAddress;
  final VoidCallback onChangeAddress;
  final bool isLoading;

  const DeliveryAddressWidget({
    super.key,
    this.address,
    this.label,
    required this.onAddAddress,
    required this.onChangeAddress,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (address == null || address!.isEmpty) {
      // No address found
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No Delivery Address Found",
              style: FontUtils.primaryFontStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : onAddAddress, // disable when loading
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    "Add Address",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    // Address available
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: FontUtils.primaryFontStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    children: [
                      const TextSpan(text: "Delivery Address "),
                      if (label != null) TextSpan(text: "($label)"),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  address!,
                  style: FontUtils.primaryFontStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          isLoading
              ? ElevatedButton(
            onPressed: null, // disable tap while loading
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
              : ElevatedButton(
            onPressed: onChangeAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              "Change",
              style: TextStyle(color: Colors.white),
            ),
          )

        ],
      ),
    );
  }
}
