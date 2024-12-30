import 'dart:math';

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
    final Color baseColor =generateRandomColor();
    final Color backgroundColor = generateBackgroundColor(baseColor, 0.2);
    return SizedBox(
      height: 180,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: baseColor, width: 0.96),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imagePath.isNotEmpty?
              Image.network(
                imagePath,
                height: 80,
                fit: BoxFit.contain,
              ): const SizedBox(),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: FontUtils.circularStdStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
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
