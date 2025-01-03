import 'package:flutter/material.dart';
import 'package:waioz/utility/font_utils.dart';

class OrderDetailItemCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String size;
  final String color;
  final String price;

  const OrderDetailItemCard({
    Key? key,
    required this.imageUrl,
    required this.productName,
    required this.size,
    required this.color,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content in Column
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12.0),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  productName,
                  style: FontUtils.circularStdStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Product Size and Color
                Row(
                  children: [
                    Text(
                      'Size - $size',
                      style: FontUtils.circularStdStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    // const SizedBox(width: 16),
                    // Text(
                    //   'Color - $color',
                    //   style: FontUtils.circularStdStyle(
                    //     fontSize: 14,
                    //     color: Colors.black87,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          // Product Price
          Text(
            '$price',
            style: FontUtils.circularStdStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
