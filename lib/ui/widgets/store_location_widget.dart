import 'package:flutter/material.dart';

class StoreLocationCard extends StatelessWidget {
  final String title;
  final Widget? icon;
  final Widget mapWidget; // Pass GoogleMap, Image.network, or any map widget

  const StoreLocationCard({
    Key? key,
    this.title = 'Store Location',
    this.icon,
    required this.mapWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Icon Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (icon != null) icon!,
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Map container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade200,
              child: mapWidget,
            ),
          ),
        ),
      ],
    );
  }
}
