import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/font_utils.dart';

class CategoryCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white, // Set the background to white
          borderRadius: BorderRadius.circular(16.0), // Adjusted for rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Light shadow
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: imagePath.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: imagePath,
                height: 140, // Adjusted image height
                width: double.infinity, // Take full width
                fit: BoxFit.cover, // Fill the card space
              )
                  : Container(
                height: 140,
                width: double.infinity,
                color: Colors.grey[200], // Placeholder background
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: FontUtils.primaryFontStyle(
                  fontSize: 16, // Adjusted for better readability
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Generates a color with the given base color and opacity.
  Color generateBackgroundColor(Color baseColor, double opacity) {
    return baseColor.withOpacity(opacity);
  }

  /// Generates a random color.
  Color generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255, // Full alpha (no transparency)
      random.nextInt(256), // Red value
      random.nextInt(256), // Green value
      random.nextInt(256), // Blue value
    );
}
}
