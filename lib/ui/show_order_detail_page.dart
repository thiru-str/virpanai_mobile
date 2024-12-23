import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


// Custom Widget for each item in the items list
import 'package:flutter/material.dart';

import '../utility/AppColors.dart';


// Custom Widget for each item in the items list
class OrderItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Wrap the image in a Flexible widget to prevent overflow
          Flexible(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: 'https://storage.googleapis.com/test-storees-bucket-storeesmvp/ice_cream.png', // Replace with actual image URL
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 8),
          // Expanded widget for the text to take up remaining space
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Oothappam",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("1 × 500"),
              ],
            ),
          ),
          // Price aligned to the end of the Row
          Text(
            "₹ 500",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Custom Widget for Detail Sections
class DetailCard extends StatelessWidget {
  final String title;
  final Widget content;

  const DetailCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.divider, // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          if (title.isNotEmpty) SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}

