import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/list_shared.dart';

/// Banner9 — marketplace list component (rail poster).
/// Renders products/collections from content.layoutData; taps route via
/// layout_option (Product / Category / Custom). Auto-generated thin widget.
class Banner9 extends StatelessWidget {
  final Content content;
  const Banner9({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return LcSection(
      content: content,
      child: lcRail([
            for (int i = 0; i < items.length; i++) LcPosterCard(item: items[i], onTap: () => lcTap(context, content, items[i]))
          ]),
    );
  }
}
