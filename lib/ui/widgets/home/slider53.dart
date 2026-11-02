import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/list_shared.dart';

/// Slider53 — marketplace list component (rail compact).
/// Renders products/collections from content.layoutData; taps route via
/// layout_option (Product / Category / Custom). Auto-generated thin widget.
class Slider53 extends StatelessWidget {
  final Content content;
  const Slider53({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return LcSection(
      content: content,
      child: lcRail([
            for (int i = 0; i < items.length; i++) LcProductCard(item: items[i], width: 140, imageHeight: 132, onTap: () => lcTap(context, content, items[i]))
          ]),
    );
  }
}
