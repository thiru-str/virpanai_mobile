import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/list_shared.dart';

/// Banner17 — marketplace list component (rail).
/// Renders products/collections from content.layoutData; taps route via
/// layout_option (Product / Category / Custom). Auto-generated thin widget.
class Banner17 extends StatelessWidget {
  final Content content;
  const Banner17({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return LcSection(
      content: content,
      child: lcRail([
            for (int i = 0; i < items.length; i++) LcProductCard(item: items[i], onTap: () => lcTap(context, content, items[i]))
          ]),
    );
  }
}
