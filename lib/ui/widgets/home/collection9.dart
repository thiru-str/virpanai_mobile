import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/list_shared.dart';

/// Collection9 — marketplace list component (coll circular).
/// Renders products/collections from content.layoutData; taps route via
/// layout_option (Product / Category / Custom). Auto-generated thin widget.
class Collection9 extends StatelessWidget {
  final Content content;
  const Collection9({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return LcSection(
      content: content,
      centerHeader: true,
      child: lcRail([
            for (int i = 0; i < items.length; i++) LcCollectionCard(item: items[i], circular: true, width: 96, onTap: () => lcTap(context, content, items[i]))
          ]),
    );
  }
}
