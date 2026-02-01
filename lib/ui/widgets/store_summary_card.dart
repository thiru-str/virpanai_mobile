import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';
import '../../utility/app_utils.dart';

class StoreSummaryCard extends StatelessWidget {
  final String storeName;
  final String address;
  final String totalPrice;
  final String? orderDate;
  final String? orderId;
  final String? phone;

  const StoreSummaryCard({
    Key? key,
    required this.storeName,
    required this.address,
    required this.totalPrice,
    required this.phone,
    this.orderDate = 'Jan 20, 2023',
    this.orderId = '#12345',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔹 DATE + BOOKING ID ROW
          if (orderDate != null || orderId != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (orderDate != null)
                  Text(
                    orderDate!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (orderId != null)
                  Text(
                    orderId!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

          if (orderDate != null || orderId != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),
          ],

          // 🔹 EXISTING CONTENT (UNCHANGED)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Store Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),const SizedBox(height: 4),
                    GestureDetector(
                      onTap: (){
                        AppUtils.makePhoneCall(phone!);
                      },
                      child: Text(
                        '+91 ${phone!}',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              // Price Tag
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E8B57), Color(0xFF006D77)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
