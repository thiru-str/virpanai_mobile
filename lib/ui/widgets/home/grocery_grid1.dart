import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_utils.dart';
import 'homepage_merch_shared.dart';
import 'grocery_shared.dart';

// GroceryGrid1 — compact 3-up grocery grid with ADD buttons (daily essentials).
class GroceryGrid1 extends StatelessWidget {
  final Content content;
  const GroceryGrid1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? '',
            ctaText: content.layoutRedirectTitle ?? '',
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: items.length > 6 ? 6 : items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              mainAxisExtent: 230,
            ),
            itemBuilder: (context, i) => GroceryTile(data: items[i], width: 0),
          ),
        ],
      ),
    );
  }
}
