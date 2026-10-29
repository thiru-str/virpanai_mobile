import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/list_shared.dart';

/// Collection5 — marketplace list component (coll grid).
/// Renders products/collections from content.layoutData; taps route via
/// layout_option (Product / Category / Custom). Auto-generated thin widget.
class Collection5 extends StatelessWidget {
  final Content content;
  const Collection5({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return LcSection(
      content: content,
      child: lcGrid([
            for (int i = 0; i < items.length; i++) LcCollectionCard(item: items[i], width: double.infinity, height: double.infinity, onTap: () => lcTap(context, content, items[i])),
          ], cols: 2, ratio: 1.0),
    );
  }
}
