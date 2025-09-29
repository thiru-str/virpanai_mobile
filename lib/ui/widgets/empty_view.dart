import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyView extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;
  final double imageHeight;
  final double spacing;

  const EmptyView({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
    this.imageHeight = 180,
    this.spacing = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              imageAsset,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
            SizedBox(height: spacing),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
