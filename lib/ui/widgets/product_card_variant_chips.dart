import 'package:flutter/material.dart';

import '../../model/product_response.dart';

const Map<String, Color> kCardColorSwatchMap = {
  'red': Color(0xFFEF4444),
  'blue': Color(0xFF3B82F6),
  'green': Color(0xFF22C55E),
  'white': Color(0xFFFFFFFF),
  'black': Color(0xFF111827),
  'yellow': Color(0xFFEAB308),
  'orange': Color(0xFFF97316),
  'pink': Color(0xFFEC4899),
  'purple': Color(0xFFA855F7),
  'grey': Color(0xFF9CA3AF),
  'gray': Color(0xFF9CA3AF),
  'brown': Color(0xFF92400E),
  'navy': Color(0xFF1E3A8A),
  'beige': Color(0xFFF5F5DC),
  'cream': Color(0xFFFFFDD0),
  'maroon': Color(0xFF9B2335),
  'teal': Color(0xFF14B8A6),
  'wine': Color(0xFF722F37),
  'golden': Color(0xFFFFD700),
  'gold': Color(0xFFFFD700),
  'silver': Color(0xFFC0C0C0),
  'indigo': Color(0xFF4F46E5),
  'violet': Color(0xFF7C3AED),
  'cyan': Color(0xFF06B6D4),
  'lime': Color(0xFF84CC16),
};

/// Returns the cheapest non-default variant and the total non-default count.
({Variant? variant, int count}) variantInfo(Product p) {
  final variants = (p.variants ?? [])
      .where((v) =>
          v.title != null &&
          v.title!.isNotEmpty &&
          v.title != 'Default Title' &&
          v.title != 'Default variant')
      .toList();
  if (variants.isEmpty) return (variant: null, count: 0);
  Variant? cheapest;
  double? minPrice;
  for (final v in variants) {
    final price =
        double.tryParse(v.calculatedPrice?.calculatedAmount?.toString() ?? '');
    if (price != null && (minPrice == null || price < minPrice)) {
      minPrice = price;
      cheapest = v;
    }
  }
  return (variant: cheapest ?? variants.first, count: variants.length);
}

Widget buildVariantChips(String title, int remaining) {
  final parts =
      title.split('/').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

  Widget chip(String label) {
    final swatch = kCardColorSwatchMap[label.toLowerCase()];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (swatch != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12, width: 0.5),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  return Wrap(
    spacing: 4,
    runSpacing: 4,
    children: [
      ...parts.map(chip),
      if (remaining > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '+$remaining',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3EAA3C),
              height: 1,
            ),
          ),
        ),
    ],
  );
}
