import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/font_utils.dart';
import 'cms_text_color.dart';

// Shared helpers for the reusable product-card components (product_cards1.dart).
const Color kAccentInk = Color(0xFF0B0B0B);
const Color kCardBorder = Color(0x14000000);

String variantIdOf(LayoutDatum d) =>
    d.variantDetails?.variantId ?? d.cartDetails?.variantId ?? '';
int cartQtyOf(LayoutDatum d) => d.cartDetails?.quantity ?? 0;

// pack size like "1 kg" contains letters; a bare price number does not.
bool hasPackText(String? s) =>
    s != null &&
    s.isNotEmpty &&
    s.codeUnits.any((c) => (c >= 65 && c <= 90) || (c >= 97 && c <= 122));

String sellingPriceOf(LayoutDatum d) =>
    d.prices?.sellingPrice ?? d.prices?.discountedPrice ?? '0';
String originalPriceOf(LayoutDatum d) => d.prices?.originalPrice ?? '0';

// AddStepper — the shared ADD → −/+ control. `count == 0` shows ADD.
class AddStepper extends StatelessWidget {
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final Color accent;
  const AddStepper({
    super.key,
    required this.count,
    required this.onInc,
    required this.onDec,
    this.accent = kAccentInk,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return GestureDetector(
        onTap: onInc,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: cmsAccent(context, accent)),
          ),
          child: Text('ADD',
              style: FontUtils.primaryFontStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: cmsAccent(context, accent))),
        ),
      );
    }
    return Container(
      decoration:
          BoxDecoration(color: cmsAccent(context, accent), borderRadius: BorderRadius.circular(9)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(context, Icons.remove, onDec),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text('$count',
              style: FontUtils.primaryFontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: cmsOn(cmsAccent(context, accent)))),
        ),
        _btn(context, Icons.add, onInc),
      ]),
    );
  }

  Widget _btn(BuildContext context, IconData icon, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: SizedBox(
          height: 28, width: 26, child: Icon(icon, size: 15, color: cmsOn(cmsAccent(context, accent)))));
}

// A tiny reusable ★ rating chip.
class RatingChip extends StatelessWidget {
  final String rating;
  final bool solid;
  const RatingChip({super.key, required this.rating, this.solid = false});
  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF16A34A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: solid ? green.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star, size: 11, color: solid ? green : const Color(0xFFF59E0B)),
        const SizedBox(width: 2),
        Text(rating,
            style: FontUtils.primaryFontStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: solid ? green : const Color(0xFF6B7280))),
      ]),
    );
  }
}
