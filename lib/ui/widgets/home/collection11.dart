import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/widgets/home/list_shared.dart';

/// Collection11 — marketplace list component (coll rows).
/// Renders products/collections from content.layoutData; taps route via
/// layout_option (Product / Category / Custom). Auto-generated thin widget.
class Collection11 extends StatelessWidget {
  final Content content;
  const Collection11({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return LcSection(
      content: content,
      child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
            for (int i = 0; i < items.length; i++) LcCollectionRow(item: items[i], onTap: () => lcTap(context, content, items[i])),
          ]),
          ),
    );
  }
}
