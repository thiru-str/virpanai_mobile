import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/list_shared.dart';

/// Banner12 — marketplace list component (grid3).
/// Renders products/collections from content.layoutData; taps route via
/// layout_option (Product / Category / Custom). Auto-generated thin widget.
class Banner12 extends StatelessWidget {
  final Content content;
  const Banner12({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return LcSection(
      content: content,
      child: lcGrid([
            for (int i = 0; i < items.length; i++) LcProductCard(item: items[i], grid: true, onTap: () => lcTap(context, content, items[i])),
          ], cols: 3, ratio: 0.5),
    );
  }
}
